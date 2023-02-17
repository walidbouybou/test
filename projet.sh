#! /bin/bash

function forme_standard()
{ 
  k=$1
  k=${k//é} 
  k=${k//è} 
  k=${k,,} 
echo "$k"
}

function group_check()
{  
gro="$1"
if grep "^$gro" /etc/group > /dev/null; then
    
else
    groupadd $gro 

fi
}


while IFS=";" read -r C1 C2 C3 C4
do 
nom=$C1 
prenom=$C2 
mp=$C3
lieu=$C4 
sep="_" 
user=$nom$sep$prenom 
#mettre user et lieu en forme standard
user=$(forme_standard $user)  
lieu=$(forme_standard $lieu)
#on teste si l'utilisateur existe
if grep "^$user" /etc/passwd > /dev/null; then
    #si l'utilisateur existe on teste si le lieu est -
    if [ $lieu="-" ]; then  
        #si oui on l'archive puis on le supprime
        date=`date`
        nom_darch=$user$sep$date 
        tar cvf /home/$lieu/$user /archives/$nom_darch.tar.gz 
        userdel -r $user
        echo "l'utilisateur $user a été archivé et supprimé"
       else  
        #sinon on verifie si son lieu a changé
        GID= `grep $user  /etc/passwd |cut -f4,4 -d:`
        gr= `grep $user  /etc/group|grep $GID |cut -f1,1 -d:`
  
            if [ "$lieu" != "$gr" ]; then  
               group_check $lieu 
               usermod -g $lieu $user
            fi 
        
     fi 

else 
#si l'utilisateur n'existe pas on teste si le lieu n'est pas -
     if [ "$lieu" != "-" ]; then   
     #si oui on le crée
               group_check $lieu 
               useradd -s /bin/bash -d /home/$lieu/$user -g $lieu $user
               echo $mp | passwd --stdin $user
               passwd -f $user
               echo "l'utilisateur $user a été crée en groupe $lieu"

fi 


done < <(tail -n +2 pa.csv)
echo "Script terminé" 
