#!/bin/bash

###########################################3
#
# Android Development Helper Doctor - ADHD
#
# (c) Henrik Sandklef, Rikard Fröberg 2017
#
# License GPLv3
#
###########################################3


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

verify_adb()
{
    ${ADB_PATH}/$ADB help >/dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo "*** ERROR ***"
        echo "adb not found, tried ${ADB_PATH}/$ADB"
        echo "    ADB_PATH:${ADB_PATH}"
        echo "    ADB:     ${ADB}"
        exit 3
    fi
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

usage()
{
    echo "NAME"
    echo "   $SHELL_NAME - android development helper doctor"
    echo
    echo "SYNOPSIS"
    echo "   $SHELL_NAME [OPTION] APP MODE"
    echo 
    echo "DESCRIPTION"
    echo "   $SHELL_NAME assists you with:"
    echo "      Download files:"
    echo "      * databases from an emulated device (or rooted physical device)"
    echo "      * serialized files (using Juneday's ObjectCache)"
    echo "      Manage (and visualise) downloaded files:"
    echo "      * databases are presented in HTML"
    echo "LOG"
    echo "   $SHELL_NAME logs to file "'$LOG_FILE' "(currently set to $LOG_FILE)"
    echo 
    echo "OPTIONS"
    echo "   --restart - restarts the adb daemon"
    echo "   --list-devices,-ld        - lists available devices"
    echo "   --device                  - specifies what device to manage"
    echo "                                (if only one device is available this will be chosen)"
    echo "   --list-database-apps,-lda - lists only apps (on the device) with a database"
    echo "   --list-serialized-apps,-lsa - list only apps (on the device) with serialized files"
    echo "   --list-apps,-la           - lists all apps (on the device)"
    echo "   --adb [PROG]              - sets adb program to use"
    echo "   --help,-h                 - prints this help text"
    echo 
    echo "APP"
    echo "   the program to manage"
    echo 
    echo "MODE"
    echo "   serializable - downloads files as serialized by ObjectCache*"
    echo "   database - downloads database files and creates txt file and html pages from each"
    echo 
    echo "ENVIRONMENT VARIABLES"
    echo "   APP - the Android app to manage"
    echo "   MODE - database, serialized, ...  "
    echo "   ADB - Android debugger bridge tool"
    echo "   ADEV - Android device to manage"
    echo
    echo "RETURN VALUES"
    echo "    0 - success"
    echo "    2 - failure"
    echo "    3 - adb could not be found"
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
    echo "      downloads all databases associated with com.android.providers.contacts"
    echo 
    echo "   $SHELL_NAME  se.juneday.systemet serialized"
    echo "      downloads all files with serialized data for se.juneday.systemet"
    echo
    echo "   $SHELL_NAME  --device emulator-5554 se.juneday.systemet serialized"
    echo "      downloads all files with serialized data for se.juneday.systemet on devce emulator-5554"
    echo

}

list_apps()
{
    echo " *** AVAILABLE APPS  ***"
    ALL_APPS=$(${ADBW} shell "$SHELL_SU_CMD ls /data/data") 2>> $LOG_FILE 
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
            ${ADBW} shell "$SHELL_SU_CMD ls  /data/data/${dir}/|grep _serializsed" >> $LOG_FILE 2>&1
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



verify_adb
while [ "$*" != "" ]
do    
#    echo "ARG: $1 | $*  [ $APP | $ADEV ]"
    case "$1" in
        "--restart")
            log "restarting"
            ${ADBW} kill-server >> $LOG_FILE 2>&1
            sleep 2
            ${ADBW} start-server >> $LOG_FILE 2>&1
            exit
            ;;
        "--list-devices"|"-ld")
            log "listing devices"
            ${ADBW} devices  2>> $LOG_FILE 
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
        "database")
            MODE=database
            log "MODE set to $MODE"
            ;;
        "serialized")
            MODE=serialized
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
