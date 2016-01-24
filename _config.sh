#!/bin/bash

# Substitute configuration files.

GITHUB_KEY=$(cat github.key)
if [ -f 'github.key' ]
then
  GITHUB_KEY=$(head -1 github.key)
else
  echo "Github API key, not found."
  exit
fi
echo "Github key: $GITHUB_KEY"

USERNAME='edfward'
if [ -f 'user.key' ]
then
  USERNAME=$(head -1 user.key)
fi
echo "Username: $USERNAME"

REPOS='[]'
if [ -f 'repos.key' ]
then
  REPOS=$(tr -d '\n' < repos.key)
fi
echo "Preferred repos: $REPOS"

echo -e "\n=======================\n"

sed -e "s/___ACCESS_TOKEN___/\"${GITHUB_KEY}\"/" \
    -e "s/___USERNAME___/\"${USERNAME}\"/" \
    -e "s/___REPOS___/${REPOS}/" \
    src/Config.elm.template > src/Config.elm
