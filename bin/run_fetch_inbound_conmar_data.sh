#!/usr/bin/env bash

bin/install_and_configure_decryption.sh

if [[ -z ${MFT_SFTP_PRIV_KEY} ]] ; then
    export MFT_SFTP_PRIV_KEY='/root/.ssh/mft_rsa'
fi
bundle exec rake sftp:get_contribution_margin_from_sftp
