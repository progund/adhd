# ADHD - Android Development Helper Doctor 

ADHD can retrieve database files, serialized files and 'normal' file
from an Android device (with root access), The retrieved files can be
converted to txt and/or html format.

# Legal stuff

* (c) Henrik Sandklef, Rikard Fröberg 2017

* Licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)

* This software comes with no warranty.

We applogise of we offend anyone with the name. We think it's funny.

# Required tools

## ObjectCache

If you want to retrieve and convert (de-serialize) serialized files
created on the device using ObjectCache you, of course, need ObjectCache.

### Point out ObjectCache yourself

With the option ```-ocd dir``` you can specify the location of the
ObjectCache jar file. Let's say you have ObjectCache installed in the
directory ```${HOME}/libs/object-cache/object-cache-01.jar``` then you
should start adhd like this:

~~~
  $0 -ocd ${HOME}/libs/object-cache/object-cache-01.jar .... etc
~~~

### Let adhd set up ObjectCache

ADHD can download serialized files from the Android devices. We have
only tested copying serialized files as created by
[ObjectCache](https://github.com/progund/java-extra-lectures/tree/master/caching)
which is also developed by your not so very humble idiots at
[juneday.se](http://wiki.juneday.se).

ADHD will download ObjectCache to the current directory if you run adhd.sh like this:
```adhd.sh --install-object-cache```

## SQLite

If you want to retrieve database files and present the data in txt or
html format you need SQLite.

You need to have [SQLite](https://www.sqlite.org/) (version 3)
installed. Ok, you can download the SQLite database files from your
Android device without SQLite. No problems. But if you either want
them converted into txt and html or open them up using SQLite we
suggest you install and make sure sqlite3 can be found using your PATH
variable.

## ADB - Android Debugger Bridge

We rely totally on
[adb](https://developer.android.com/studio/command-line/adb.html). It
come with Android Studio so you need to know where to find the program.

## Misc other softwares

* bash - check out our [wiki pages](http://wiki.juneday.se/mediawiki/index.php/Bash) for more information on that. Once you've followed the instructions there you have tools such as sed, awk and grep which are needed. If you have no idea what we're talking about, you really (yes, REALLY!) need to check bash and its friends out. We suggest you attend the course: [Bash introduction](http://wiki.juneday.se/mediawiki/index.php/Bash-introduction) and [Bash programming](http://wiki.juneday.se/mediawiki/index.php/Bash_Programming). 

# Workflow

## Preparations

Edit the script and make sure:

* ```ADB``` is set to point out the path to your adb program (shipped with Android Studio)

* Connect a rooted device or an emulated device where you have ```su``` rights.

* Make sure adb can find your device: ```adhd.sh -ld``` - make sure
  your device is listed. If your device is one of many you need to
  specify which device in the examples below using the option
  ```--device dev```.

* Make sure adb can find your app:
  ```adhd.sh --la``` - make sure your app is listed

* If you want to retrieve and convert serialized files you need to point out the location of the classes that were serialized. Point out these classes with the option ```-ocd dir``` (where dir is the directory where your classes are located).

## Download database files

Let's assume you want to download database files from ```com.google.android.youtube```

Retrieve and convert database files with the following command:
```adhd.sh com.google.android.youtube database```

You should now have the database itself, a text version of the content of the database and an html version of the content of the database. These are located in the following folder: ```adhd/apps/com.google.android.youtube/```

## Download serialized files

Let's assume you want to download and convert serialized files from an app called ```se.juneday.gitrepoviewer```
* Retrieve and convert serialized files
```adhd.sh -ocd ~/AndroidStudioProject/GitRepoViewer/app/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes/  se.juneday.gitrepoviewer serialized```

You should now have the serialized file itself and a text version of it. These are located in the following folder: ```adhd/apps/se.juneday.gitrepoviewer/```


# Manual

Usage (from the script itself):
```
NAME
   adhd.sh - android development helper doctor

SYNOPSIS
   adhd.sh [OPTION] APP MODE

DESCRIPTION
   adhd.sh
      List android devices

      List installed application (with database files and/or ObjectCache files)

      Download and extract information from files on an Android Device:
      * databases from an emulated device (or rooted physical device)
      * serialized files (using Juneday's ObjectCache)
      * files in your app's folder
      Manage (and visualise) downloaded files:
      * databases are presented in HTML and TXT
      * serialized are presented in TXT
LOG
   adhd.sh logs to file $LOG_FILE

OPTIONS
   --restart-daemon
        restarts the adb daemon and exits
   --list-devices,-ld
        lists running devices
   --list-available-devices, -lad
        lists available devices
   --device
        specifies what device to manage
        (if only one device is available this will be chosen)
   --list-database-apps,-lda
        lists only apps (on the device) with a database
   --list-serialized-apps,-lsa
        list only apps (on the device) with serialized files
   -lsd
        list only apps (on the device) with serialized files AND databases
   --list-apps,-la
        lists all apps (on the device)
   --adb PROG
        sets adb program to PROG
   --help,-h
        prints this help text
   --verify-software, -vs
        verify required softwares
   --objectcache-dir, -ocd
        directory where the ObjectCache class are located
   --classpath, -cp
        CLASSPATH for Java programs
   --debug, -d
        verbose printing enabled

APP
   the program (on the Android Device) to manage

MODE
   serialized - downloads files as serialized by ObjectCache and generates TXT files*
   database - downloads database files and creates TXT file and HTML pages from each
   files - all your app's files (as is)
   all - all of the above

ENVIRONMENT VARIABLES
   Set any of the below environment variables to alter the settings:
   APP 
   - the Android app to manage. Default value: No default
   MODE
    - database, serialized, ... Default value: No default
   ADB
    - Android debugger bridge tool. Default: ~/Android/Sdk/platform-tools/adb
   ADEV
    - Android device to manage. Default value: No default
   OC_PATH
    - Directory where the ObjectCache class are located
   CLASSPATH
    - CLASSPATH for java programs

RETURN VALUES
    0 - success
    2 - failure
    3 - adb could not be found
    4 - slite and/or ObjectCache could not be found
   10 - no mode set
   11 - no app set

EXAMPLES

   adhd.sh -lda 
      lists all apps with one (or more) databases available

   adhd.sh -ld 
      lists all devices available

   adhd.sh  com.android.providers.contacts database
      downloads all databases associated with
      com.android.providers.contacts and creates TXT/HTML

   adhd.sh  se.juneday.systemet serialized
      downloads all files with serialized data for 
      se.juneday.systemet and creates TXT

   adhd.sh  --device emulator-5554 se.juneday.systemet serialized
      downloads all files with serialized data for 
      se.juneday.systemet on devce emulator-5554 and creates TXT

   adhd.sh  -ocd ~/opt/ObjectCache --device emulator-5554 \
   se.juneday.systemet serialized
      as above but using ObjectCache as found in
      dir ~/opt/ObjectCache

   adhd.sh  -ocd ~/opt/ObjectCache  \
   -cp ~/AndroidStudioProjects/BlaBlaBla --device emulator-5554 \
   se.juneday.systemet serialized
      as above but setting CLASSPATH to 
      ~/AndroidStudioProjects/BlaBlaBla to find your own classes

```
