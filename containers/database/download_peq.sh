#!/bin/bash
set -e

echo "Downloading PEQ database..."
curl -L -o /tmp/peq.zip "http://db.projecteq.net/api/v1/dump/latest"

echo "Extracting PEQ database..."
unzip -o /tmp/peq.zip -d /tmp/peq

echo "Importing PEQ database..."
for sql_file in /tmp/peq/peq-dump/create_*.sql; do
    echo "  Importing $(basename $sql_file)..."
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < "$sql_file"
done

echo "PEQ database import complete."
rm -rf /tmp/peq /tmp/peq.zip
