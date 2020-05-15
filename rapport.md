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
var Chance = require('chance');
var chance = new Chance();

var express = require('express');
var app = express();

app.get('/', function(req, res){
    res.send(generateStudents());
});

app.listen(3000, function(){
    console.log('Accepting HTTP requests on port 3000!');
});

function generateStudents(){
	var numberOfStudents = chance.integer({
		min : 1,
		max : 10
	});
	
	console.log(numberOfStudents);
	
	var students = [];
	for(var i = 0; i < numberOfStudents; ++i){
        var gender = chance.gender();
		var birthYear = chance.year({
			min: 1986,
			max: 1996
		});
		students.push({
            firstName: chance.first({
				gender: gender
			}),
			lastName: chance.last(),
			gender: gender,
			birthday: chance.birthday({
				year: birthYear
			})
		});
	};
	console.log(students);
	return students;
}
```

Nous voyons ici que l'on écoute les requêtes sur le port 3000 et qu'à toute requête de type GET sur la cible '/', nous y générons un tableau avec un nombre d'étudiant aléatoire (1 à 10) possédant un genre, une date de naissance, un nom et prénom. Ensuite, ce tableau au format _json_ est envoyé en réponse au client connecté sur le port 3000 (à l'aide de telnet ou d'un naviagateur web).

<u>**Test**</u>  

On ouvre une invite de commande à l'endroit où se trouve le fichier Dockerfile afin de créer une image et de lancer le container à partir de cette dernière comme suit: 

```
docker build -t res/express_students .
docker run -p 9091:3000 res/express_students
```

Il faut ensuite ouvrir un navigateur web, taper: `http://localhost:9091/` et le contenu du tableau des étudiants s'affiche. Il est également possible comme mentionné dans le webcast d'utiliser l'application Postman pour envoyer la requête **GET** et recevoir la réponse du serveur. Une autre solution possible est aussi d'utiliser telnet et d'effectuer une requête **HTTP** (`GET / HTTP/1.0 CRLF`).

# Step 3: Reverse proxy with apache (static configuration)
# Step 4: AJAX requests with JQuery
# Step 5: Dynamic reverse proxy configuration
# Additional steps
## Load balancing: multiple server nodes
## Load balancing: round-robin vs sticky sessions
## Dynamic cluster management
## Management UI
