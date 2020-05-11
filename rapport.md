# RES 2020 Labo HTTP-Infra

**Auteurs : Christian Zaccaria, Nenad Rajic**

[TOC]

# Instructions et Objectifs
L'objectif de ce laboratoire est de pouvoir se familiariser avec les outils logiciels qui permettent de construire une infrastructure Web : c'est à dire un environnement permettant de fournir du contenu statique et dynamique aux navigateurs web. Pour cela, nous utiliserons _Serveur Apache httpd_ (pouvant agir à la fois comme serveur HTTP et reverse proxy) ainsi que _express.js_ (framework JS facilitant l'écriture d'applications web dynamiques).

Le deuxième objectif est de pouvoir mettre en œuvre une application web simple, complète et dynamique. Nous créons alors des ressources HTML, CSS et JS qui seront transmises aux navigateurs et présentées aux différents utilisateurs. Le code JavaScript exécuté dans le navigateur émettra des requêtes HTTP asynchrones à notre infrastructure Web (requêtes AJAX) et récupéra le contenu généré de manière dynamique. 

Finalement, ce laboratoire permet de pratiquer l'utilisation de Docker : pour ce faire tous les composants de l'infrastructure web sont regroupés dans différents images Docker personnalisées. (3 images différentes au minimum).

# Step 1 : Static HTTP server with apache httpd
# Step 2: Dynamic HTTP server with express.js
# Step 3: Reverse proxy with apache (static configuration)
# Step 4: AJAX requests with JQuery
# Step 5: Dynamic reverse proxy configuration
# Additional steps
## Load balancing: multiple server nodes
## Load balancing: round-robin vs sticky sessions
## Dynamic cluster management
## Management UI
