#! /bin/bash

docker kill $(docker ps -q) > /dev/null
docker rm $(docker ps -a -q)  > /dev/null

staticContainer1=$(docker run -d --name apache_static1 res/apache_php)
staticContainer2=$(docker run -d --name apache_static2 res/apache_php)
dynamicContainer1=$(docker run -d --name dynamic_express1 res/express_animals)
dynamicContainer2=$(docker run -d --name dynamic_express2 res/express_animals)

staticIP1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $staticContainer1)
staticIP2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $staticContainer2)
dynamicIP1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $dynamicContainer1)
dynamicIP2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $dynamicContainer2)


proxyName=$(docker run -d --name apache_rp -e STATIC_APP1=$staticIP1:80 -e STATIC_APP2=$staticIP2:80 -e DYNAMIC_APP1=$dynamicIP1:3000 -e DYNAMIC_APP2=$dynamicIP2:3000 -p 8080:80 res/apache_rp)

proxyIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $proxyName)

echo "Infra with reverse proxy and load balancing is done !"
echo "Reverse proxy IP: $proxyIP"
read -p "Press to exit"