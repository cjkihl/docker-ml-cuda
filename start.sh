#!/bin/bash

echo "pod started"

if [[ $PUBLIC_KEY ]]
then
    echo "starting ssh service"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

sleep infinity

# if [[ $JUPYTER_PASSWORD ]]
# then
#     echo "starting jupyter"
#     cd /
#     jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace
# else
#     sleep infinity
# fi