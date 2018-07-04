function modifyMessages {
   #saveIFS=$IFS
   #IFS=$(echo -en "ñ")
   echo $1
   cp  messages/help.ms logs/.filetmp.tmp
   sed -i -e 's/ /%20/g' logs/.filetmp.tmp
   cat ./logs/.filetmp.tmp
   for i in `cat ./logs/.filetmp.tmp`
   do
      var=$var`echo -e "$i%A0"`
   done
   echo $var
   #IFS=$saveIFS
}

modifyMessages
