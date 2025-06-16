resource "azurerm_nginx_configuration" "main" {
  nginx_deployment_id = azurerm_nginx_deployment.main.id
  root_file           = "/etc/nginx/nginx.conf"

  config_file {
    content = base64encode(<<-EOT
      user nginx;
      worker_processes auto;
      worker_rlimit_nofile 8192;
      pid /run/nginx/nginx.pid;
      load_module modules/ngx_http_app_protect_module.so;

      events {
          worker_connections 4000;
      }

      error_log /var/log/nginx/error.log error;

      http {
          upstream app {
              zone app 64k;
              server ${azurerm_public_ip.vm_pip[0].ip_address} weight=50 max_fails=3 fail_timeout=30s;
              server ${azurerm_public_ip.vm_pip[1].ip_address} weight=50 max_fails=3 fail_timeout=30s;
          }

          app_protect_enforcer_address 127.0.0.1:50000;

          server {
              listen 80 default_server;

              location / {
                  app_protect_enable on;
                  app_protect_policy_file /etc/app_protect/conf/NginxStrictPolicy.json;
                  app_protect_security_log_enable on;
                  app_protect_security_log "/etc/app_protect/conf/log_all.tgz" syslog:server=localhost:5140;
                  proxy_set_header Host \$host;
                  proxy_set_header X-Real-IP \$remote_addr;
                  proxy_set_header X-Proxy-app app;
                  proxy_pass http://app;
              }
          }
      }
    EOT
    )
    virtual_path = "/etc/nginx/nginx.conf"
  }

  depends_on = [azurerm_nginx_deployment.main]
}

