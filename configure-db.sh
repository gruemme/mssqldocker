#!/bin/basg
# Shell script to import data into a MS SQL Server Docker container

shopt -s nullglob

# wait for MSSQL server to start
export STATUS=1
i=0

while [ ${STATUS} -ne 0 ] && [ $i -lt 30 ]; do
	i=$i+1
	/opt/mssql-tools/bin/sqlcmd -t 1 -U sa -P "${SA_PASSWORD}" -Q "select 1" >> /dev/null
	STATUS=$?
done

if [ ${STATUS} -ne 0 ]; then
	echo "Error: MSSQL SERVER took more than thirty seconds to start up."
	exit 1
fi

echo "======= MSSQL SERVER STARTED ========" | tee -a ./config.log
echo "======= MSSQL CONFIGURATION STARTED ========" | tee -a ./config.log
# Run the setup script to create the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1 -U sa -P "${SA_PASSWORD}" -d master -i setup.sql

for file in ./import/*.sql; do
  echo "======= Execute script ${file} to database ${MSSQL_DB} ========"
  /opt/mssql-tools/bin/sqlcmd -m -1 -S 127.0.0.1 -U sa -P "${SA_PASSWORD}" -d ${MSSQL_DB} -i "${file}";
done

echo "======= MSSQL CONFIGURATION COMPLETE =======" | tee -a ./config.log
