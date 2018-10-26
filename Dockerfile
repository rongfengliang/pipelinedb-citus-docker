FROM postgres:10
LABEL author="dalongrong"
LABEL email="1141591465@qq.com"
COPY docker-entrypoint-initdb.d/install_pipelinedb.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint-initdb.d/reenable_auth.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint-initdb.d/001-create-citus-extension.sql  /docker-entrypoint-initdb.d/
RUN  apt-get update
RUN  curl -s http://download.pipelinedb.com/apt.sh |  bash
RUN  apt-get install -yqq pipelinedb-postgresql-10
RUN echo "shared_preload_libraries = 'pipelinedb' " >> ${PGDATA}/postgresql.conf.sample
RUN echo "max_worker_processes = 'pipelinedb' ">> ${PGDATA}/postgresql.conf.sample
RUN echo "shared_preload_libraries='citus'" >> ${PGDATA}/postgresql.conf.sample
COPY pg_healthcheck /
HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
