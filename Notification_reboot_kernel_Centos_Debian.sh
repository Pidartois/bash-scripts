#!/bin/bash
# Script notification redémarrage après un update de kernel sur Centos et Debian.
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# Variables
sujet="Redémarrage nécessaire sur $HOSTNAME"
jour=$(date +'%d %B %Y')
nouveau=$(ls -t /boot/vmlinuz-* | sed "s/\/boot\/vmlinuz-//g" | head -n1)
actuel=$(uname -r)
destinataire="mail@admin.com"
expediteur="notifications_updates@admin.com"

kernel(){
echo -e "------------------------------------------------------------------------------------------------------\n"
echo -e "\t$jour : Redémarrage nécessaire sur $HOSTNAME\n"
echo -e "------------------------------------------------------------------------------------------------------\n"
echo -e "Le kernel a été mis à jour, un redémarrage est nécessaire.\n\nkernel actuel : $actuel\nKernel installé : $nouveau\n"
}

if [ "$nouveau" != "$actuel" ];then

    kernel | mail -s "$sujet" -r "$expediteur" "$destinataire"

    else

  exit

fi
