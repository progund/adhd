#!/bin/bash

###########################################
#
# Android Development Helper Doctor - ADHD
#
# (c) 2017, 2018
# Henrik Sandklef & Rikard Fröberg
#
# License GPLv3
#
###########################################


#
#
# User tweakable variables
#
#
if [ "$ADB" = "" ]
then
    ADB=~/Android/Sdk/platform-tools/adb
fi
LOG_FILE=~/.adhd.log

PATHSEP=":"
if [[ $OS == "Windows_NT" ]] || [[ $OSTYPE == "cygwin" ]]
then
    PATHSEP=";"
fi

# Use ADB to find path to emulator
EMU=$(dirname $ADB)/../emulator/emulator

verify_sw()
{
    RET=0
    echo -n "Verifying adb: "
    # Check adb
    $ADB help >/dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo "*** ERROR ***"
        echo "adb not found, tried $ADB"
        exit 3
    fi
    echo "OK"
    
    echo
    echo -n "Verifying SQLite: "
    # Check SQLite
    echo ".quit" | $SQLITE  >/dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo 
        echo "*** WARNING ***"
        echo "$SQLITE not found. You will not be able to read databases"
        echo 
        RET=4
    else
        echo "OK"
    fi

#    setup_oc
    echo
    echo -n "Verifying ObjectCache: "
    # Check ObjectCache
    CMD="java -cp $OC_PATH${PATHSEP}$CLASSPATH se.juneday.ObjectCacheReader --test"
 #   echo $CMD
    $CMD 2>/dev/null >/dev/null
    if [ $? -ne 0 ]
    then
        echo 
        echo "*** WARNING ***"
        echo "ObjectCache not found. You will not be able to read Serialized files."
        echo "You can either:"
        echo "1. set the path to the ObjectCache dir, do something like the below:"
        echo "   adhd.sh -ocd ~/opt/ObjectCache --verify-software"
        echo "or"
        echo "   adhd.sh --install-object-cache"
        echo 
        RET=4
    else
        echo "OK"
    fi

    echo
    echo -n "Verifying Emulator: "
 
    if [ ! -x $EMU ]
    then
        echo "*** WARNING ***"
        echo "Emulator not found. You will not be able to start and stop AVDs."
        RET=4
    else
        echo "OK"
    fi

    return $RET
}

adbw()
{
    if [ "$ADEV" != "" ]
    then
        $ADB -s ${ADEV} $*
    else
        $ADB $*
    fi
}

#
# Internal
#
DEST_PATH=/mnt/sdcard/Download/
SHELL_SU_CMD="su root "
PROGRAM_SUITE=adhd
SHELL_NAME=adhd.sh
CLIARGS=$*
ADBW=adbw
SQLITE=sqlite3

log()
{
    echo "$*" >> $LOG_FILE
}

log "---=== $(date) ===---"


err()
{
    echo "$*" 1>&2
}

loge()
{
    log "$*"
    err "$*"
}

exit_if_error()
{
    RET=$1
    CMD=$2
    MSG=$3

    if [ "$RET" != "0" ]
    then
        loge "*** ERROR ***"
        loge "Return value: $RET"
        loge "$CMD"
        loge "$MSG"
        loge
        exit 2
    fi
}

warn_if_error()
{
    RET=$1
    CMD=$2
    MSG=$3

    if [ "$RET" != "0" ]
    then
        loge "*** WARNING ***"
        loge "Return value: $RET"
        loge "$CMD"
        loge "$MSG"
        loge
    fi
}

usage()
{
    echo "NAME"
    echo "   $SHELL_NAME - android development helper doctor"
    echo
    echo "SYNOPSIS"
    echo "   $SHELL_NAME [OPTION] APP MODE"
    echo 
    echo "DESCRIPTION"
    echo "   $SHELL_NAME"
    echo "      List android devices"
    echo
    echo "      List installed application (with database files and/or ObjectCache files)"
    echo
    echo "      Download and extract information from files on an Android Device:"
    echo "      * databases from an emulated device (or rooted physical device)"
    echo "      * serialized files (using Juneday's ObjectCache)"
    echo
    echo "      Manage (and visualise) downloaded files:"
    echo "      * databases are presented in HTML and TXT"
    echo "      * serialized are presented in TXT"
    echo "LOG"
    echo "   $SHELL_NAME logs to file "'$LOG_FILE'
    echo 
    echo "OPTIONS"
    echo "   --restart-daemon"
    echo "        restarts the adb daemon and exits"
    echo "   --list-devices,-ld"
    echo "        lists running devices"
    echo "   --list-available-devices, -lad"
    echo "        lists available devices"
    echo "   --device"
    echo "        specifies what device to manage"
    echo "        (if only one device is available this will be chosen)"
    echo "   --list-database-apps,-lda"
    echo "        lists only apps (on the device) with a database"
    echo "   --list-serialized-apps,-lsa"
    echo "        list only apps (on the device) with serialized files"
    echo "   -lsd"
    echo "        list only apps (on the device) with serialized files AND databases"
    echo "   --list-apps,-la"
    echo "        lists all apps (on the device)"
    echo "   --adb PROG"
    echo "        sets adb program to PROG"
    echo "   --help,-h"
    echo "        prints this help text"
    echo "   --verify-software, -vs"
    echo "        verify required softwares"
    echo "   --objectcache-dir, -ocd"
    echo "        directory where the ObjectCache class are located"
    echo "   --classpath, -cp"
    echo "        CLASSPATH for Java programs"
    echo 
    echo "APP"
    echo "   the program (on the Android Device) to manage"
    echo 
    echo "MODE"
    echo "   serializable - downloads files as serialized by ObjectCache and generates TXT files*"
    echo "   database - downloads database files and creates TXT file and HTML pages from each"
    echo "   all - all of the above"
    echo 
    echo "ENVIRONMENT VARIABLES"
    echo "   Set any of the below environment variables to alter the settings:"
    echo "   APP "
    echo "   - the Android app to manage. Default value: No default"
    echo "   MODE"
    echo "    - database, serialized, ... Default value: No default"
    echo "   ADB"
    echo "    - Android debugger bridge tool. Default: ~/Android/Sdk/platform-tools/adb"
    echo "   ADEV"
    echo "    - Android device to manage. Default value: No default"
    echo "   OC_PATH"
    echo "    - Directory where the ObjectCache class are located"
    echo "   CLASSPATH"
    echo "    - CLASSPATH for java programs"
    echo
    echo "RETURN VALUES"
    echo "    0 - success"
    echo "    2 - failure"
    echo "    3 - adb could not be found"
    echo "    4 - slite and/or ObjectCache could not be found"
    echo "   10 - no mode set"
    echo "   11 - no app set"
    echo
    echo "EXAMPLES"
    echo
    echo "   $SHELL_NAME -lda "
    echo "      lists all apps with one (or more) databases available"
    echo
    echo "   $SHELL_NAME -ld "
    echo "      lists all devices available"
    echo
    echo "   $SHELL_NAME  com.android.providers.contacts database"
    echo "      downloads all databases associated with"
    echo "      com.android.providers.contacts and creates TXT/HTML"
    echo 
    echo "   $SHELL_NAME  se.juneday.systemet serialized"
    echo "      downloads all files with serialized data for "
    echo "      se.juneday.systemet and creates TXT"
    echo
    echo "   $SHELL_NAME  --device emulator-5554 se.juneday.systemet serialized"
    echo "      downloads all files with serialized data for "
    echo "      se.juneday.systemet on devce emulator-5554 and creates TXT"
    echo
    echo "   $SHELL_NAME  -ocd ~/opt/ObjectCache --device emulator-5554 \\"
    echo "   se.juneday.systemet serialized"
    echo "      as above but using ObjectCache as found in"
    echo "      dir ~/opt/ObjectCache"
    echo
    echo "   $SHELL_NAME  -ocd ~/opt/ObjectCache  \\"
    echo "   -cp ~/AndroidStudioProjects/BlaBlaBla --device emulator-5554 \\"
    echo "   se.juneday.systemet serialized"
    echo "      as above but setting CLASSPATH to "
    echo "      ~/AndroidStudioProjects/BlaBlaBla to find your own classes"
    echo

}

list_apps()
{
    echo " *** AVAILABLE APPS  ***"
    ALL_APPS=$(${ADBW} shell "$SHELL_SU_CMD ls /data/data/") 2>> $LOG_FILE 
    exit_if_error $? "${ADBW} shell $SHELL_SU_CMD ls /data/data" "Failed listing apps on device"

    for dir in $ALL_APPS
    do
        
        if [ "$1" = "--only-database" ]
        then
            ${ADBW} shell "$SHELL_SU_CMD ls  /data/data/${dir}/databases" >> $LOG_FILE 2>&1
            RET=$?
            if [ $RET -eq 0 ]
            then
                echo " * ${dir}"
            fi
        elif [ "$1" = "--only-serialized" ]
        then
            ${ADBW} shell "$SHELL_SU_CMD ls /data/data/${dir}/|grep _serialized" >> $LOG_FILE 2>&1
            
            RET=$?
            if [ $RET -eq 0 ]
            then
                echo " * ${dir}"
            fi
        else
            echo " * ${dir}"
        fi            
    done
}


setup_oc() {
    if [ ! -f se/juneday/ObjectCacheReader.class ]
    then
        mkdir -p se/juneday/
        curl -o se/juneday/ObjectCacheReader.java https://raw.githubusercontent.com/progund/java-extra-lectures/master/caching/se/juneday/ObjectCacheReader.java
        curl -o se/juneday/ObjectCache.java https://raw.githubusercontent.com/progund/java-extra-lectures/master/caching/se/juneday/ObjectCache.java
        exit_if_error $? "Failed to download ObjectCache"

        javac se/juneday/ObjectCacheReader.java
        exit_if_error $? "Failed to compile ObjectCache"
    fi
}


while [ "$*" != "" ]
do    
#    echo "ARG: $1 | $*  [ $APP | $ADEV ]"
    case "$1" in
        "--restart-daemon"|"-rd")
            log "restarting"
            ${ADBW} kill-server >> $LOG_FILE 2>&1
            sleep 2
            ${ADBW} start-server >> $LOG_FILE 2>&1
            exit
            ;;
        "--list-available-devices"|"-lad")
            log "listing available devices"
#            for d in $(ls -1 ~/.android/avd/*.ini)
 #           do
  #              echo -n " * "
   #             basename $d | sed 's,\.ini,,'g
            #        done
            $EMU -list-avds
            exit
            ;;
        "--start-device"|"-sd")
            log "Startting device"
            ADEV=$2
            $EMU -avd $ADEV 2>>$LOG_FILE >>$LOG_FILE &
            shift
            exit
            ;;
        "--list-devices"|"-ld")
            log "listing devices"
            ${ADBW} devices  2>> $LOG_FILE 
            exit
            ;;
        "--install-object-cache"|"-io")
            setup_oc
            exit
            ;;
        "--device")
            log "setting device to $2"
            export ADEV=$2
            shift
            ;;
        "--list-database-apps"|"-lda")
            log "listing apps (with database)"
            list_apps --only-database
            exit
            ;;
        "--list-serialized-apps"|"-lsa")
            log "listing apps (with serialized files)"
            list_apps --only-serialized
            exit
            ;;
        "--list-apps"|"-la")
            log "listing apps"
            list_apps 
            exit
            ;;
        "--adb")
            log "ADB set to $2"
            ADB=$2
            shift
            ;;
        "--help"|"-h")
            log "help text printed"
            usage
            exit 
            ;;
        "--verify-software"|"-vs")
            verify_sw
            RET=$?
            exit $RET
            ;;
        "--objectcache-dir"|"-ocd")
            OC_PATH=$2
            shift
            ;;
        "--classpath"|"-cp")
            CLASSPATH=$2
            shift
            ;;
        "database")
            MODE=database
            log "MODE set to $MODE"
            ;;
        "serialized")
            MODE=serialized
            log "MODE set to $MODE"
            ;;
        "both")
            MODE=both
            log "MODE set to $MODE"
            ;;
        *)
            APP=$1
            ;;
    esac
    shift
done

check_app()
{
    if [ "$APP" = "" ]
    then
        echo "No app supplied"
        echo "To see available apps"
        echo $0 --list-apps
        exit
    fi
}

DATA_PATH=/data/data/${APP}
DB_PATH=${DATA_PATH}/databases
DEST_DIR=$PROGRAM_SUITE/apps/$APP

prepare_dload()
{
    TO_DLOAD="$1"
    echo -n "* Preparing download of $TO_DLOAD: "
    CMD="$SHELL_SU_CMD cp $1 ${DEST_PATH}/"
    ${ADBW} shell "$CMD"   >> $LOG_FILE 2>&1
    exit_if_error $? "$CMD"  "Failed preparing file download on device"
    echo "OK"
}

dload()
{
    TO_DLOAD="$1"
    echo -n "* Downloading $TO_DLOAD:           " 
    CMD="pull ${TO_DLOAD}"
    ${ADBW} ${CMD} >> $LOG_FILE 2>&1
    exit_if_error $? "${ADBW}  ${CMD}" "Failed downloading file from device"
    echo "OK"

}

move_file()
{
    TO_MOVE="$1"
    echo -n "* Moving file $TO_MOVE:           " 
    mv ${TO_MOVE} $DEST_DIR >> $LOG_FILE 2>&1
    exit_if_error $? "mv ${TO_MODE} $DEST_DIR" "Failed moving file to $DEST_DIR"
    echo "OK"
}

read_serialized()
{
#    setup_oc
    echo
    echo "Converting serialized files to txt files"
    echo "========================================================"
    CMD="java -cp $OC_PATH${PATHSEP}$CLASSPATH se.juneday.ObjectCacheReader "
    for ser in $(find adhd/apps/$APP -name "*serialized.data" | sed 's,_serialized.data,,g')
    do
        echo -n " * creating ${ser}.txt: "
        $CMD $ser > ${ser}.txt
        if [ $? -eq 0 ]
        then
            echo "OK"
        else
            echo "FAILURE"
        fi
    done    
}

download_serialized()
{
    mkdir -p $DEST_DIR
    CNT=1
    for ser in $(${ADBW} shell "$SHELL_SU_CMD ls ${DATA_PATH}/ | grep \.serialized.data" 2>> $LOG_FILE)  
    do
        echo
        echo "Handling serialized file # $CNT: $ser"
        echo "========================================================"
        prepare_dload "${DATA_PATH}/$ser"
        dload "${DEST_PATH}/${ser}"
        move_file "${ser}"
        CNT=$(( $CNT + 1 ))
    done
}

download_db()
{
#    echo "DLOAD: ${ADBW} shell $SHELL_SU_CMD ls ${DB_PATH}/ | grep \.db"
    mkdir -p $DEST_DIR
    CNT=1
    for dbase in $(${ADBW} shell "$SHELL_SU_CMD ls ${DB_PATH}/ | grep \.db$" 2>> $LOG_FILE)  
    do
        DB_NAME=$(basename $dbase)
        
        echo
        echo "Handling database # $CNT: $DB_NAME"
        echo "========================================================"
        prepare_dload "${DB_PATH}/$dbase"
        dload "${DEST_PATH}/${DB_NAME}"
        move_file ${DB_NAME}
        CNT=$(( $CNT + 1 ))
        echo
    done
}

sql()
{
    log "SQL: $* [using sqlite3 $DB]" 
    echo -e "$*" | sqlite3 $DB
}

init_html()
{
    echo "<html>" >> $1
    echo "<body>" >> $1
}

end_html()
{
    echo "</body>" >> $1
    echo "</html>" >> $1
}

read_db()
{
    echo
    echo "Reading databases"
    echo "========================================================"

    for db in $(find $DEST_DIR -name "*.db" )
    do
        echo "Database $db:"
        export DB=$db
        rm -f ${db}.html
        rm -f ${db}.txt
        init_html  ${db}.html
        
        for tbl in $(sql ".schema" | grep -v android_metadata | grep "CREATE[ ]*TABLE" | sed -e 's,(, (,g' -e 's,[ ]*IF[ ]*NOT[ ]*EXISTS[ ]*, ,g' -e "s,',,g" |  awk '{ print $3}')
        do
            echo " * $tbl"
            log "Reading from $DB::$tbl"
            echo "<table border=1>  " >> ${db}.html
            echo "<h1>Table: $tbl</h1>" >> ${db}.html
            SQL_CMD=".header on\n.mode html\nSELECT * FROM $tbl"
            sql "$SQL_CMD" >>  ${db}.html
            echo "</table>  " >> ${db}.html

            SQL_CMD=".mode ascii\nSELECT * FROM $tbl"
            sql "$SQL_CMD" >> ${db}.txt

        done
        end_html  ${db}.html
    done
}

log "What do I do now?, here's some settings before proceeding:"
log "ADB: $ADB"
log "APP: $APP"
log "MODE: $MODE"
log ""

case $MODE in
    "database")
        log "Download db"
        check_app
        download_db
        read_db
        ;;
    "serialized")
        log "Download serialized file"
        check_app
        download_serialized
        read_serialized
        ;;
    "both")
        log "Download db"
        check_app
        download_db
        read_db
        log "Download serialized file"
        check_app
        download_serialized
        read_serialized
        ;;
    *)
        log "no mode set, bailing out"
        echo " *** ERROR ***"
        echo "No mode choosen.... Don't know what you want to do."
        echo ".... Oh no, I am trapped in my own mind."
        echo ".. Tell me about your mother!"
        echo " *** ERROR ***"
        exit 10
        ;;
esac


log "Leaving"
log ""
