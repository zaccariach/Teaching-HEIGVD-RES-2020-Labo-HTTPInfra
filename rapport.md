# RES 2020 Labo HTTP-Infra

**Auteurs : Christian Zaccaria, Nenad Rajic**

- [RES 2020 Labo HTTP-Infra](#res-2020-labo-http-infra)
- [Instructions et Objectifs](#instructions-et-objectifs)
- [Step 1: Static HTTP server with apache httpd](#step-1-static-http-server-with-apache-httpd)
- [Step 2: Dynamic HTTP server with express.js](#step-2-dynamic-http-server-with-expressjs)
- [Step 3: Reverse proxy with apache (static configuration)](#step-3-reverse-proxy-with-apache-static-configuration)
- [Step 4: AJAX requests with JQuery](#step-4-ajax-requests-with-jquery)
- [Step 5: Dynamic reverse proxy configuration](#step-5-dynamic-reverse-proxy-configuration)
- [Additional steps](#additional-steps)
  - [Management UI](#management-ui)
  - [Load balancing: multiple server nodes](#load-balancing-multiple-server-nodes)
  - [Load balancing: round-robin vs sticky sessions](#load-balancing-round-robin-vs-sticky-sessions)
  - [Dynamic cluster management](#dynamic-cluster-management)



# Instructions et Objectifs
L'objectif de ce laboratoire est de pouvoir se familiariser avec les outils logiciels qui permettent de construire une infrastructure Web : c'est à dire un environnement permettant de fournir du contenu statique et dynamique aux navigateurs web. Pour cela, nous utiliserons _Serveur Apache httpd_ (pouvant agir à la fois comme serveur HTTP et reverse proxy) ainsi que _express.js_ (framework JS facilitant l'écriture d'applications web dynamiques).

Le deuxième objectif est de pouvoir mettre en œuvre une application web simple, complète et dynamique. Nous créons alors des ressources HTML, CSS et JS qui seront transmises aux navigateurs et présentées aux différents utilisateurs. Le code JavaScript exécuté dans le navigateur émettra des requêtes HTTP asynchrones à notre infrastructure Web (requêtes AJAX) et récupéra le contenu généré de manière dynamique. 

Finalement, ce laboratoire permet de pratiquer l'utilisation de Docker : pour ce faire tous les composants de l'infrastructure web sont regroupés dans différents images Docker personnalisées. (3 images différentes au minimum).

**Il est important de noter que notre laboratoire a été réalisé à l'aide de _Docker Desktop for Windows, version 2.3.0.2_.** 

> En outre, nous avons décidé de _merge_ pour chaque _step_ effectué directement dans le _master_. Nous ne savons pas si cela est forcément une bonne pratique, mais pensons que ceci permet d'avoir directement dans _master_ la dernière étape finie et vérifiée. 

# Step 1: Static HTTP server with apache httpd

<u>**But**</u>

Installer un serveur apache (httpd) et le configurer tout en y ajoutant du contenu static HTML récupéré depuis le site web <https://startbootstrap.com/themes/> en utilisant Docker.

<u>**Réalisation**</u> 

Pour commencer, nous crééons une branche à partir du master nommée _fb-apache-static_, ceci afin de nous permettre de mettre en place cette première étape du laboratoire. Pour cette réalisation, nous avons créé un fichier Dockerfile et y avons écrit les lignes nous permettant de récupérer une image du _DockerHub_ contenant le serveur **httpd** et **PHP** mis à disposition : nous avons pris donc l'image officielle de **PHP** incluant aussi le server **httpd** 

Voici donc notre fichier Dockerfile:

```bash
FROM php:7.2-apache

COPY content/ /var/www/html/
```

La première ligne nous permet de récupérer notre image **httpd** et **PHP** avec la version 7.2 *d'apache* et la seconde ligne va copier notre dossier local `content`, contenant le dossier complet du site web static téléchargé depuis le site startbootstrap et modifié au préalable, dans le dossier `/var/www/html/` du container Docker.

Nous avons décidé de prendre le thème _FreeLancer_ sur _Boostrap_ et de le personnalisé afin qu'il soit à l'image de notre magnifique laboratoire de RES.

<u>**Test**</u>  

On ouvre une invite de commande à l'endroit où se trouve le fichier Dockerfile afin de créer une image et de lancer le container à partir de cette dernière comme suit: 

```
docker build -t res/apache_php .
docker run -d -p 9090:80 res/apache_php
```

Le paramètre `-d` n'est pas vraiment nécessaire (pas présent dans les podcasts), mais nous préferons l'utiliser afin de lancer le container en arrière plan. 

Il faut ensuite ouvrir un navigateur web, taper: `http://localhost:9090/` et le contenu web static s'affiche. 

![step1-website](img-rapport/step1-website.PNG)

# Step 2: Dynamic HTTP server with express.js

<u>**But**</u>

Mise en place une application web dynamique avec **Node.js** qui va retourner des données *JSON*. Cette application dockerisée va donc parler **HTTP** et fournir des données *JSON* à différents clients.

<u>**Réalisation**</u>

En premier, nous avons créé une branche *fb-express-dynamic* à partir de la branche *fb-apache-static*. Puis, comme à l'étape précédente, nous avons mis en place un fichier Dockerfile comme suit: 

```bash
FROM node:12.16

COPY src /opt/app

CMD ["node", "opt/app/index.js"]
```

La premièrer ligne permet de récupérer l'image Node version 12.16 depuis le *DockerHub* (dernière version LTS de **Node.js**), puis copier le contenu du dossier local `src` dans le dossier `/opt/app` du container Docker. Finalement la dernière ligne va nous permettre de lancer la commande `node index.js` à chaque démarrage du container.

Ensuite, à l'emplacement du fichier Dockerfile, nous avons créé un dossier `src` et y avons initialisé un environnement **NPM** en tapant `npm init` (insèrer uniquement le nom, version et auteur) dans une invite de commande. Il est imporant de noter que si on utilise Windows, il est nécessaire d'installer **Node.js**, téléchargeable à l'adresse : https://nodejs.org/fr/

Puis, afin d'utiliser les modules _chance_ et _express_ , il faut taper `npm install --save chance` et `npm install --save express` pour avoir accès à ces modules lors de l'implémentation de l'application. 

Ain de vérifier le fonctionnement de tout ceci, il a fallu créer un fichier `index.js` dans ce dossier `src` et implémenter l'application comme suit: 

```bash
var chance = require('chance');
var chance = new chance();

var express = require('express');
var app = express();

app.get('/', function(req, res){
    res.send(generateAnimals());
});

app.listen(3000, function(){
    console.log('Accepting HTTP requests on port 3000!');
});

function generateAnimals(){
	var numberOfAnimals = chance.integer({
		min : 1,
		max : 10
	});
	
	console.log(numberOfAnimals);
	
	var animals = [];
	
	for(var i = 0; i < numberOfAnimals; ++i){
        var gender = chance.gender();
		animals.push({
            'race'      : chance.animal(),
            'name'      : chance.first({ gender: gender }),
            'gender'    : gender,
            'age'       : chance.age({type: 'child'}),
            'country'   : chance.country({ full: true })
		});
	}
	console.log(animals);
	return animals;
}
```

Nous voyons ici que l'on écoute les requêtes sur le port 3000 et qu'à toute requête de type *GET* sur la cible '/', nous y générons un tableau avec un nombre d'animaux aléatoire (1 à 10) possédant une race, un nom, un genre, un age et un pays. Ensuite, ce tableau au format _json_ est envoyé en réponse au client connecté sur le port 3000 (à l'aide de telnet ou d'un naviagateur web).

<u>**Test**</u>  

On ouvre une invite de commande à l'endroit où se trouve le fichier Dockerfile afin de créer une image et de lancer le container à partir de cette dernière comme suit: 

```
docker build -t res/express_animals .
docker run -p 9091:3000 res/express_animals
```

Il faut ensuite ouvrir un navigateur web, taper: `http://localhost:9091/` et le contenu du tableau des étudiants s'affiche. Il est également possible comme mentionné dans le webcast d'utiliser l'application Postman pour envoyer la requête **GET** et recevoir la réponse du serveur. Une autre solution possible est aussi d'utiliser telnet et d'effectuer une requête **HTTP** (`GET / HTTP/1.0 CRLF`).

Voici le résultat avec le navigateur web :

![step2-website](img-rapport/step2-website.PNG)

# Step 3: Reverse proxy with apache (static configuration)

**<u>But</u>**

Mise en place d'un reverse proxy servant comme point d'entrée dans l'infrastructure contenant nos deux serveurs : le web serveur statique (**apache httpd**) et le web serveur dynamique (**express.js**). Ces derniers ne seront donc plus accessibles directement comme dans les étapes précédentes mais toutes requêtes AJAX passent uniquement par le reverse proxy en utilisant le *same-origin policy* permettant d'appliquer la politique de "tout script venant d'un certain nom de domaine peut faire des requêtes uniquement vers le même nom de domaine".

<u>**Réalisation**</u> 

En premier, nous avons créé une branche *fb-apache-reverse-proxy* à partir de la branche *fb-express-dynamic.* Deux containers sont lancés : l'un étant le serveur web static et l'autre le serveur web dynamique à l'aide des images générées aux précédentes étapes. 

Les commandes sont les suivantes:

```bash
docker run -d --name apache_static res/apache_php
docker run -d --name express_dynamic res/express_animals
```

Pour cette étape, il faut donc un container supplémentaire pour le reverse proxy. Un fichier Dockerfile est crée afin de créer ce container et se compose comme suit: 

```dockerfile
FROM php:7.2-apache

COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

Nous reprenons donc l'image en version 7.2 du serveur apache avec php et allons copier un dossier local `conf`, qui va être prochainement créé, dans le dossier `/etc/apache2` du container. Ensuite, il faut lancer les modules `a2enmod` pour activer les modules *proxy* et *proxy_http* et `a2ensite` pour activer les sites avec le nom de fichier `000-` et `001-`.

Avant de créer l'image, nous avons créé un dossier `conf/sites-available` en local à l'endroit où se trouvait notre Dockerfile et y avons ajouté 2 fichiers: `000-default.conf` et `001-reverse-proxy.conf`. 

**Contenu du fichier** `000-default.conf`: 

```
<VirtualHost *:80>
</VirtualHost>
```

Cette implémentation permet d'être plus strict ainsi que de définir l'hôte virtuel par défaut. On ne donne pas accès à du contenu / redirections et nous ne permettons pas d'afficher un message d'erreur en cas / d'accès non souhaité.

**Contenu du fichier** `001-reverse-proxy.conf`: 

```bash
<VirtualHost *:80>
	ServerName demo.res.ch

	#ErrorLog ${APACHE_LOG_DIR}/error.log
	#CustomLog ${APACHE_LOG_DIR}/access.log combined

	ProxyPass "/api/animals/" "http://172.17.0.3:3000/"
	ProxyPassReverse "/api/animals/" "http://172.17.0.3:3000/"

	ProxyPass "/" "http://172.17.0.2:80/"
    ProxyPassReverse "/" "http://172.17.0.2:80/"
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet

```

On va rediriger les requêtes `/` et `/api/animals/` vers l'IP de leur container respectif grâce aux mots-clés de mapping `ProxyPass` et `ProxyPassReverse`. Les deux IP peuvent être obtenues grâce à la commande suivante : 

```bash
docker inspect nom-du-container | grep -i ipaddress
```

> **Attention  ! ** Il est important de noter que la configuration statique est très fragile (notamment lorsqu'on ne sait pas ce que l'on fait) : en effet, c'est une très mauvaise idée "d'hardcoder" les adresses IP dans le reverse proxy car les containers Dockers possèdent des adresses IP accordées de manières dynamique. Il est donc toujours nécessaires de lancer les containers que le *reverse proxy* va utiliser, vérifier leur adresse IP afin de pouvoir insérer l'IP dans les *hôtes virtuels* pour ensuite *build* une image, etc... Ceci peut donc vite devenir un casse tête ...
>
> On verras par la suite qu'il existe _Docker compose_ permettant de faire ceci d'une façon bien plus "propre" ainsi que dynamique.

Finalement, avec la commande suivante, le container reverse proxy a été créé puis démarré comme suit: 

```bash
docker build -t res/apache_rp .
docker run -p 8080:80 res/apache_rp
```

Une dernière modification a été nécessaire sur notre machine, à savoir le fichier `/etc/hosts` sur un système Unix et `C:\Windows\System32\drivers\etc\hosts` sur un système Windows. Il a donc fallu ajouter une résolution du nom DNS `demo.res.ch` à l'adresse `localhost` comme suit (ceci est car nous utilisons _Docker for Windows_, car si l'on utilisait _Docker Toolbox_ on aurait une autre adresse IP et non localhost --> typiquement 192.168.99.100). 

```bash
127.0.0.1 demo.res.ch
```

<u>**Test**</u> 

On ouvre un navigateur web et de taper les lignes suivantes pour être redirigé soit sur le site web static soit sur notre tableau d'animaux.

```
http://demo.res.ch:8080/
```

![step3-website](img-rapport/step3-website.PNG)

```
http://demo.res.ch:8080/api/animals/
```

![step3-website-animals](img-rapport/step3-website-animals.PNG)

On va réessayer afin de vérifier que le contenu est chargé de manière dynamique.

![step3-website-animals2](img-rapport/step3-website-animals2.PNG)

Finalement, on peut vérifier que nous n'avons aucun accès autre que par le _reverse proxy_ en testant directement d'attendre les 2 serveurs. (l'argument `-C` est présent afin d'utiliser les fin de lignes supportées par le protocole _HTTP_ : à savoir `CRLF`)

![step3-cannot-access-servers](img-rapport/step3-cannot-access-servers.PNG)

Ceci se confirme par le fait qu'aucun _port mapping_ n'a été effectué lorsqu'on a créé les containers Docker. 

# Step 4: AJAX requests with JQuery

<u>**But**</u> 

Pouvoir implémenter une requête *AJAX* en utilisant la librairie Javascript nommée JQuery. On va donc envoyer des requêtes *AJAX*, à partir de la page principale, vers le backend dynamique afin de récupérer la liste d'animaux générée aléatoirement afin de mettre à jour une partie de l'interface utilisateur.

<u>**Réalisation**</u> 

Nous avons créé une branche *fb-ajax-jquery* à partir de la branche *fb-apache-reverse-proxy.* Nous avons ensuite ajouté une ligne supplémentaire dans les *Dockerfile* de chaque image effectué dans les 3 premiers points de ce laboratoire afin d'effectuer une mise à jour des packages et installer l'éditeur `vim` afin de pouvoir effectuer des modifications sur des fichiers.

```dockerfile
RUN apt-get update && apt-get install -y vim
```

Vu que les *Dockerfile* ont été modifiés, nous devons les générer à nouveau. Il suffit donc de relancer les commandes `build` et `run` comme décrites dans les étapes précédentes mais en suivant bien l'ordre des étapes de ce laboratoire : en effet les adresses IP des containers ont été "hardcodées", ce qui nous contraint à devoir obtenir les bonnes adresses IP aux bon containers.

Ensuite, nous avons dû ajouter la ligne suivante à la fin du body du fichier `content/index.html` (présent dans le serveur _apache_) permettant d'indiquer où se trouve le script `animals.js`: 

```bash
  <!-- Custom script to load animals -->
  <script src="js/animals.js"></script>
```

Puis, nous avons créé le fichier `/js/animals.js` (toujours des dossiers du serveur _apache_) qui contient les lignes suivantes: 

```bash
$(function() {
        console.log("Loading animals");

        function loadAnimals() {
                $.getJSON( "/api/animals/", function( animals ) {
                        console.log(animals);
                        var message = "No animal is here";
                        if( animals.length > 0 ) {
                                message = "Race : " + animals[0].race + " / Nom : " + 									animals[0].name ;
                        }
                        $(".masthead-subheading").text(message);
                });
        };

        loadAnimals();
        setInterval( loadAnimals, 2000);
});
```

Quand la librairie JQuery est chargée, la fonction est appelée. On définit donc une fonction où l'on définit l'URL contenant les résultats à récupérer et on appelle la fonction de callback lorsqu'on les reçoit. On va alors vérifier que la liste soit pleine et tout simplement construire notre chaîne de caractère avec la race de l'animal et son nom. Puis, ce message est placé dans une classe de la page qui va afficher le message (dans le cas présent dans la classe _masthead-subheading_, ceci sera visible juste sur le message _Welcome to RES_). 

Cette fonction va être appelé à intervalle de 2000 ms, affichant les différents animaux du tableau sur la page _index.html_.

> **Attention !** Il est important de noter que sans _Reverse proxy_ cette étape ne fonctionnerait pas, car nous n'avons pas défini de _port mapping_ permettant de faire le lien entre notre machine et les différents containers : si l'on essaie l'adresse `demo.res.ch:80 ou demo.res.ch:3000` rien ne se passera à cause du _port mapping_. 
>
> Nous n'excluons pas non plus l'hypothèse venant de la _Same-origin policy_ : en effet si aucun nom de domaine n'était spécifié, nous ne pensons pas qu'avec uniquement des adresses IP ceci puisse se faire.

**<u>Test</u>**

Premièrement, il faut d'abord supprimer les images qui ont été créées puis les générer à nouveau et les lancer en tapant les commandes `docker build` et `docker run` de chaque étape et cela dans l'ordre des étapes (afin que les modifications sur _index.html_, l'ajout de _animals.js_, ainsi que l'installation de _vim_ puissent avoir lieu). 

Commandes pour re-build les images

```
docker build -t res/apache_php . 
docker build -t res/express_animals .
docker build -t res/apache_rp .
```

Commandes pour lancer les containers (ces commandes doivent être lancé dans cet ordre prédéfini et une vérification des IP des containers _apache_static_ et _express_static_ est nécessaire afin de vérifier qu'elle possèdent bien l'adresse définie dans les _localhosts_).

```
docker run -d --name apache_static res/apache_php
docker run -d --name express_static res/express_animals
docker run -d -p 8080:80 --name apache_rp res/apache_rp
```

Puis, il faut ouvrir un navigateur web et taper `demo.res.ch:8080`. À partir de là, la classe choisie sur la page du site, pour contenir l'information récupérée depuis la liste, se mettra à jour toutes les 2000 ms.

![step4-website](img-rapport/step4-website.PNG)

Afin de vous montrer le bon fonctionnement de notre infrastructure, nous avons décidé de vous créer un petit _gif_ afin de vous montrer le changement d'animal tous les **2000 ms**. 
> Dans le _gif_ le port mappé avec le reverse proxy est le 9090 et non le 8080 (car nous avons fait la vidéo après coup et remarqué l'erreur après). Néanmoins ceci n'influence en aucun lieu le résultat à obtenir.

![ajax-queries](img-rapport/ajax-queries.gif)



# Step 5: Dynamic reverse proxy configuration

<u>**But**</u>

Pourvoir remplacer la configuration "hardcodée" afin de la rendre dynamique en passant les configuration IP via le flag `-e` de la commande `docker run` ainsi que exécuter un script personnalisée permettant de récupérer les variables environnement afin de générer un fichier de configuration.

<u>**Réalisation**</u>

Nous avons commencé par créer une branche *fb-dynamic-configuration* à partir de la branche *fb-ajax-jquery*. Nous avons ensuite créé un fichier `apache2-foreground`, au niveau du *Dockerfile*, repris depuis le git officiel de *docker PHP* (v7.2-apache, https://github.com/docker-library/php/blob/master/apache2-foreground), et rajouté les lignes ci-dessous permettant d'afficher en premier lieu les variables d'environnement passée en paramètre lors de la commande ``docker run` (avec le paramètre `-e` ) ainsi que de  copier le fichier de config généré en PHP.

```bash
#Add setup for RES lab
echo "Setup for the RES lab..."
echo "Static app URL: $STATIC_APP"
echo "Dynamic app URL: $DYNAMIC_APP"
php /var/apache2/templates/config-template.php > /etc/apache2/sites-available/001-reverse-proxy.conf
```

Une bonne pratique pour être sur que le fichier puisse être exécutable lorsqu'il est sur le _reverse proxy_ . 

```bash
chmod 755 apache2-foreground
```

Nous avons créé le fichier modèle de config PHP (`apache-reverse-proxy/templates/config-template.php`) permettant de récupérer les variables d’environnement passées en paramètre afin de les insérer à la configuration qui sera ensuite copiée dans le fichier `/etc/apache2/sites-available/001-reverse-proxy.conf`.

```php
<?php
    $dynamic_app = getenv('DYNAMIC_APP');
    $static_app = getenv('STATIC_APP');
?>

<VirtualHost *:80>
	ServerName demo.res.ch
	
	ProxyPass '/api/animals/' 'http://<?php print "$dynamic_app"?>/'
	ProxyPassReverse '/api/animals/' 'http://<?php print "$dynamic_app"?>/'
	
	ProxyPass '/' 'http://<?php print "$static_app"?>/'
	ProxyPassReverse '/' 'http://<?php print "$static_app"?>/'
</VirtualHost>

```

Ensuite, le *Dockerfile* a été modifié afin de prendre ces changements en compte.

> Attention : Il est très important que ce fichier `apache2-foreground` soit en format _UNIX_ (**LF** UNIQUEMENT !) donc il faut le convertir lorsqu'on travaille sur *Windows*. On peut facilement le convertir avec _Notepad++_ par exemple. 
>
> Cependant, nous voulons éviter tous les risques et donc dans le _reverse proxy_ nous installons aussi un utilitaire appelant _dos2unix_ permettant de convertir les chaines `CRLF` en `FL` . Nous spécifions aussi dans le _Dockerfile_ la conversion du fichier : cela est surement inutile lorsqu'on utilise un environnement Unix, cependant vaut mieux prévenir que guérir !

```dockerfile
FROM php:7.2-apache

RUN apt-get update && apt-get install -y vim && apt-get install dos2unix

COPY templates /var/apache2/templates
COPY conf/ /etc/apache2

COPY apache2-foreground /usr/local/bin/
RUN cd /usr/local/bin/ && dos2unix apache2-foreground

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*

```

Finalement, il est possible de modifier le fichier `conf/sites-available/001-reverse-proxy.conf` afin de mettre en commentaires les commandes `proxyPass` et `ProxyPassReverse`, car elles seront, de toutes manière, écrasées par la copie de la config effectuée par le script `apache2-foreground`. Cependant, nous ne l'avons pas effectué car ceci permet toujours d'avoir le _Step 1_ sans aucune modification.

Nous pouvons donc refaire un *build* de l’image *res/apache_rp* en se situant dans le répertoire contenant le *Dockerfile* avec la commande suivante: `docker build -t res/apache_rp .`

<u>**Test**</u>

Nous avons démarré plusieurs containers de l’image `res/apache_php` (sans nom, sauf un se nommant `apache_static` que l'on va utiliser) et plusieurs containers de l’image `res/express_animals` (sans nom, sauf un se nommant `express_dynamics` l'on va utiliser). 

Nous cherchons ensuite l’adresse IP des containers  `apache_static` et `express_dynamic` (avec la commande `docker inspect NOM_DU_CONTAINER | grep -i ipaddress` afin de lancer notre container pour le _reverse_proxy_ avec la commande suivante.

> Dans la commande suivante, le x des 2 adresses IP est à remplacer par celui de `apache_static` et `express_dynamic`.

> 

```bash
docker run -d -e STATIC_APP=172.17.0.x:80 -e DYNAMIC_APP=172.17.0.x:3000 --name apache_rp -p 8080:80 res/apache_rp
```

Nous vérifions alors que tout exécute correctement en allant à l'adresse suivante (toutes les étapes précédentes doivent toujours fonctionner).

```
http://demo.res.ch:8080/
```

![step5-website](img-rapport/step5-website.PNG)

Finalement, ne trouvant pas que cette étape est totalement "dynamique", nous avons décidé de créer un script *bash* permettant de démarrer les trois containers (`apache_static, express_dynamic et apache_rp`) et d'automatiser la recherche de l'adresse IP des deux serveurs. Ceci permet d'ajouter un petit supplément à ce laboratoire ainsi qu'à la partie suivie par des podcasts ! 

Voici le script créé `run-rp-step5.sh` (testé et approuvé sur Ubuntu ainsi que Windows)

```
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
```

# Additional steps
## Management UI

Afin de ne pas re-inventer la roue, nous avons décidé de rechercher sur le web si des images / containers permettent de mettre en place un outil regroupant l'accès ainsi que la gestion des différents containers présent sur notre machine à l'aide d'une GUI.

Après différentes recherches, nous avons décidé d'utiliser l'outil nommé _Portainer_ nous permettant d'effectuer les différentes actions voulues.

<u>**Réalisation**</u>

Nous avons créé une branche *Management-UI* à partir de la branche *fb-dynamic-configuration.* 

Nous avons trouvé ce lien, nous permettant de mettre en place l'outil très facilement : https://gist.github.com/SeanSobey/344edd228922ffd4266ae7d451421ab6

1. Vérifier que l'option daemon sans TLS est bien activée.

   ![stepUI-verifiy-daemon](img-rapport/stepUI-verifiy-daemon.PNG)

2. Créer un volume docker.

```  
docker volume create portainer_data
```

3. Démarrage du container avec l'image *Portainer* (nous avons choisi la version avec une authentification nécessaire).

```  
docker run -d -p 3040:9000 --name portainer --restart=always -v portainer_data:/data portainer/portainer -H tcp://docker.for.win.localhost:2375
```

<u>**Test**</u>

Aller à l'adresse http://localhost:3040

Nous arrivons sur une page permettant de créer un utilisateur. (Nous avons créer l'utilisateur *Tartenpion* et mot de passe _ResIsFun2020_)

![stepUI-login](img-rapport/stepUI-login.PNG)

Nous arrivons alors dans une page permettant de gérer nos différents containers /images ainsi que notre environnement _Docker_.

![stepUI-GUI](img-rapport/stepUI-GUI.PNG)

## Load balancing: multiple server nodes

<u>**But**</u> 

Mise en place un mécanisme permettant en cas de défaillance d'un des serveurs (dans notre cas de containers) d'avoir toujours accès au site (la charge est donc repartie sur un autre serveur).

**Réalisation**: 

Nous avons créé une branche *fb-loadBalancing-mutiple* à partir de la branche *Management-UI*. 

Après avoir rechercher dans la documentation officielle de _Apache httpd_, nous avons trouvé ceci https://httpd.apache.org/docs/2.4/mod/mod_proxy_balancer.html.

Il est défini que afin d'implémenter la répartition de charge, il est nécessaire d'avoir 3 modules activés :

* *proxy* (déjà implémenté)
* *proxy_balancer* (nécessaire à la répartition de charge)  
* Un algorithme permettant de planifier la répartition de charge : nous avons choisi un algorithme se basant sur le comptage des requêtes --> *lbmethod_byrequests* (définit l'algorithme de planification de la répartition de charge). 

Par conséquent, nous avons du adapté dans le *Dockerfile* du serveur proxy.

```dockerfile
RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests
```

Nous devons ensuite modifier notre fichier *config-template.php* afin d'y insérer plusieurs adresses IP pour un serveur donné (adresses IP des serveurs statiques et dynamique). Ceci permettra alors de répartir la charge sur un autre serveur dans le cas qu'un serveur soit défaillant.

```php
<?php
 	$dynamic_app1 = getenv('DYNAMIC_APP1');
 	$dynamic_app2 = getenv('DYNAMIC_APP2');
    $static_app1 = getenv('STATIC_APP1');
    $static_app2 = getenv('STATIC_APP2');
?>

<VirtualHost *:80>
 ServerName demo.res.ch

 <Proxy "balancer://dynamic_app">
    BalancerMember 'http://<?php print "$dynamic_app1"?>'
    BalancerMember 'http://<?php print "$dynamic_app2"?>'
 </Proxy>
 
 <Proxy "balancer://static_app">
    BalancerMember 'http://<?php print "$static_app1"?>'
    BalancerMember 'http://<?php print "$static_app2"?>'
 </Proxy>

 ProxyPass '/api/animals/' 'balancer://dynamic_app/'
 ProxyPassReverse '/api/animals/' 'balancer://dynamic_app'
 
 ProxyPass '/' 'balancer://static_app/'
 ProxyPassReverse '/' 'balancer://static_app/'
</VirtualHost>
```

Finalement, il faut re-build à nouveau l'image `apache_rp` avec le nouveau *Dockerfile*.

**<u>Test</u>**

On lance 2 serveurs *apache_static* et 2 serveurs *express_dynamic*. 
```
docker run -d --name apache_static1 res/apache_php
docker run -d --name apache_static2 res/apache_php
docker run -d --name express_dynamic1 res/express_animals
docker run -d --name express_dynamic2 res/express_animals
```
A l'aide de `docker inspect` , on récupère leurs adresses IP afin de les inscrire dans la commande qui suit pour le démarrage du container *apache_rp* :

```bash
docker run -d -e STATIC_APP1=172.17.0.2:80 -e STATIC_APP2=172.17.0.3:80 -e DYNAMIC_APP1=172.17.0.4:3000 -e DYNAMIC_APP2=172.17.0.5:3000 --name apache_rp -p 8080:80 res/apache_rp
```

Nous vérifions que l'accès au site est bien possible (à l'aide du navigateur) et ensuite tuons 2 containers (1 pour les serveurs statiques et 1 pour les serveurs dynamique) à l'aide de les commandes suivantes.

```bash
docker kill apache_static1
docker kill express_dynamic2
```

Nous vérifions que le site est toujours fonctionnel après avoir effectué un rafraîchissement de la page (CTRL + F5).

![stepLoadBalancing-website](img-rapport/stepLoadBalancing-website.PNG)

Finalement, comme pour le _STEP 5_, nous avons crée un script permettant d'automatiser la création de containers pour cette infrastructure.

Voici le script créé `run-rp-stepLoadBalancing.sh` (testé et approuvé sur Ubuntu ainsi que Windows)

```
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


proxyName=$(docker run -d --name apache_rp -e STATIC_APP1=$staticIP1:80 -e STATIC_APP2=$staticIP2:80 -e DYNAMIC_APP1=$dynamicIP1:3000 -e DYNAMIC_APP2=$dynamicIP2:3000 -p 9090:80 res/apache_rp)

proxyIP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $proxyName)

echo "Infra with reverse proxy and load balancing is done !"
echo "Reverse proxy IP: $proxyIP"
read -p "Press to exit"
```

## Load balancing: round-robin vs sticky sessions

## Dynamic cluster management