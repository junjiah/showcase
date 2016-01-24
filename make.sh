#!/bin/bash

bash _config.sh
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

rm -rf dist/*

elm-make src/Main.elm --output=dist/index.html
cp -r assets dist/
cp style.css dist/
