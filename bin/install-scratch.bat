:: Opprett en scratch org
call sfdx force:org:create -f config\project-scratch-def.json --setalias %1 --durationdays %2 --setdefaultusername --json --loglevel fatal  --wait 10

:: Installer crm-platform-base
call sfdx force:package:install --package 04t7U0000000Rs7QAE -r -k %3 --wait 10 --publishwait 10

:: Installer crm-platform-access-control
call sfdx force:package:install --package 04t7U0000004e8tQAA -r -k %3 --wait 10 --publishwait 10

:: Dytt kildekoden til scratch org'en
call sfdx force:source:push
