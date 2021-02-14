#!/bin/sh

# Create ssh "client" key
# http://stackoverflow.com/a/20977657

KEY_OUTDIR=/etc/ssh
USER_HOME=/home/docker

KEYGEN=/usr/bin/ssh-keygen
KEYFILE=${KEY_OUTDIR}/ssh_host_rsa_key

if [ ! -f $KEYFILE ]; then
    $KEYGEN -q -t rsa -N "" -f $KEYFILE
    ls ${KEY_OUTDIR}
    cp $KEYFILE ${USER_HOME}/.ssh/
    cat $KEYFILE.pub >> ${USER_HOME}/.ssh/authorized_keys
fi

echo "== Use this private key to log in with the user docker=="
cat $KEYFILE
