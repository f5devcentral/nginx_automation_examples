#cloud-config
package_update: true
package_upgrade: true
packages:
  - ca-certificates
  - lsb-release
  - gnupg
  - curl
  - wget

write_files:
  - path: /usr/share/nginx/html/${html_filename}
    permissions: '0644'
    content: |
      ${html_content}

runcmd:
  - apt update
  - curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg > /dev/null
  - echo "deb [signed-by=/etc/apt/keyrings/nginx.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
  - apt update
  - apt install -y nginx
  - |
    cat <<'EOF' > /etc/nginx/nginx.conf
    user www-data;
    worker_processes auto;
    error_log /var/log/nginx/error.log notice;
    pid /run/nginx.pid;

    events {
        worker_connections 1024;
    }

    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        sendfile on;
        keepalive_timeout 65;

        log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                        '\$status \$body_bytes_sent "\$http_referer" '
                        '"\$http_user_agent" "\$http_x_forwarded_for"';
        access_log /var/log/nginx/access.log main;

        server {
            listen 80;
            server_name ${server_ip};

            location / {
                root /usr/share/nginx/html;
                index ${html_filename};
            }

            location /status {
                stub_status on;
                access_log off;
                allow 127.0.0.1;
                deny all;
            }
        }
    }
    EOF
  - systemctl enable nginx
  - systemctl restart nginx
