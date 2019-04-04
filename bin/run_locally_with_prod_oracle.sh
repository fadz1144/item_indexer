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

# Get the PDMADMIN_URL (it has the password in it)
if [[ ! -z "$PDMADMIN_URL" ]] ; then
    echo "Detected PDMADMIN_URL from your environment:"
    echo "$PDMADMIN_URL"
elif [[ -r `secretsfile prod` ]] ; then
    eval $(fgrep 'PDMADMIN_URL=' $(secretsfile prod) | sed -e 's/^/export /')
    echo "Detected PDMADMIN_URL from a downloaded secrets file:"
    echo "$PDMADMIN_URL"
else
    secretsdown prod
    eval $(fgrep 'PDMADMIN_URL=' $(secretsfile prod) | sed -e 's/^/export /')
    echo "Downloaded the prod secrets file and fetched PDMADMIN_URL from that:"
    echo "$PDMADMIN_URL"
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

# GET A NAME FOR IMAGE
RAND_WORD=$(perl -e '$dict = "/usr/share/dict/words"; $bytes= -s $dict; open IN, $dict;seek(IN,rand($bytes-11),0);$_=<IN>;$_=<IN>;print' | tr A-Z a-z | sed s/[^a-z]//g)
II_TEMP_IMAGE_NAME=ii-ora-temp-${RAND_WORD}
II_CONTAINER_NAME=iiora_${RAND_WORD}_container


echo '**** BUILDING IMAGE! ****'
echo docker build -f Dockerfile.oracle -t ${II_TEMP_IMAGE_NAME} .
docker build -f Dockerfile.oracle -t ${II_TEMP_IMAGE_NAME} .

echo '**** RUNNING! ****'
cd $BRIDGE_DEPLOY/docker
pwd
# This command mimics what docker-compose does when running the webapps locally, configuring it for local use and allowing this one-off container to talk to your DB.
docker run --name=${II_CONTAINER_NAME} -e PDMADMIN_URL --entrypoint '/bbb/app/docker/bin/docker-entrypoint.sh' -v "$PWD/bin:/bbb/app/docker/bin:ro" -v "$PWD/config:/bbb/app/docker/config:ro"  --network=docker_default ${II_TEMP_IMAGE_NAME}:latest $COMMAND

cd -

echo 'CLEANING UP!'
docker container rm ${II_CONTAINER_NAME} && echo "Successfully removed container"
echo ""
echo "** IMPORTANT **"
echo " If you are going to be running this again today you probably want to keep the images around"
echo " (option 'N') so that the cache will make your build much faster."
echo " But they will start to take up a lot of room on your disk, so you will need to remove them"
echo " at some point. If you choose N you will be shown the command you can use later to remove"
echo " the images we left behind. If you choose Y we will delete the image we just used."
echo ""
read -n 1 -p 'Type Y to delete this docker image and N to leave the image. >' NUKEIMAGE
echo ""
if [[ "${NUKEIMAGE}" = y ]]  || [[ "${NUKEIMAGE}" = Y ]]; then
  docker image rm ${II_TEMP_IMAGE_NAME} && echo "Successfully removed image ${II_TEMP_IMAGE_NAME}" && echo "Deleted the image."
else
  echo "docker image rm ${II_TEMP_IMAGE_NAME} && echo Successfully removed image ${II_TEMP_IMAGE_NAME}" >> tmp/rm_images.sh
  echo "Make sure you run this command to clean up ALL the images when you are done:"
  echo ""
  echo " source tmp/rm_images.sh ; rm tmp/rm_images.sh"
  echo ""
fi

echo "All done!"
