#!/bin/bash

GITHUB_KEY=$(cat github.key)

sed -i .bak "s/###ACCESS_TOKEN###/${GITHUB_KEY}/" src/RepoList.elm

printf "\relm-reactor running, hit Ctrl-c to quit\n"

elm-reactor &
REACTOR_PID=$!

function cleanup() {
    kill $REACTOR_PID
    sed -i .bak "s/${GITHUB_KEY}/###ACCESS_TOKEN###/" src/RepoList.elm
    exit
}

trap cleanup INT

while true; do
    sleep 5
done
