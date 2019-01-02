# Setup the Server

1. Create Servers in AWS/or anywhere 
    Then environment variable named `id` for the `sudo` user to all the servers and assign serial no to them.
    

    Note: The Environment variable should be made for superuser otherwise it won't work.So do only it after changing user to superuser.
    
    For ex:- If you have 3 nodes then:
    ```
    echo id=1 >> .bashrc in node1
    echo id=2 >> .bashrc in node3
    echo id=3 >> .bashrc in node3
    ```


2. Since We are using bastion server to hit request over the Nodes, So In `hosts.ini` file we need to       add an extra argument to do ssh to the node.
    ```
    ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q bastionuser@bastionserver"'
    ```

4. In `playbook.yml` file Change IP address  to Nodes Ips that are passed corresponding to the script
    
    For ex:- 
    ```
    script: ./zookeeper.sh 10.0.1.70 10.0.1.94 10.0.1.212
    ```
5. In `create_sink.sh` file to change the sink configuration file:
    ```
    "connection.url": "jdbc:postgresql://hostname:5432/nextiot",
    "connection.user": "database_user",
    "connection.password": "database_pass"
    ```

6. Run Command:

    To Add private key identity to authentication origin
    ```
    ssh-add -k NextSoftware.pem
    ```


    To Check if all of your hosts are accessible:
    ```
    ansible all -m ping -i hosts.ini
    ```
    To Start The Kafka Cluster:
    ```
    ansible-playbook -i hosts.ini --become playbook.yml
    ```

7. This Script with start with Zookeeper, Kafka, Schema-Registry in all the node and 
    Kafka-connect with sink to postgres in a first node.


# Note:
The default Topic created is `nextiot`and the current setup will be fetching and sinking data to postgres from the same topic