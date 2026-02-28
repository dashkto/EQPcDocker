FROM mariadb:10.11

RUN apt update && apt install -y curl unzip && rm -rf /var/lib/apt/lists/*

ADD Server/loginserver/login_util/login_schema.sql /docker-entrypoint-initdb.d/01_login_schema.sql
ADD containers/database/download_peq.sh /docker-entrypoint-initdb.d/00_download_peq.sh

RUN chmod +x /docker-entrypoint-initdb.d/00_download_peq.sh
