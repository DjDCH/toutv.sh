#! /bin/sh
#
# toutv.sh
#
# Exemple d'URL valide
# http://www.tou.tv/sherlock/S02E02


INPUT=$*

if [[ -z $INPUT ]]
	then
	echo "Vous devez entrer un URL comme argument (e.g: toutv.sh http://www.tou.tv/virginie/SE23EP01)"
	exit 1

elif [ "$INPUT" = "http://www.tou.tv/"*]
	then
		#Récupération des infos qu'on devra donner à rtmpdump
		FILENAME="`echo $INPUT | cut -f 4,5 -d\/ | sed 's/\//\_/'`" # J'aime pas avoir à renommer mes fichiers moi-même!

		PID=`wget $INPUT -q -O - | grep toutv.mediaData | tr ',' '\n' | grep PID | cut -f 4 -d \"`
		URL=`wget http://release.theplatform.com/content.select?pid=$PID -q -O - | sed -e 's/>/>\n/g' -e 's/<\//\n<\//g' | grep "rtmp://medias-flash.tou.tv/ondemand/?"`


		# Vérification et installation de rtmpdump
		RTMPDUMP=`command -v rtmpdump`
		if [$?]
			then
				echo "RTMPdump est installé, le programme peut continuer."
			else
				echo "RTMPdump est introuvable"
				#echo "Ce programme va maintenant être installé"
				#if [command -v apt-get] then; sudo apt-get install -y rtmpdump
				#	elif [command -v yum] then; sudo yum install -y rtmpdump
				#	elif [command -v pacman] then; sudo pacman -S noconfirm rtmpdump
				echo "Vous devrez l'installer vous-même avant de procéder.";exit 2
				#fi
		fi



		#RTMP="`echo $URL | sed 's/<break>.*$//'`"
		#APP="`echo ${RTMP} | sed 's/^.*\/\(ondemand\/\?\)/\1/'`"
		#PLAYPATH="`echo $URL | sed 's/^.*<break>//'`"
		#AUTH="`echo $URL | sed 's/^.*auth=//;s/&.*$//'`"

		# Rtmpdump en action!
		RTMP="`echo $URL | sed 's/\;break\&gt\;.*$//'`"
		APP="`echo ${RTMP} | sed 's/^.*\/\(ondemand\/\?\)/\1/'`"
		PLAYPATH="`echo $URL | sed 's/^.*\;break\&gt\;//'`"
		AUTH="`echo $URL | sed 's/^.*auth=//;s/\;.*$//'`"

		set -x
		exec ${RTMPDUMP} --app ${APP} \
		   --flashVer 'WIN 10,0,22,87' \
		   --swfVfy 'http://static.tou.tv/lib/ThePlatform/4.1.2/swf/flvPlayer.swf' \
		   --auth "${AUTH}" \
		   --tcUrl "${RTMP}" --rtmp "${RTMP}" \
		   --playpath "${PLAYPATH}" \
		   -o $FILENAME.flv --verbose
		exit 0


else
	echo "Ce script ne fonctionne qu'avec tou.tv. Assurez-vous que votre URL commence par \"http://www.tou.tv\""
	exit 1
fi



#Ne pas tenir compte de ce qui se trouve en dessous de cette ligne à moins que la SRC ne décide de changer à nouveau son système.
#-----------------------------------------------------------------

#SELECTIONER CE QUI SE TROUVE ENTRE "auth=" ET "&"
#sed 's/^.*auth=//;s/&.*$//'`"

#rtmp://medias-flash.tou.tv/ondemand/?	auth=daEaaaMcRbKc9dmdIbNcWbRbdc4cHdwbDdn-bpUsHi-cOW-2qvAxkIqyDx&amp	;	aifp=v0001&amp	;	slist=004/MP4/s/2012-05-11_19_00_00_sherlock_0005_1200;004/MP4/s/2012-05-11_19_00_00_sherlock_0005_500;004/MP4/s/2012-05-11_19_00_00_sherlock_0005_800&lt	;break&gt;	mp4:004/MP4/s/2012-05-11_19_00_00_sherlock_0005_1200.mp4
#rtmp://medias-flash.tou.tv/ondemand/?	auth=CLEF_D_AUTHENTIFICATION						&	aifp=v0001	&	slist=001/MOV/HR/CONTENU_hr;001/MOV/MR/CONTENU_mr;001/MOV/BR/CONTENU_br												<break>		mp4:001/MOV/HR/CONTENU.mov
