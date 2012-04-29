# alias sshec2='ssh -v -i ~/.ssh/s3-proxy-keypair.pem ubuntu@ec2-50-17-84-140.compute-1.amazonaws.com'
sudo su -

# stuff we need to build from source
apt-get update
apt-get install libpcre3-dev build-essential libssl-dev

# get the nginx source
cd /opt/
wget http://nginx.org/download/nginx-0.8.54.tar.gz
tar -zxvf nginx*
# we'll put the source for nginx modules in here
mkdir /opt/nginxmodules
cd /opt/nginxmodules
# get the source for the Headers More module - see http://wiki.nginx.org/HttpHeadersMoreModule
wget --no-check-certificate http://github.com/agentzh/headers-more-nginx-module/tarball/v0.14
tar -zxvf v0.14
mv agentzh-headers-more-nginx-module-2cbbc15 headers-more
cd /opt/nginx*/

# configure with chosen modules - see http://wiki.nginx.org/InstallOptions & http://articles.slicehost.com/2008/5/13/ubuntu-hardy-installing-nginx-from-source
./configure \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/lock/nginx.lock \
  --http-log-path=/var/log/nginx/access.log \
  --with-http_dav_module \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --with-http_stub_status_module \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --with-debug \
  --add-module=/opt/nginxmodules/headers-more \
  --with-http_ssl_module

make
make install

mkdir -p /var/lib/nginx/body
mkdir -p /var/lib/nginx/proxy
mkdir -p /var/lib/nginx/fastcgi
mkdir -p /var/lib/nginx/uwsgi
mkdir -p /var/lib/nginx/scgi
mkdir /usr/local/nginx/logs/
# copy in nginx_init.d.sh to /etc/init.d/
sudo chmod +x /etc/init.d/nginx
sudo /usr/sbin/update-rc.d -f nginx defaults

vi /etc/init.d/nginx # edit the DEAMON with the correct new path, which is now /usr/local/nginx/sbin/nginx

/etc/init.d/nginx start
