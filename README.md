# ADHD - Android Development Helper Doctor 

# Legal stuff

(c) Henrik Sandklef, Rikard Fröberg 2017

Licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)

# Using

Usage (from the script itself):
```
NAME
   adhd.sh - android development helper doctor

SYNOPSIS
   adhd.sh [OPTION] APP MODE

DESCRIPTION
   adhd.sh assists you with:
      Download files:
      * databases from an emulated device (or rooted physical device)
      * serialized files (using Juneday's ObjectCache)
      Manage (and visualise) downloaded files:
      * databases are presented in HTML
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

APP
   the program to manage

MODE
   serializable - downloads files as serialized by ObjectCache*
   database - downloads database files and creates txt file and html pages from each

ENVIRONMENT VARIABLES
   APP - the Android app to manage
   MODE - database, serialized, ...  
   ADB - Android debugger bridge tool
   ADEV - Android device to manage

RETURN VALUES
    0 - success
    2 - failure
    3 - adb could not be found
   10 - no mode set
   11 - no app set

EXAMPLES

   adhd.sh -lda 
      lists all apps with one (or more) databases available

   adhd.sh -ld 
      lists all devices available

   adhd.sh  com.android.providers.contacts database
      downloads all databases associated with com.android.providers.contacts

   adhd.sh  se.juneday.systemet serialized
      downloads all files with serialized data for se.juneday.systemet

   adhd.sh  --device emulator-5554 se.juneday.systemet serialized
      downloads all files with serialized data for se.juneday.systemet on devce emulator-5554
```

# Requirements

## ObjectCache

ADHD can download serialized files from the Android devices. We have
only tested copying serialized files as created by [ObjectCache](https://github.com/progund/java-extra-lectures/tree/master/caching) which is also developed by your not so very humble idiots at [juneday](http://wiki.juneday.se).

# Software that uses ADHD

We, the idiots at [juneday](http://wiki.juneday.se), use ADHD in some of our courses:
* Android: [Android the practical way](http://wiki.juneday.se/mediawiki/index.php/Android_-_the_practical_way)
* Java:  [Programming with Java](http://wiki.juneday.se/mediawiki/index.php/Programming_with_Java) and [More programming with Java](http://wiki.juneday.se/mediawiki/index.php/More_programming_with_Java)
* Misc: [Extra Lectures](http://wiki.juneday.se/mediawiki/index.php/Misc:Extra_lectures)

... all our courses have videos, texts, exercises, solutions and links
to additional reading. We aim, and have come quite a long way, at
providing intructions for teacher using our material. It's available
for free under a free license.