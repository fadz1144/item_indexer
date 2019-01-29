#!/bin/bash
set -e

if [[ ! -d /secrets/mft ]] ; then
    echo 'ERROR! Missing secrets volume mount at /secrets/mft! Please check your kube config yml! '
    exit 3
fi

if [[ ! -r /secrets/mft/private-encryption-key.asc ]] ; then
    echo 'ERROR! Can't read /secrets/mft/private-encryption-key.asc ! Check your permissions! '
    exit 3
fi

echo "------------------------------------------------------------------------------"
echo "------------------------------ Installing GPG --------------------------------"
echo "------------------------------------------------------------------------------"

apt-get install --no-upgrade -q -y gpgv2 expect

echo "------------------------------------------------------------------------------"
echo "------------ Importing encryption key from secrets volume mount --------------"
echo "------------------------------------------------------------------------------"

# Import encryption key
gpg --import /secrets/mft/private-encryption-key.asc
expect -c "spawn gpg --edit-key <bbb-labs-automation@onekingslane.com> trust quit; send \"5\ry\r\"; expect eof"

echo "------------------------------------------------------------------------------"
echo "------------------------ Installing SSH key for mft --------------------------"
echo "------------------------------------------------------------------------------"
# Install SSH key
# Note: Currently github uses the same ssh key and it lives at /root/.ssh/id_rsa which comes in via the upstream
#   image, but i'd rather keep this decoupled in case we change one and not the other!
mkdir -p /root/.ssh && cp /secrets/mft/bbb-labs-automation /root/.ssh/mft_rsa
chmod go-rwx /root/.ssh /root/.ssh/mft_rsa

echo "------------------------------------------------------------------------------"
echo "-------------- If you can read this, everything is fine so far ---------------"
echo "------------------------------------------------------------------------------"
