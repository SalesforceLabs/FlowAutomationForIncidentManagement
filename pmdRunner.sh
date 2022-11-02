#!/bin/bash

PMDFILENAME="pmd-bin-6.50.0"
if [ ! -d "$PMDFILENAME" ]; then
  echo "You do not have PMD ready, downloading it."
  curl -L -O https://github.com/pmd/pmd/releases/download/pmd_releases%2F6.50.0/pmd-bin-6.50.0.zip
  unzip $PMDFILENAME.zip
  rm $PMDFILENAME.zip
fi
$PMDFILENAME/bin/run.sh pmd -d aim-base -R ruleSet.xml
$PMDFILENAME/bin/run.sh pmd -d aim-bot -R ruleSet.xml
$PMDFILENAME/bin/run.sh pmd -d aim-messaging -R ruleSet.xml
$PMDFILENAME/bin/run.sh pmd -d aim-slack -R ruleSet.xml