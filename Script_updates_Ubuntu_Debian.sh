#!/bin/bash
# Script mises à jour Ubuntu et Debian
# Le script va lister le nombre et le nom des paquets qui seront mis à jour.
# Il va ensuite les installer et pour terminer envoyer un mail récapitulatif.
# Une fois le traitement terminé ou si aucune mise à jour n'est disponible,un shutdown sera effectué. 
# Icône notification : https://www.iconfinder.com/icons/118955/available_software_update_icon
# Licence MIT ( http://choosealicense.com/licenses/mit/ )
# Auteur : Mickaël BONNARD ( https://www.mickaelbonnard.fr )

# mettre dans /etc/sudoers : nom_utilisateur ALL=NOPASSWD: /usr/bin/updates

jour=`date +%d-%m-%Y`
heure=`date +%H:%M:%S`
log=/home/utilisateur/.updates
destinataire=mail@mail.fr

if [ ! -d $log ];then

mkdir $log

fi

export DEBIAN_FRONTEND=noninteractive

notify-send -i /usr/share/pixmaps/software-update-icon.png -t 5000 "Vérification des mises à jour..." "Veuillez patienter quelques instants..."

echo -e "-------------------------------------------------------------------------------------------------" > $log/update_$jour-$heure

echo -e "\tMises à jour du $(date +%d" "%B" "%Y)" sur $HOSTNAME >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo -e "\tEtape 1 : Mise à jour de la liste des paquets disponibles" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------" >> $log/update_$jour-$heure

apt-get update >> $log/update_$jour-$heure 

nombre=$(apt-get -s full-upgrade | grep "Inst" | awk '{print $2}' | wc -l )

if [ $nombre -ne 0 ];then

notify-send -i /usr/share/pixmaps/software-update-icon.png "$nombre mise(s) à jour disponible(s)"

else

notify-send -i /usr/share/pixmaps/software-update-icon.png "Aucune mise à jour disponible..." "L'ordinateur va maintenant s'arrêter..."

rm -rf $log/update_$jour-$heure

sleep 10s && shutdown -h now

fi

echo -e "-------------------------------------------------------------------------------------------------" >> $log/update_$jour-$heure

echo -e "\tEtape 2 : Liste des mises à jours disponibles"  >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

liste_correctifs=$(apt-get -s full-upgrade | grep "Inst" | awk '{print $2}')

for i in $liste_correctifs ;do

versions=$(apt-cache policy $i | head -3)

echo -e "$versions" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

done

echo -e "\tNombre total de mises à jour disponibles : $nombre" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo -e "\tEtape 3 : Installation des mises à jour" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

> /var/log/dpkg.log

apt-get full-upgrade -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-confdef" 2> $log/erreur.log

nombre_ok=$(grep "status installed" /var/log/dpkg.log | awk {'print $5'} | awk -F : {'print $1'} | wc -l)

case $? in

0) echo "Les paquets suivants ont été mis à jour ou installés :" >> $log/update_$jour-$heure

echo "" >> $log/update_$jour-$heure

grep "status installed" /var/log/dpkg.log | awk {'print $5" "$6" "$7'} >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo -e "\tNombre total de paquets mis à jour ou installés : $nombre_ok" >> $log/update_$jour-$heure;;

1) cat $log/erreur.log >> $log/update_$jour-$heure;;

esac

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo -e "\tEtape 4 : Nettoyage" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

apt-get clean && apt-get autoclean && apt-get autoremove -y >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

echo "Fin du traitement le $(date +%d-%B-%Y) à $(date +%H:%M:%S)" >> $log/update_$jour-$heure

echo -e "-------------------------------------------------------------------------------------------------"  >> $log/update_$jour-$heure

cat $log/update_$jour-$heure | mail -s "Mises à jour du $(date +%d" "%B" "%Y) sur $HOSTNAME" $destinataire

export DEBIAN_FRONTEND=dialog

find $log -type f -mtime +15 -exec rm -rf {} \;

sleep 10s && shutdown -h now
