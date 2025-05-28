FROM apache/hive:4.0.0

USER root

RUN apt-get update && apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

USER hive