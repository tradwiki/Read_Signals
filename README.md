# Journal de résidence 2022-03-15 - Splash

## Avant

### Intentions

* Tenter de faire deux mappings simultanés avec Splash, soit:
  * DrawPlanck sur un cube
  * La sortie vidéo LivePose sur un des cube et DrawPlanck à l'écran principal (le coin)

## Pendant

### Installation des outils et équipement

#### Emplacement

* Le coin de mur du métalab
* 2 cubes collés

#### Réglages

* Ordinnateur : Molécule de la SAT
* molécule mp : satmetalab (l'ordinateur est déjà configuré pour notre projet depuis la dernières fois dans les fichiers configs de livepose / splash)
* Utiliser mon ordinateur(mac) pour rouler DrawPlanck et l'envoyer par le plugin NDI sur obs
* Connecter mon ordinateur au modem par cable ethernet
* caméra : intel realsense [d435i](https://www.intelrealsense.com/depth-camera-d435i/)

##### LivePose

* loader à l'environment virtuel (important pour certains programmes python) ". livepose\_venv/bin/activate" ou 'source livepose\_venv/bin/activate'
* 'cd sources/livepose/'
* './livepose.sh -c livepose/configs/mmpose.json'
* configurer le programme avec la bonne caméra commande "vim livepose/configs/mmpose.json"
* streamer l'image avec obs
* One-line version: . \~/livepose\_venv/bin/activate && cd sources/livepose/ && ./livepose.sh -c livepose/configs/mmpose.json

##### Splash

* Start Obs (webcam virtuelle) and turn on NDI plugin on remote machine
* accéder au dossier podorythmie sur l'ordinateur molécule pour reprendre notre config de la dernière fois (sur l'ordinateur molécule)
* 'ndi2shmdata -L' (pour identifier le signal provenant de mon ordi) after turning OBS on in the host
* Copy the source arrival name (e.g., MACBOOK-PRO-DE-MAC.LOCAL (OBS processing))
* ndi2shmdata -n 'MACBOOK-PRO-DE-MAC.LOCAL (OBS processing)' -v /tmp/ndi\_video" (pour mettre le flux video dans un fichier temporaire) - needs to keep running
* Open splash: ' splash -o /home/metalab/Documents/Podorythmie/splash.json' (project file is podo.splash.project
* EXTRA : to modify the map, ouvrir blender et associer le bon fichier dans splash afin de modéliser l'espace en temps réel.
* Pour l'entrée NDI via Ethernet : utiliser le nom complet qui est affiché par la commande pour créer un feed temporaire pour le signal NDI : utiliser le bon nom : "MACBOOK-PRO-DE-MAC.LOCAL (Obs processing)"
* Copy-paste sequence: 
  * ndi2shmdata -n 'MACBOOK-PRO-DE-MAC.LOCAL (OBS processing)' -v /tmp/ndi\_video
  * splash -o /home/metalab/Documents/Podorythmie/splash.json


* Splash info for media:
  * media 1: shmdata -> /tmp/ndi\_video (2nd parameter)
  * media 2: video4Linux -> /dev/video6 (change the device accordingly) -> click "do capture" 

##### Blender

* Trouver le fichier associe a l'image video
* Ouvrir le fichier en question dans Blender
* Peser send mesh dans plane settings de blender
* Peser sur la touche 'g' pour bouger
  * Object mode pour bouger l'objet entierement
  * Edit mode pour changer le positionement des points

#### Problèmes rencontrés

Michal a passé une bonne partie de la matinée à troubleshooter l'ordinateur afin que l'objectif soit atteint.

Quelques problèmes auxquels nous avons fait face:

* difficile de savoir quelle caméra est l'entre de données (se trouve par essaie erreur dans le dossier config.json de live pose)
* L'ordinateur ne reconnait pas l'entrée NDI venant de mon ordinateur par le nom "Obs processing" nous avons passé un peu de temps à trouver quel était le problème avant de réaliser que c'était le nom du signal qu'on avait mal identifié.
* Il a fallu refaire le mapping pour le cube compte tenu que c'était une nouvelle forme.

#### Analyse et constats

Dans la journée nous sommes parvenu.e.s à projeter à la fois livePose et DrawPlanck (connecté à la planche 4). Dans le but de rouler le système entièrement sur un ordinateur, demander à l'équipe de développer un plugin shmdata qui enverrait les données de LivePose à Splash directement (comme il nous déja entre blender et Splash)

#### Apprentissages : réussites et potentialités

## Après

Nous avons finalement réussi à faire fonctionner les deux signaux (LivePose et DrawPlanck) et les projeter les sources sur des surfaces différentes à partir d'un seul projecteur.

D'une part, il a pris du temps avant de configurer chaque élément du pipeline afin de s'assurer que tout fonctionne. Ayant individuellement essayé chaque aspect la semaine du 21 février, nous cherchions à savoir quels protocoles et sources peuvent se combiner simultanément. Dans le cas de splash, processing et LivePose, c'est possible dans la mesure que nous avons 2 sources et un serveur.

Dans l'avenir, il faudrait envisager l'installation de linux sur un de nos ordinateurs afin de rendre notre usage de ses programmes autonome et mobile. Dans cette mesure, il faudrait que je remplace mon système d'exploitation par linux et que j'installe les logiciels nécessaires. Par la suite, il faudrait mettre en place les configurations de chaque logiciel respectif [(disponible dans nuage)](%5Bnuage%5D(https://nuage.en-commun.net/f/1975582).) Suite à ce premier essaie de pipeline, nous aurons donc à réfléchir aux contexts dans lesquels nous pouvons en faire usage ainsi que l'équipement conséquent à cela.

* Essayer de faire une projection dans le mini dome
* 
