# Install dependencied for Docker
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2


sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


sudo yum-config-manager --enable docker-ce-edge

sudo yum-config-manager --enable docker-ce-test

sudo yum install docker-ce

sudo systemctl start docker

sudo usermod -aG docker $USER

# Open firewall port 9092
sudo firewall-cmd \
  --zone=public \
  --add-port=9092/tcp \
  --add-port=2182/tcp \
  --add-port=3888/tcp \
  --add-port=2182/tcp \
  --permanent

# Reload Firewall
sudo firewall-cmd --reload

