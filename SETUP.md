# Documentation for the setup of npm-wrapper

There are currently three usages of npm-wrapper:

## Add NPM Wrapper scripts to an existing NPM project

Download and unzip the following URL. Copy the files (except the LICENSE) from this project into your
existing project:
```
https://github.com/mpuening/npm-wrapper/archive/master.zip
```

Run the following command without any parameters (Also see Settings section):
```
./setup.sh
```

You can now use the wrapper scripts in place of the globally installed commands.
For example:
```
./npmw start
```

## Bootstrap an Angular Project

Download and unzip the following URL. Copy the files (except the LICENSE) from this project to an empty directory.
```
https://github.com/mpuening/npm-wrapper/archive/master.zip
```

Run the following command, replacing my-app with your preferred Angular project name:
```
./setup.sh my-app
```

To start the app, run the following command:
```
./ngw serve
```

## Bootstrap a Typescript app with lite-server

Download and unzip the following URL. Copy the files (except the LICENSE) from this project to an empty directory.
```
https://github.com/mpuening/npm-wrapper/archive/master.zip
```

Run the following command
```
./setup.sh lite-server
```

To start the app, run the following command:
```
./npmw start
```

To compile your Typescript files:
```
./tscw
```

## Test Wrapper Scripts

Here are three commands to verify that your wrapper scripts are working. They should each report their version.

```
./npmw --version
```

```
./ngw --version
```

```
./tscw --version
```

## Background and History

I found myself wasting too much time trying figuring out which version
of Node and NPM to run on certain projects. Node and NPM projects are known
to be very fussy about which version you need to build them. One afternoon, I wasted
too much time trying to make a small enhancement to an NPM component. I thought it
would build with 8.9. After some searching, I found some comments that says it
was not compatible with 8.9 yet. So I backed down a version. No luck. I went
back more versions. Still no luck. I finally found someone who could build the
component... I had to go back to an ancient version of Node and use a Mac. Total nonsense.
What's more, I had to remember those settings because I had to switch back to the
latest version of NPM to work on the application to test the component change. So I vowed
that I would never again install Node and NPM globally. They have proven to me that version
compatibility is a pipe dream. 

Another widely used tool found itself in a similar situation: Gradle. The folks
that created Gradle were infamous about breaking backwards compatibility. So
embarassingly so that they solved the issue with the Gradle Wrapper. Never
again would people install Gradle globally. Developers ran the Gradle Wrapper that
would install Gradle locally within the project. When developers want to update
to newer versions of Gradle, they would update their wrapper properties. Problem
solved.

So I took that idea to build the npm-wrapper. Oddly enough, Gradle has a plugin
to install Node and NPM locally. So the setup script uses the Gradle Wrapper to 
download and install Gradle, which is then used to run a Gradle script to install
Node and NPM... all within your project directory. You can then run the wrapper
scripts to run your build and you never have to think again what version to use.

## Settings

At the top of the setup.sh script, there are these variables:

* NODE_VERSION
* NPM_VERSION
* NG_CLI_VERSION

Before running the setup.sh script you can update the values of those variables
to match your requirements.

*Note* The NPM_VERSION is not used presently because NPM is shipped with Node.
Should you which to control the version the NPM seprately from Node, you need
to uncommment the value in the Gradle script. See line ~106, where npmVersion is used.

In addition, an .npmrc file is not generated. Should you need an .npmrc file, you can set
the NPMRC_REQUIRED variable to true, and COMPANY_REGISTRY to your registry if you have one,
or just leave the value as false, and create one yourself.

If the Gradle Wrapper cannot download Gradle, edit the gradle/wrapper/gradle-wrapper.properties
and update the URL where Gradle can be downloaded.

When you need to update your version of Node that is installed locally, just update the setup.sh
script with values you want for Node, and then run this command which will clean out the old
version:
```
rm -rf .gradle && ./setup.sh && ./npmw install
```

You can double check your version of NPM with the following command:
```
./npmw --version
```

## Git Ignore Suggestions

If you copy in this npm-wrapper into project, you may want to add some entries to your
.gitignore file so as to not inadvertantly add unceccessary files to your source control
system.

Here is what you should add:

```
SETUP.md
setup.sh
gradle/
.gradle/
gradlew
gradlew.bat
ngw
npmw
tscw
```

There is also the LICENSE file I added. Consider using your own license.

## Why do I need Java?

Because of the use of the Gradle Wrapper to bootstrap the installation of everying,
you need to have Java installed. Once Node and NPM and installed localled, Java is
not used again until you wish to update to newer versions of Node or NPM.

If you can install Node and NPM, you can install Java.

## Why no README.md?

I purposely avoided having a file named README.md to not collide with the README.md
file created by the NG CLI, or a README.md file that you will likely have if you copy
this npm-wrapper project into your existing project. Hopefully, none of the other file
names I use collide with yours.

## Is Windows supported?

The scripts in this project should work using Git Bash.

## Bugs and Wish List

For bootstrapping Angular projects, I wanted the project to be generated in the current
directory. Unfortunately, this currently fails. Here is an issue:

```
https://github.com/angular/angular-cli/issues/5431
```

The setup.sh workarounds the issue by creating the project into a tmp directory
and then moving it into the current directory.
