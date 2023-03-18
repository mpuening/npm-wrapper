#!/bin/bash

DEFAULT_NODE_VERSION=18.15.0
DEFAULT_NPM_VERSION=9.6.2
DEFAULT_NG_CLI_VERSION=15.2.2
DEFAULT_TS_VERSION=5.0.2

NPMRC_REQUIRED=false
COMPANY_REGISTRY=http://your.company.com/mirror

#########################################
#
# Usage
#
usage() {
    echo "Usage: $0 [-N <node-version>] [-n <npm-version>] [-a <ng-version>] [-t <ts-version>] [-r]" 1>&2; exit 1;
}

#########################################
#
# Create a gradle script to download node and npm
#
download_node_and_npm() {

    cd .npm-wrapper

    if [ -f "settings.gradle" ]; then
        >&2 echo "settings.gradle already exists"
    else
        cat << EOF >> ./settings.gradle
rootProject.name = 'install-node'
EOF
    fi

    if [ -f "build.gradle" ]; then
	    >&2 echo "build.gradle already exists"
    else
        cat << EOF >> ./build.gradle
plugins {
  id "com.github.node-gradle.node" version "3.5.1"
}

node {
  // Version of node to use.
  version = "$NODE_VERSION"

  // Version of npm to use.
  // npmVersion = "$NPM_VERSION"

  // Base URL for fetching node distributions
  // distBaseUrl = "$COMPANY_REGISTRY/nodejs-dist/"

  // If true, it will download node using above parameters.
  // If false, it will try to use globally installed node.
  download = true
}
EOF
    fi

    #
    # Create a package.json file that installs Angular CLI
    #
    if [ -f "package.json" ]; then
	    >&2 echo "package.json already exists"
    else
        cat << EOF >> package.json
{
  "name": "nodeinstall",
  "version": "0.0.1",
  "devDependencies": {
    "@angular/cli": "$NG_CLI_VERSION",
    "typescript": "$TS_VERSION"
  }
}
EOF
    fi

#
# Create a .npmrc file that handles alternate registries
#
    if [ "$NPMRC_REQUIRED" = "true" ]; then
        cat << EOF >> .npmrc
registry=$COMPANY_REGISTRY/api/npm/npm-repo
phantomjs_cdnurl=$COMPANY_REGISTRY/phantomjs
chromedriver_cdnurl=$COMPANY_REGISTRY/chromedriver
operadriver_cdnurl=$COMPANY_REGISTRY/operadriver
sass_binary_site=$COMPANY_REGISTRY/node-sass
fse_binary_host_mirror=$COMPANY_REGISTRY/fsevents
sqlite3_binary_site=$COMPANY_REGISTRY/node-sqlite3
electron_mirror=$COMPANY_REGISTRY/electron/
EOF
    fi

    #
    # With files in place, run gradle wrapper to download node, and run npm install to get Angular CLI
    #
    ./gradlew npmInstall

    # Clean up
    #rm -f package.json
    #rm -f package-lock.json
    #rm -f build.gradle
    #rm -f settings.gradle

    cd ..
}

#########################################
#
# Create an NPM Wrapper (npmw) script (if one doesn't exist)
#
create_npm_wrapper() {

    if [ -f "npmw" ]; then
        >&2 echo "npmw already exists"
    else
        cat << EOF >> npmw
#!/bin/sh

#
# Script to execute npm using locally installed node
#
# example usage: ./npmw --version
#
for dir in \$(find ./.npm-wrapper/.gradle/nodejs -mindepth 1 -maxdepth 1 -type d) ; do
   export PATH=\$dir:\$dir/bin:\$PATH
done
npm \$*
EOF
        chmod a+rx ./npmw
    fi
}

#########################################
#
# Create an Angular CLI Wrapper (ngw) script (if one doesn't exist)
#
create_ng_wrapper() {

    if [ -f "ngw" ]; then
        >&2 echo "ngw already exists"
    else
        cat << EOF >> ngw
#!/bin/sh

#
# Script to execute ng cli using locally installed node
#
# example usage: ./ngw version
#
for dir in \$(find ./.npm-wrapper/.gradle/nodejs -mindepth 1 -maxdepth 1 -type d) ; do
   export PATH=\$dir:\$dir/bin:\$PATH
done
node ./.npm-wrapper/node_modules/@angular/cli/bin/ng.js \$*
EOF
        chmod a+rx ./ngw
    fi
}

#########################################
#
# Create an Typescript Compiler Wrapper (tscw) script (if one doesn't exist)
#
create_tsc_wrapper() {

    if [ -f "tscw" ]; then
        >&2 echo "tscw already exists"
    else
        cat << EOF >> tscw
#!/bin/sh

#
# Script to execute typescript compiler using locally installed node
#
# example usage: ./tscw --version
#
for dir in \$(find ./.npm-wrapper/.gradle/nodejs -mindepth 1 -maxdepth 1 -type d) ; do
   export PATH=\$dir:\$dir/bin:\$PATH
done
./.npm-wrapper/node_modules/.bin/tsc \$*
EOF
        chmod a+rx ./tscw
    fi
}

#########################################
#
# Optional parameter to build a lite-server project
#
create_liteserver_project() {

    ./npmw init --yes
    ./npmw install lite-server --save-dev
    ./npmw install typescript --save-dev
    ./tscw --init
    cat << EOF >> index.html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Typescript Playground</title>
</head>
<body>
It works! Check console for more output.
<script src="./app.js"></script>
</body>
</html>
EOF
  cat << EOF >> server.js
#!/usr/bin/env node
'use strict';

// Provide a title to the process in 'ps'
process.title = 'lite-server';

require('lite-server/lib/lite-server')();
EOF
  cat << EOF >> app.ts
console.log("It works!");
EOF
    ./tscw
}

#########################################
#
# Optional parameter to build an angular project
#
create_angular_project() {
    ./ngw new $1  --directory tmp
    cd tmp
    rm -rf node_modules
    mv * .* ..
    cd ..
    rmdir tmp
    ./npmw install
}

#########################################
#
# Process arguments
#
while getopts ":N:n:a:t:r" o; do
    case "${o}" in
        N)
            node=${OPTARG}
            ;;
        n)
            npm=${OPTARG}
            ;;
        a)
            ng=${OPTARG}
            ;;
        t)
            ts=${OPTARG}
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument."
            exit 1
            ;;
        r)
            # TODO Use Registry
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${node}" ]; then
   NODE_VERSION=$DEFAULT_NODE_VERSION 
else
   NODE_VERSION=${node} 
fi

if [ -z "${npm}" ]; then
   NPM_VERSION=$DEFAULT_NPM_VERSION 
else
   NPM_VERSION=${npm} 
fi

if [ -z "${ng}" ]; then
   NG_CLI_VERSION=$DEFAULT_NG_CLI_VERSION 
else
   NG_CLI_VERSION=${npm} 
fi

if [ -z "${ts}" ]; then
   TS_VERSION=$DEFAULT_TS_VERSION 
else
   TS_VERSION=${ts} 
fi

#
# Now call the functions to do everything
#
cd "$(dirname "$0")"
download_node_and_npm
create_npm_wrapper
create_ng_wrapper
create_tsc_wrapper

if [[ $# -eq 1  && $1 == "lite-server" ]]; then
    create_liteserver_project
fi

if [[ $# -eq 1 && $1 != "lite-server" ]]; then
    create_angular_project
fi

