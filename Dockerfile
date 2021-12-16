FROM mcr.microsoft.com/mssql/server:2019-CU11-ubuntu-20.04

USER root

RUN apt install bash -y

# Create a config directory
RUN mkdir -p /usr/config
RUN mkdir -p /usr/config/import
VOLUME /usr/config/import

# Bundle config source
COPY . /usr/config
RUN touch /usr/config/config.log

# Grant permissions for to our scripts to be executable
RUN chmod +x /usr/config/entrypoint.sh
RUN chmod +x /usr/config/configure-db.sh
RUN chmod 666 /usr/config/config.log

USER mssql
WORKDIR /usr/config

ENTRYPOINT ["./entrypoint.sh"]

# Tail the setup logs to trap the process
CMD ["tail -f /dev/null"]

HEALTHCHECK --interval=15s CMD /opt/mssql-tools/bin/sqlcmd -U sa -P "${SA_PASSWORD}" -Q "select 1" && grep -q "MSSQL CONFIG COMPLETE" ./config.log
