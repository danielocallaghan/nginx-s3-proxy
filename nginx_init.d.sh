#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

pid        logs/nginx.pid;


events {
  worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

  # DO NOT RESPOND TO REQUESTS OTHER THAN yourdomain.com
  # server {
  #   listen       80  default;
  #   server_name  _;
  #   return       444;
  # }

  # FILE UPLOADS
  server {
    listen   80;
    server_name  ec2-50-17-84-140.compute-1.amazonaws.com;

    access_log  /var/log/nginx/s3uploadproxy.access.log;
    error_log /var/log/nginx/s3uploadproxy.error.log;

    proxy_read_timeout 10;
    proxy_connect_timeout 10;
    client_max_body_size 30M;
    # slow uploads
    proxy_send_timeout 1200;

    # Deny illegal Host headers
    #if ($host !~* ^(yourdomain.com|www.yourdomain.com)$ ) {
    #  return 444;
    #}

    # dissalow methods
    if ($request_method !~ ^(OPTIONS|POST)$ ) {
      # empty response
      return 444;
    }

    location / {
      # CORS PRE-FLIGHT REQUESTS
      if ($request_method = 'OPTIONS') {
        more_set_headers 'Access-Control-Allow-Origin: *';
        more_set_headers 'Access-Control-Allow-Methods: POST, OPTIONS';
        more_set_headers 'Access-Control-Max-Age: 1728000';
        more_set_headers 'Content-Type: text/plain; charset=UTF-8';
        #more_set_headers 'Access-Control-Allow-Headers: ';
        return 200;
      }

      # FILE UPLOADS
      if ($request_method = 'POST') {
        more_set_headers 'Access-Control-Allow-Origin: *';
        proxy_pass http://epicenterdms.s3.amazonaws.com;
      }
    }

    # 204 (No Content) for favicon.ico
    location = /favicon.ico {
      #empty_gif;
      return 204;
    }
  }

  # HTTPS server
  #
  #server {
    # listen       443;
    # server_name  localhost;

    # ssl                  on;
    # ssl_certificate      cert.pem;
    # ssl_certificate_key  cert.key;

    # ssl_session_timeout  5m;

    # ssl_protocols  SSLv2 SSLv3 TLSv1;
    # ssl_ciphers  ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
    # ssl_prefer_server_ciphers   on;

    # location / {
    #    root   html;
    #    index  index.html index.htm;
    # }
  #}

}
