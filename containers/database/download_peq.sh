#!/bin/bash
# This script runs during MariaDB's docker-entrypoint init phase.
# The database is accessible via: mysql -u root ${MYSQL_DATABASE}
set -e

echo "Fetching latest PEQ database artifact..."
LATEST=$(curl -ksL "https://db.eqemu.dev/api/v1/artifacts" | \
  grep -oE '"filename":"[^"]+"' | head -1 | cut -d'"' -f4)

echo "Downloading ${LATEST}..."
curl -kL --progress-bar -o /tmp/peq.zip "https://db.eqemu.dev/api/v1/dump/archive/${LATEST}"

echo "Extracting PEQ database..."
unzip -o /tmp/peq.zip -d /tmp/peq

echo "Importing PEQ database tables..."
for sql_file in /tmp/peq/peq-dump/create_tables_*.sql; do
    echo "  Importing $(basename "$sql_file")..."
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < "$sql_file"
done

echo "PEQ database import complete."
rm -rf /tmp/peq /tmp/peq.zip
