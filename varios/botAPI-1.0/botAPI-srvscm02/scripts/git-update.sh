#!/bin/bash

PWD=$(pwd)
PATH_REPO_BRANCH=$(echo ${PWD##*/})
# git checkout -f ${PATH_REPO_BRANCH}
# if [ "$PATH_REPO_BRANCH" == "AcseleV13.8-Asesuisa-20160722" ];then
if [ "$PATH_REPO_BRANCH" == "AcseleV13.8-Asesuisa-develop" ];then
	git checkout develop 
else
	git checkout -f ${PATH_REPO_BRANCH}
fi
git pull origin $PATH_REPO_BRANCH
if [ ! $? -eq 0 ] ; then
   exit 1
fi

git branch -D temp	
echo "El PWD: ${PWD}"
echo "La ruta del Branch a actualizar: ${PATH_REPO_BRANCH}"

         stty -echo
         export CLASSPATH='/home/oracle/scm/Git/Generate-UpdateVersionNumberTool-jar/dist/lib/*'
         #export CLASSPATH='.:lib/*'
		 export PATH_EXEC_GIT="/usr/local/git/bin"
		 export PATH_BUILD_NUMBER="/home/oracle/scm/Git/Generate-UpdateVersionNumberTool-jar/build-git.number"
		 #export PATH_REPOSITORY=/home/scm/svn/workspace/git/AcseleV13.8-ALFA
		 export PATH_REPOSITORY="/home/scm/svn/workspace/"${PATH_REPO_BRANCH}
		 export GIT_BRANCH=auto
		 #export GIT_ACTION=count
		 export GIT_ACTION=checkout
		 #export GIT_ACTION=showid
		 #export SVN_VERSION_NUMBER=0
         export OPTION_PARAMETER=$1
		 
		 
		 stty echo

         echo 'Iniciando UpdateVersionNumberTool'
		 echo 'Option_Parameter = ' $OPTION_PARAMETER
		 
		 if [ "$OPTION_PARAMETER" == "-h" ];then
		     echo '  args:  0 path executable git    '
             echo '         1 path build number      '
             echo '         2 path repository local  '
		     echo '         3 branch                 '
		     echo '         4 action                 '
             echo '         5 numVersion             '
             echo '                                  ' 
             echo '  java UpdateVersionNumberTool pathExecutableGit pathbuildNumber pathToRepositoryLocal branch action numversion '
             echo '  examples: '
             echo '            '
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e auto count (Obtain count default branch number repository)'
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e auto showid 10 (Show ShaIDMD5 GIT Correspondient to Revision Number Version 10 Equivalent in default branch number repository) '
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e auto checkout 10 (Checkout ShaIDMD5 GIT Correspondient to Revision Number Version 10 Equivalent in default branch number repository) '
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e all count (Obtaint count all versions number repository)'
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e master count (Obtain count branch versions numbers repository)'
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e master defaultcheck (Checkout to branch master repository default last HEAD)'
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e develop defaultcheck (Checkout to branch develop repository default last HEAD)'
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e master showid 10  (Show ShaIDMD5 GIT Correspondient to Revision Number Version 10 Equivalent)'
             echo 'java UpdateVersionNumberTool /usr/bin /home/Consisint/Acsele/Versions/Generate-UpdateVersionNumberTool/build-git.number /home/Consisint/Acsele/Versions/AcseleGit/Acsel-e master checkout 10 (Checkout ShaIDMD5 GIT Correspondient to Revision Number Version 10 Equivalent)'
		 fi    		   
		 
		 
		 if [ "$OPTION_PARAMETER" == "-r" ];then
		     export SVN_VERSION_NUMBER=$2
		     if [ $SVN_VERSION_NUMBER -eq 0 ];then
                     	java -Xms1024m -Xmx1024m -Dfile.encoding=utf8 -cp $CLASSPATH -jar /home/oracle/scm/Git/Generate-UpdateVersionNumberTool-jar/dist/updateVersionNumberTool.jar "$PATH_EXEC_GIT" "$PATH_BUILD_NUMBER" "$PATH_REPOSITORY" $GIT_BRANCH $GIT_ACTION
		     else
			echo "No es igual a 0 #####" 
                	java -Xms1024m -Xmx1024m -Dfile.encoding=utf8 -cp $CLASSPATH -jar /home/oracle/scm/Git/Generate-UpdateVersionNumberTool-jar/dist/updateVersionNumberTool.jar "$PATH_EXEC_GIT" "$PATH_BUILD_NUMBER" "$PATH_REPOSITORY" $GIT_BRANCH $GIT_ACTION $SVN_VERSION_NUMBER
             	     fi
		 else
			export SVN_VERSION_NUMBER=$2
			if [ "$OPTION_PARAMETER" == "-hash" ];then		
				/bin/git checkout ${SVN_VERSION_NUMBER}
		 		#java -Xms1024m -Xmx1024m -Dfile.encoding=utf8 -cp $CLASSPATH -jar /home/oracle/scm/Git/Generate-UpdateVersionNumberTool-jar/dist/updateVersionNumberTool.jar "$PATH_EXEC_GIT" "$PATH_BUILD_NUMBER" "$PATH_REPOSITORY" $GIT_BRANCH $GIT_ACTION 
			fi
		 fi
	git branch temp		 
	git checkout temp
        echo -n 'Finalizado UpdateVersionNumberTool'
	echo -e "\n"	
        exit 0

       
