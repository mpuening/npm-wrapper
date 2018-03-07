#!/bin/sh

GRADLE_NODE_PLUGIN_VERSION=1.2.0

NODE_VERSION=8.9.4
NPM_VERSION=5.6.0
NG_CLI_VERSION=1.7.2

NPMRC_REQUIRED=false
COMPANY_REGISTRY=http://your.company.com/mirror

#
# Create an NPM Wrapper (npmw) script (if one doesn't exist)
#
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
for dir in \$(find ./.gradle/nodejs -mindepth 1 -maxdepth 1 -type d) ; do
   export PATH=\$dir:\$dir/bin:\$PATH
done
npm \$*
EOF
chmod a+rx ./npmw
fi

#
# Create an Angular CLI Wrapper (ngw) script (if one doesn't exist)
#
if [ -f "ngw" ]; then
	>&2 echo "ngw already exists"
else
cat << EOF >> ngw
#!/bin/sh

#
# Script to execute ng cli using locally installed node
#
# example usage: ./ngw --version
#
for dir in \$(find ./.gradle/nodejs -mindepth 1 -maxdepth 1 -type d) ; do
   export PATH=\$dir:\$dir/bin:\$PATH
done
./node_modules/\@angular/cli/bin/ng \$*
EOF
chmod a+rx ./ngw
fi

#
# Create a gradle script to download node and npm
#
if [ -f "node.gradle" ]; then
	>&2 echo "node.gradle already exists"
else
cat << EOF >> node.gradle
buildscript {
    ext {
        nodePluginVersion = "$GRADLE_NODE_PLUGIN_VERSION"
    }
    repositories {
        mavenLocal()
        mavenCentral()
        maven { url "https://plugins.gradle.org/m2/" }
        // maven { url "$COMPANY_REGISTRY/plugins-release" }
    }
    dependencies {
        classpath "com.moowork.gradle:gradle-node-plugin:\${nodePluginVersion}"
    }
}

apply plugin: "com.moowork.node"

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
# Save backup files for package.json, package-lock.json
#
if [ -f "package.json" ]; then
	mv package.json package.json.bak
fi
if [ -f "package-lock.json" ]; then
	mv package-lock.json package-lock.json.bak
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
    "@angular/cli": "$NG_CLI_VERSION"
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
./gradlew -b node.gradle npmInstall
rm -f package.json
rm -f package-lock.json
rm -f node.gradle

#
# Optional parameter to build an angular project
#
if [[ $# -eq 1 ]]; then
  ./ngw new $1  --directory tmp
  cd tmp
  mv * .* ..
  cd ..
  rmdir tmp
  ./npmw install
fi

#
# Finally, restore backup files for package.json, package-lock.json
#
if [ -f "package.json.bak" ]; then
	mv package.json.bak package.json
fi
if [ -f "package-lock.json.bak" ]; then
	mv package-lock.json.bak package-lock.json
fi

