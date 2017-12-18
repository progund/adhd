# ADHD - Android Development Helper Doctor 

# Legal stuff

(c) Henrik Sandklef, Rikard Fröberg 2017

Licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)

# Disclaimer

This software comes with no warranty.

We applogise of we offend anyone with the name. We think it's funny.

# Using

Usage (from the script itself):
```
NAME
   adhd.sh - android development helper doctor

SYNOPSIS
   adhd.sh [OPTION] APP MODE

DESCRIPTION
   adhd.sh assists you with:
      Download and reads out information from files on an Android Device:
      * databases from an emulated device (or rooted physical device)
      * serialized files (using Juneday's ObjectCache)
      Manage (and visualise) downloaded files:
      * databases are presented in HTML and TXT
      * serialized are presented in TXT
LOG
   adhd.sh logs to file $LOG_FILE (currently set to /home/hesa/.adhd.log)

OPTIONS
   --restart - restarts the adb daemon
   --list-devices,-ld        - lists available devices
   --device                  - specifies what device to manage
                                (if only one device is available this will be chosen)
   --list-database-apps,-lda - lists only apps (on the device) with a database
   --list-serialized-apps,-lsa - list only apps (on the device) with serialized files
   --list-apps,-la           - lists all apps (on the device)
   --adb [PROG]              - sets adb program to use
   --help,-h                 - prints this help text
   --verify-software, -vs    - verify required softwares
   --objectcache-dir, -ocd   - path to ObjectCache classes
   --classpath, -cp   - CLASSPATH for Java programs

APP
   the program (on the Android Device) to manage

MODE
   serializable - downloads files as serialized by ObjectCache and generates TXT files*
   database - downloads database files and creates TXT file and HTML pages from each
   all - all of the above

ENVIRONMENT VARIABLES
   APP - the Android app to manage
   MODE - database, serialized, ...  
   ADB - Android debugger bridge tool
   ADEV - Android device to manage
   OC_PATH - ObjectCache directory
   CLASSPATH - CLASSPATH for java programs

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
      downloads all databases associated with com.android.providers.contacts and creates TXT/HTML

   adhd.sh  se.juneday.systemet serialized
      downloads all files with serialized data for se.juneday.systemet and creates TXT

   adhd.sh  --device emulator-5554 se.juneday.systemet serialized
      downloads all files with serialized data for se.juneday.systemet on devce emulator-5554 and creates TXT

   adhd.sh  -ocd ~/opt/ObjectCache --device emulator-5554 se.juneday.systemet serialized
      as above but using ObjectCache as found in dir ~/opt/ObjectCache

   adhd.sh  -ocd ~/opt/ObjectCache -cp ~/AndroidStudioProjects/BlaBlaBla --device emulator-5554 se.juneday.systemet serialized
      as above but setting CLASSPATH to ~/AndroidStudioProjects/BlaBlaBla to find your own classes

```

# Requirements

## ObjectCache

ADHD can download serialized files from the Android devices. We have
only tested copying serialized files as created by [ObjectCache](https://github.com/progund/java-extra-lectures/tree/master/caching) which is also developed by your not so very humble idiots at (juneday)[http://wiki.juneday.se].

## SQLite

You need to have [SQLite](https://www.sqlite.org/) (version 3) installed. Ok, you can download the SQLite database files from your Android device without SQLite. No problems. But if you either want them converted into txt and html or open them up using SQLite we suggest you install and make sure sqlite3 can be found using your PATH variable.

## ADB - Android Debugger Bridge

We rely totally on [adb](https://developer.android.com/studio/command-line/adb.html). Install it now.

## Misc other softwares

* bash - check out our [wiki pages](http://wiki.juneday.se/mediawiki/index.php/Bash) for more information on that. Once you've followed the instructions there you have tools such as sed, awk and grep which are needed. If you have no idea what we're talking about, you really (yes, REALLY!) need to check bash and its friends out. We suggest you attend the course: [Bash introduction](http://wiki.juneday.se/mediawiki/index.php/Bash-introduction) and [Bash programming](http://wiki.juneday.se/mediawiki/index.php/Bash_Programming). 

# Software that uses ADHD

We, the idiots at [juneday](http://wiki.juneday.se), use ADHD in some of our courses:
* Android: [Android the practical way](http://wiki.juneday.se/mediawiki/index.php/Android_-_the_practical_way)
* Java:  [Programming with Java](http://wiki.juneday.se/mediawiki/index.php/Programming_with_Java) and [More programming with Java](http://wiki.juneday.se/mediawiki/index.php/More_programming_with_Java)
* Misc: [Extra Lectures](http://wiki.juneday.se/mediawiki/index.php/Misc:Extra_lectures)

... all our courses have videos, texts, exercises, solutions and links
to additional reading. We aim, and have come quite a long way, at
providing intructions for teacher using our material. It's available
for free under a free license.