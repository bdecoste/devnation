#!/bin/sh

USER="wdecoste"
REPO="kitchensink-example"
OPENSHIFT_GIT="ssh://53443ed76892df968b000048@demo-demo.example.com/~/git/demo.git/"
SOURCE_GIT="https://github.com/wdecoste/kitchensink-example.git"
APP_NAME="demo"
KEY="[OPENSHIFT]"
PULL_FILE="/mnt/extra/demo_pull.txt"

pulls=`wget -q -O - "https://api.github.com/repos/${USER}/${REPO}/pulls"`

#echo "${pulls}" 

#echo "----------------------------------------"

max=$(<${PULL_FILE})
echo "${max}"

title=`echo "${pulls}" | jsawk 'return this.title'`
echo "${title}"

if [[ ${title} == *${KEY}* ]]
then

  pull=`echo "${pulls}" | jsawk 'return this.number' | cut -d'[' -f 2 | cut -d']' -f 1`
  echo "${pull}"

  if [[ ${pull} > ${max} ]]
  then

    git clone ${OPENSHIFT_GIT} /mnt/extra/tmp/${APP_NAME}

    cd /mnt/extra/tmp/${APP_NAME}

    git remote add upstream ${SOURCE_GIT}

    sed -i 's/\/upstream\/*/\/upstream\/*\n\tfetch = +refs\/pull\/*\/head:refs\/pull\/upstream\//g' /mnt/extra/tmp/${APP_NAME}/.git/config

    git fetch upstream

    git checkout -b ${pull} pull/upstream/${pull}

    git checkout master

    git merge ${pull} -m "test"

    git push

    echo "${pull}" > "${PULL_FILE}"
  fi
fi

rm -rf /mnt/extra/tmp/${APP_NAME}



 
