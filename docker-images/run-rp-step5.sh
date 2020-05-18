#! /bin/bash

docker kill $(docker ps -q) > /dev/null
docker rm $(docker ps -a -q)  > /dev/null

staticContainer=$(docker run -d  --name apache_static res/apache_php)
dynamicContainer=$(docker run -d --name dynamic_express res/express_animals)

staticIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $staticContainer)
dynamicIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $dynamicContainer)


proxyName=$(docker run -d --name apache_rp -e STATIC_APP=$staticIP:80 -e DYNAMIC_APP=$dynamicIP:3000 -p 8080:80 res/apache_rp)

proxyIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $proxyName)

echo "Infra with reverse proxy is done !"
echo "Reverse proxy IP: $proxyIP"
read -p "Press to exit"