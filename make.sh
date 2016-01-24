#!/bin/bash

GITHUB_KEY=$(cat github.key)

sed -i .bak "s/###ACCESS_TOKEN###/${GITHUB_KEY}/" src/GithubKey.elm

rm -rf dist/*

elm-make src/Main.elm --output=dist/index.html
cp -r assets dist/
cp style.css dist/

sed -i .bak "s/${GITHUB_KEY}/###ACCESS_TOKEN###/" src/GithubKey.elm
