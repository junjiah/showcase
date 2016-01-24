#!/bin/bash

bash _config.sh

rm -rf dist/*

elm-make src/Main.elm --output=dist/index.html
cp -r assets dist/
cp style.css dist/
