# Docker on CLOUD-Z


```sh
ssh-keygen -R <ip>
ssh root@<ip>

useradd skcc -m -s /bin/bash
passwd skcc
visudo -f /etc/sudoers

apt-get update
apt-get install vim
apt-get install apt-transport-https ca-certificates -y
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
vim /etc/apt/sources.list.d/docker.list
deb https://apt.dockerproject.org/repo ubuntu-xenial main
apt-get update
apt-get install docker-engine
systemctl enable docker
service docker start

docker run hello-world

groupadd docker
sudo usermod -aG docker $USER
sudo ufw status
sudo ufw allow 2375/tcp

su skcc
mkdir repo
cd repo
scp
cd ..
```

```
docker save -o <filename> <imagename>
docker load -i <filename> 
  
```

## 
```sh
docker run -i --cpus=5 --memory=8g -d -p 8889:8888 lecture_anomaly_detection /bin/bash
docker ps
#docker exec -u skcc -it <dockerID> bash
docker exec -it <dockerID> bash
```

```sh
docker run -i -d -p 8800:8888 -p 6600:6006 lecture_analytics_dl /bin/bash -c "jupyter notebook"
docker run -i -d --cpus=5 --memory=8g -p 8800:8888 -p 6600:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker exec -it <dockerID> bash

```


```sh

docker run -i -d --cpus=5 --memory=8g -p 8800:8888 -p 6600:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8801:8888 -p 6601:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8802:8888 -p 6602:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8803:8888 -p 6603:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8804:8888 -p 6604:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8805:8888 -p 6605:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8806:8888 -p 6606:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8807:8888 -p 6607:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8808:8888 -p 6608:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8808:8888 -p 6608:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"
docker run -i -d --cpus=5 --memory=8g -p 8809:8888 -p 6609:6006 lecture_analytics_dl /bin/bash -c "bash ./autostart.sh"

```

