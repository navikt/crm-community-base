:: Opprett en scratch org
call sfdx force:org:create -f config\project-scratch-def.json --setalias %1 --durationdays %2 --setdefaultusername --json --loglevel fatal  --wait 10

:: Installer crm-platform-base
call sfdx force:package:install --package 04t2o000000OA1dAAG  -k navcrm --wait 10 --publishwait 10

:: Installer crm-platform-access-control
call sfdx force:package:install --package 04t2o000000OA22AAG  -k navcrm --wait 10 --publishwait 10

:: Dytt kildekoden til scratch org'en
call sfdx force:source:push