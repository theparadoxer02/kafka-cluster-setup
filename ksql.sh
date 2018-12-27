source ~/.bashrc


docker run -d \
    --name ksql-$id \
    -e KSQL_BOOTSTRAP_SERVERS=10.0.1.70:9092 \
    -e KSQL_LISTENERS=http://0.0.0.0:8088/ \
    -e KSQL_KSQL_SERVICE_ID=$id \
    -p 8088:8088 \
    confluentinc/cp-ksql-server:5.1.0