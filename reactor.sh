#!/bin/bash

bash _config.sh

printf "\relm-reactor running, hit Ctrl-c to quit\n"

elm-reactor &
REACTOR_PID=$!

function cleanup() {
    kill $REACTOR_PID
    # TODO: May have other works.
    exit
}

trap cleanup INT

while true; do
    sleep 5
done
