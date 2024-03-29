#!/bin/bash
# Script qui va permettre d'optimiser vos images ( .png, .jpeg et .jpg ).
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# Variables
repertoire='/home/mickael/photos'
centos='/etc/centos-release'

# On teste la présence du fichier /etc/centos-release.

if [ -f $centos ]

  then

# On teste si jpegoptim optipng sont installés.

which jpegoptim optipng &>/dev/null

# Si ce n’est pas le cas, alors on installe les 2 paquets.

if [ $? -ne 0 ]

    then

yum -y install jpegoptim optipng 2>/dev/null

  else

# Si on est sur une distribution Debian, on teste si jpegoptim optipng sont installés.

which jpegoptim optipng &>/dev/null

# Si ce n’est pas le cas, alors on installe les 2 paquets.

if [ $? -ne 0 ]

    then

apt -y install jpegoptim optipng 2>/dev/null

  fi

    fi

  fi

clear

# On optimise les photos.

# https://www.systutorials.com/docs/linux/man/1-jpegoptim/

find "${repertoire}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec jpegoptim -P -t --all-progressive --strip-all {} \;

# https://linux.die.net/man/1/optipng

find "${repertoire}" -iname "*.png" -exec optipng -o7 -preserve -strip all {} \;
