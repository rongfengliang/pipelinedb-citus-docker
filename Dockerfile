FROM postgres:10
LABEL author="dalongrong"
LABEL email="1141591465@qq.com"
ARG VERSION=7.5.1
COPY docker-entrypoint-initdb.d/install_pipelinedb.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint-initdb.d/reenable_auth.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint-initdb.d/001-create-citus-extension.sql  /docker-entrypoint-initdb.d/
RUN  apt-get update && apt-get  -yqq install curl ca-certificates
RUN  curl -s http://download.pipelinedb.com/apt.sh |  bash
RUN  curl -s https://install.citusdata.com/community/deb.sh | bash \
    && apt-get install -y postgresql-$PG_MAJOR-citus-7.5=$CITUS_VERSION \
                          postgresql-$PG_MAJOR-hll=2.10.2.citus-1 \
                          postgresql-$PG_MAJOR-topn=2.0.2 \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*
RUN  apt-get install -yqq pipelinedb-postgresql-10
RUN echo "shared_preload_libraries = 'pipelinedb' " >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "max_worker_processes = 'pipelinedb' ">> /usr/share/postgresql/postgresql.conf.sample
RUN echo "shared_preload_libraries='citus'" >> /usr/share/postgresql/postgresql.conf.sample
COPY pg_healthcheck /
HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
