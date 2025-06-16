#cloud-config
package_update: true
package_upgrade: true
packages:
  - ca-certificates
  - apt-transport-https
  - lsb-release
  - gnupg
  - wget
  - curl

write_files:
  - path: /etc/ssl/nginx/nginx-repo.crt
    permissions: '0644'
    content: |
      ${nginx_cert}

  - path: /etc/ssl/nginx/nginx-repo.key
    permissions: '0644'
    content: |
      ${nginx_key}

  - path: /etc/nginx/license.jwt
    permissions: '0644'
    content: |
      ${nginx_jwt}

  - path: /usr/share/nginx/html/${html_filename}
    permissions: '0644'
    content: |
      ${html_content}

runcmd:
  - mkdir -p /etc/ssl/nginx
  - apt update
  - apt install -y apt-transport-https lsb-release ca-certificates wget gnupg2 ubuntu-keyring
  - wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor | sudo tee  /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
  - printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/ubuntu $(lsb_release -cs) nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
  - wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
  - apt update
  - apt install -y nginx-plus
  - |
    cat <<'EOF' > /etc/nginx/nginx.conf
    user nginx;
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
