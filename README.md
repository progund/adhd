# ADHD - Android Development Helper Doctor 

# Legal stuff

(c) Henrik Sandklef, Rikard Fröberg 2017

Licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)

# Using

Usage (from the script itself):
```
NAME
    - android development helper

SYNOPSIS
    [OPTION]

DESCRIPTION
    assists you with:
      Download files:
      * databases from an emulated device (or rooted physical device)
      * serialized files (using Juneday's ObjectCache)
      Manage (and visualise) downloaded files:
      * databases are presented in HTML
LOG
    logs to file /home/hesa/.adhd.log

OPTIONS
   --restart - restarts the adb daemon
   --list-devices,-ld        - lists available devices
   --device                  - specifies what device to manage
                                (if only one device is available this will be chosen)
   --list-database-apps,-lda - lists only apps (on the device) with a database
   --list-apps,-la           - lists all apps (on the device)
   --app [APP]               - sets program to manage
   --adb [PROG]              - sets adb program to use
   --help,-h                 - prints this help text

RETURN VALUES
     0 - success
     2 - failure
     3 - adb could not be found
    10 - no mode set
    11 - no app set

EXAMPLES
    -lda 
      lists all apps with one (or more) databases available
    --app com.android.providers.contacts 
      downloads all databases associated with com.android.providers.contacts
```

# Software that uses ADHD

We, the idiots at [juneday](http://wiki.juneday.se), use ADHD in some of our courses:
* Android: [Android the practical way](http://wiki.juneday.se/mediawiki/index.php/Android_-_the_practical_way)
* Java:  [Programming with Java](http://wiki.juneday.se/mediawiki/index.php/Programming_with_Java) and [More programming with Java](http://wiki.juneday.se/mediawiki/index.php/More_programming_with_Java)
* Misc: [Extra Lectures](http://wiki.juneday.se/mediawiki/index.php/Misc:Extra_lectures)

... all our courses have videos, texts, exercises, solutions and links
to additional reading. We aim, and have come quite a long way, at
providing intructions for teacher using our material. It's available
for free under a free license.