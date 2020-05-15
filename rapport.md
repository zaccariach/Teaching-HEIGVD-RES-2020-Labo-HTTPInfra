# RES 2020 Labo HTTP-Infra

**Auteurs : Christian Zaccaria, Nenad Rajic**

[TOC]

# Instructions et Objectifs
L'objectif de ce laboratoire est de pouvoir se familiariser avec les outils logiciels qui permettent de construire une infrastructure Web : c'est à dire un environnement permettant de fournir du contenu statique et dynamique aux navigateurs web. Pour cela, nous utiliserons _Serveur Apache httpd_ (pouvant agir à la fois comme serveur HTTP et reverse proxy) ainsi que _express.js_ (framework JS facilitant l'écriture d'applications web dynamiques).

Le deuxième objectif est de pouvoir mettre en œuvre une application web simple, complète et dynamique. Nous créons alors des ressources HTML, CSS et JS qui seront transmises aux navigateurs et présentées aux différents utilisateurs. Le code JavaScript exécuté dans le navigateur émettra des requêtes HTTP asynchrones à notre infrastructure Web (requêtes AJAX) et récupéra le contenu généré de manière dynamique. 

Finalement, ce laboratoire permet de pratiquer l'utilisation de Docker : pour ce faire tous les composants de l'infrastructure web sont regroupés dans différents images Docker personnalisées. (3 images différentes au minimum).

**Il est important de noter que notre laboratoire a été réalisé à l'aide de _Docker Desktop for Windows, version 2.3.0.2_.** 

# Step 1 : Static HTTP server with apache httpd

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
# Step 3: Reverse proxy with apache (static configuration)
# Step 4: AJAX requests with JQuery
# Step 5: Dynamic reverse proxy configuration
# Additional steps
## Load balancing: multiple server nodes
## Load balancing: round-robin vs sticky sessions
## Dynamic cluster management
## Management UI
