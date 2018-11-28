docker rm -f $(docker ps -a -q)


zk_server_list_arg=""
i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done

eval Server$id=0.0.0.0
echo Server$id
j=0
for var in "$@"
do
    let j=j+1
    zk_server_list_arg="$zk_server_list_arg -e zk_server.$j="$\Server$j":2888:3888"
done

echo $zk_server_list_arg


t="docker run -d \
    --name zoo-$id \
    -e zk_id=$id `# Zookeeper ID` \
    $zk_server_list_arg \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    confluent/zookeeper"

eval $t
