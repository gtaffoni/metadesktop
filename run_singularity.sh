#!/bin/bash
# 
# This Script allows to execute the conatiner using singularity 
# in an isolated enviroment
# 
# author <giuliano.taffoni@inaf.it>
#

export CONTAINER_NAME=morgan1971/kasm_desktop
export CONTAINER_VERSION=0.0.5
export BASE_PORT= 
if [ 'XXX'$1 = 'XXX' ]; then
    COMMAND=
else
    COMMAND=$1
fi

export BASE_PORT=
export SINGULARITY_VNC_AUTH=True
export SINGULARITY_NOHTTPS=true
export SINGULARITYENV_BASE_PORT=$BASE_PORT
export SINGULARITYENV_AUTH_USER=testuser
export SINGULARITYENV_AUTH_PASS=testpass

HOMEDIR=`mktemp -d -t singularity_XXXXXXX`
mkdir $HOMEDIR/tmp
mkdir $HOMEDIR/home
singularity run  --pid --no-home --home=/home/metauser --workdir ${HOMEDIR}/tmp -B${HOMEDIR}:/home/ -B/beegfs:/beegfs --containall --cleanenv docker://${CONTAINER_NAME}:${CONTAINER_VERSION} $COMMAND
rm -fr ${HOMEDIR}

