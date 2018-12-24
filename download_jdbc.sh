
#!/bin/bash
file="/usr/share/java/kafka-connect-jdbc/postgresql-42.2.5.jar"
if [ ! -f "$file" ]
then
    mkdir -p /usr/share/java/kafka-connect-jdbc
    cd /usr/share/java/kafka-connect-jdbc
    sudo wget https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
fi
