docker rm -f $(docker ps -a -q) # Delete previously docker container


# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done

eval Server$id=0.0.0.0  # Set the node's ip to 0.0.0.0 in whichever node it is running
# echo Server$id

# From list of argument passed Generate text like:
#   "-e zk_server.1=$Server1:2888:3888 -e zk_server.2=$Server2:2888:3888"

zk_server_list_arg=""   # ZK Server argument text needed while running zookeeper container
j=0
for var in "$@"
do
    let j=j+1
    zk_server_list_arg="$zk_server_list_arg -e zk_server.$j="$\Server$j":2888:3888"
done

# echo $zk_server_list_arg

t="docker run -d \
    --name zoo-$id \
    -e zk_id=$id `# Zookeeper ID` \
    $zk_server_list_arg \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    confluent/zookeeper"

eval $t
