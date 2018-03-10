Documentation for the setup of npm-wrapper

There are currently three usages of npm-wrapper:

Bootstrap an Angular Project
Download and unzip the following URL:
https://github.com/mpuening/npm-wrapper/archive/master.zip
Run the following command, replacing my-app with your preferred Angular project name;
./setup.sh my-app
To start the app, run the following command:
./ngw serve

Bootstrap a Typescript app using lite-server
Download and unzip the following URL:
https://github.com/mpuening/npm-wrapper/archive/master.zip
Run the following command
./setup.sh lite-server
To start the app, run the following command:
./npmw start
To compile your Typescript files:
./tscw

Add NPM Wrapper scripts to existing project
Download and unzip the following URL:
https://github.com/mpuening/npm-wrapper/archive/master.zip
Run the following command without any parameters:
./setup.sh
You can now use the wrapper scripts in place of the globally installed commands.

Test Wrapper Scripts

./npmw --version
./ngw --version
./tscw --version

Background and History

I found myself wasting too much time trying figuring out which version
of Node and NPM to run on certain projects. Node and NPM projects are known
to be very fussy about which version you need to build them. One afternoon, I wasted
too much time trying to make a small enhancement to an NPM component. I thought it
would build with 8.9. After some searching, I found some comments that says it
was not compatible with 8.9 yet. So I backed down a version. No luck. I went
back more versions. Still no luck. I finally find someone who could build the
component. I had to go back to an ancient version of Node and use a Mac. Total nonsense.
Whatsmore, I had to remember those settings because I had to switch back to the
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

So I took that idea to build the npm-wrapper. Oddly enoughly, Gradle has a plugin
to install Node and NPM locally. So the setup script uses the Gradle Wrapper to 
download and install Gradle, which is then used to run a Gradle script to install
Node and NPM... all within your project directory. You can then run the wrapper
scripts to run your build and you never have to think again what version to use.

Settings

Git Ignore Suggestions

Why do I need Java?

Bugs and Wish List

Why no README.md?
