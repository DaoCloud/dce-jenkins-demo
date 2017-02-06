FROM daocloud.io/jenkins

USER root
ENV NGINX_VERSION 1.11.9-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
                        ca-certificates \
                        nginx=${NGINX_VERSION} \
                        nginx-module-xslt \
                        nginx-module-geoip \
                        nginx-module-image-filter \
                        nginx-module-perl \
                        nginx-module-njs \
                        gettext-base \
    && rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/entrypoint.sh", "/usr/local/bin/jenkins.sh"]

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY jenkins.conf /etc/nginx/conf.d/jenkins.conf
COPY plugin.json /usr/share/nginx/html/plugin.json

LABEL io.daocloud.dce.plugin.name="dce-jenkins" \
      io.daocloud.dce.plugin.description="这是一个 DCE 与 Jenkins 集成的示例" \
      io.daocloud.dce.plugin.categories="continuous-integration" \
      io.daocloud.dce.plugin.icon-src="https://dce.daocloud.io/v1/plugin-store/blob/Jenkins-60ec5.svg" \
      io.daocloud.dce.plugin.vendor="DaoCloud" \
      io.daocloud.dce.plugin.required-dce-version=">=2.2.0" \
      io.daocloud.dce.plugin.nano-cpus-limit="500000000" \
      io.daocloud.dce.plugin.memory-bytes-limit="52428800"
