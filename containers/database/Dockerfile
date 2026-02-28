FROM mariadb:10.11

RUN apt update && apt install -y ca-certificates curl unzip && rm -rf /var/lib/apt/lists/*

ADD containers/database/download_peq.sh /docker-entrypoint-initdb.d/00_download_peq.sh
ADD Server/loginserver/login_util/login_schema.sql /docker-entrypoint-initdb.d/01_login_schema.sql

RUN chmod +x /docker-entrypoint-initdb.d/00_download_peq.sh
