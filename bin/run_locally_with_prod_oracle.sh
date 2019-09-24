#!/bin/bash
source ~/.bash_profile

### What this is for ###
# Allows you to build and run your local version of item indexer against the production Oracle DB
# This lets you test your XPDM transformers against real data.

### MAKE SURE WE ARE RUNNING FROM THE RIGHT PLACE ###
### SKIP DOWN FOR THE GOOD STUFF ###

if [[ $1 = '-?' ]] || [[ $1 = '--help' ]] || [[ $1 = '-h' ]] ; then
    echo "Run me from the item_indexer directory, like this:"
    echo "You set COMMAND equal to the command you want to run, like a rake task for example"
    echo ""
    echo "COMMAND='rake -T' bin/run_locally_with_prod_oracle.sh"
    exit 2
fi


if [[ $(basename $PWD) != 'item_indexer' ]] ; then
    echo "Run me from the item_indexer directory, like this:"
    echo ""
    echo "bin/run_locally_with_prod_oracle.sh"
    exit 2
fi

# Get the PDMADMIN_USER, PDMADMIN_PASSWORD, PDMADMIN_DB
if [[ ! -z "$PDMADMIN_USER" ]] ; then
    echo "Detected PDMADMIN_USER from your environment:"
    echo PDMADMIN_USER = $PDMADMIN_USER
    echo PDMADMIN_PASSWORD = $PDMADMIN_PASSWORD
    echo PDMADMIN_DB = $PDMADMIN_DB
elif [[ -r `secretsfile prod` ]] ; then
    eval $(fgrep 'PDMADMIN_USER=' $(secretsfile prod) | sed -e 's/^/export /')
    eval $(fgrep 'PDMADMIN_PASSWORD=' $(secretsfile prod) | sed -e 's/^/export /')
    eval $(fgrep 'PDMADMIN_DB=' $(secretsfile prod) | sed -e 's/^/export /')
    echo "Detected PDMADMIN_USER from a downloaded secrets file:"
    echo PDMADMIN_USER = $PDMADMIN_USER
    echo PDMADMIN_PASSWORD = $PDMADMIN_PASSWORD
    echo PDMADMIN_DB = $PDMADMIN_DB
else
    secretsdown prod
    eval $(fgrep 'PDMADMIN_USER=' $(secretsfile prod) | sed -e 's/^/export /')
    eval $(fgrep 'PDMADMIN_PASSWORD=' $(secretsfile prod) | sed -e 's/^/export /')
    eval $(fgrep 'PDMADMIN_DB=' $(secretsfile prod) | sed -e 's/^/export /')
    echo "Downloaded the prod secrets file and fetched PDMADMIN_USER from that:"
    echo PDMADMIN_USER = $PDMADMIN_USER
    echo PDMADMIN_PASSWORD = $PDMADMIN_PASSWORD
    echo PDMADMIN_DB = $PDMADMIN_DB
fi

echo ${BRIDGE_DEPLOY:=$PWD/../bridge-deploy} >/dev/null

if [[ -d ${BRIDGE_DEPLOY}/docker/bin ]] && [[ -d ${BRIDGE_DEPLOY}/docker/config ]] ; then
    echo "bridge-deploy detected at ${BRIDGE_DEPLOY}"
else
    echo "Cannot find your bridge-deploy repo. If you continue to get this message, try setting its path to the BRIDGE_DEPLOY environment variable, like this:"
    echo 'BRIDGE_DEPLOY=/example/path/to/bridge-deploy bin/run_locally_with_prod_oracle.sh'
    exit 2
fi

# COMMAND TO RUN
echo ${COMMAND:=rake xpdm:test_connectivity} > /dev/null

if [[ $COMMAND = "bundle exec rails c" ]] ; then
    DASHIT='-i -t'
else
    DASHIT=''
fi

# GET A NAME FOR IMAGE
RAND_WORD=$(perl -e '$dict = "/usr/share/dict/words"; $bytes= -s $dict; open IN, $dict;seek(IN,rand($bytes-11),0);$_=<IN>;$_=<IN>;print' | tr A-Z a-z | sed s/[^a-z]//g)
II_TEMP_IMAGE_NAME=ii-ora-temp-${RAND_WORD}
II_CONTAINER_NAME=iiora_${RAND_WORD}_container


echo '**** BUILDING IMAGE! ****'
echo docker build -f Dockerfile.oracle -t ${II_TEMP_IMAGE_NAME} .
echo "If the next command hangs with no output for longer than a few seconds, you probably need to disconnect from VPN."
docker build -f Dockerfile.oracle -t ${II_TEMP_IMAGE_NAME} .

read -n 1 -p 'If you are not connected to VPN now, connect, then press any key >' ZZ

echo '**** RUNNING! ****'
cd $BRIDGE_DEPLOY/docker
pwd
# This command mimics what docker-compose does when running the webapps locally, configuring it for local use and allowing this one-off container to talk to your DB.
docker run $DASHIT --name=${II_CONTAINER_NAME} -e PDMADMIN_USER -e PDMADMIN_PASSWORD -e PDMADMIN_DB --entrypoint '/bbb/app/docker/bin/docker-entrypoint.sh' -v "$PWD/bin:/bbb/app/docker/bin:ro" -v "$PWD/config:/bbb/app/docker/config:ro"  --network=docker_default ${II_TEMP_IMAGE_NAME}:latest $COMMAND

cd -

echo 'CLEANING UP!'
docker container rm ${II_CONTAINER_NAME} && echo "Successfully removed container"
echo "docker image rm ${II_TEMP_IMAGE_NAME} && echo Successfully removed image ${II_TEMP_IMAGE_NAME}" >> tmp/rm_images.sh
echo "If you want to clean up all the images when you are done, run this:"
echo " source tmp/rm_images.sh ; rm tmp/rm_images.sh"
echo ""

echo "All done!"
