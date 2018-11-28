# Setup the Server

1. Generate a SSH Key if not generated before using
    `ssh-keygen`

2. Copy the Private ssh key of your system to the Server/Remote Node
    `ssh -i ~/.ssh/id_rsa user@remotehost`

3. In the hosts file Change the values `ansible_user`, `ansible_host`, `ansible_private_key_file` according to your need. If needed add another Group in this file

4. Change Ip address that are passed corresponding to the script to nodes ip address, Here we can add any odder number of ip address to make a kafka cluster.