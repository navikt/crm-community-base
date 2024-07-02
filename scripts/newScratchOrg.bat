echo "Oppretter scratch org"
call sf org create scratch --definition-file config\project-scratch-def.json --alias %1 --duration-days %2 --set-default --json --wait 30

echo "Installer crm-platform-base v0.169"
call sf package install --package 04t7U000000TqIuQAK --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Installer crm-platform-access-control v0.101"
call sf package install --package 04t7U000000TpqbQAC --no-prompt --installation-key %3 --wait 30 --publish-wait 30

echo "Dytter kildekoden til scratch org'en"
call sf project deploy start

echo "Ferdig"
