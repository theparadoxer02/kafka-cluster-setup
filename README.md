# Setup the Server

1. Generate a SSH Key in your system if not generated before using
    `ssh-keygen`. Double Press Enter and you private key is saved to the path `~/.ssh/id_rsa`

2. Copy the Private ssh key of your system to the Server/Remote Node
    `ssh-copy-id -i ~/.ssh/id_rsa user@remotehost`. do it for all the remote hosts.

3. In `hosts` file Change the values `ansible_user`, `ansible_host`, `ansible_private_key_file` according to the Nodes. If needed, you can add another Group.

4. Change IP address that are passed corresponding to the script to nodes ip address, Here we can add any odd number of ip address to make a kafka cluster.
 for ex:- ```script: ./zookeeper.sh 10.5.48.138 10.5.48.48 10.5.48.208```
