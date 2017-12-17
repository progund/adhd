#!/bin/bash

ADHD_DIR=$(dirname $0)

APP=
MODE=
ADB=

ADHD=$ADHD_DIR/adhd.sh

verify_sw()
{
    echo -n "Verifying required software:"
    $ADHD --verify-software
    RET=$?
    if [ $RET -eq 0 ]
    then
        echo " OK"
    else
        echo "Error or warning from adhd"
        echo -n "Continue? [Y/n]? "
        read ANS
        if [ "$ANS" = "y" ] || [ "$ANS" = "Y" ]  || [ "$ANS" = "" ]
        then
            echo
        else
            echo "Try the following to see information about ENVIRONMENT variables"
            echo "that may help you:"
            echo "  adhd.sh --help"
            exit $RET
        fi
    fi
}

get_device()
{
    echo "Listing attached devices:"
    $ADHD --list-devices | grep -v "List of devices attached" | \
        while read ADEVICE
        do
            if [ "$ADEVICE" = "" ]; then break ; fi
            echo " * " $ADEVICE
        done 
    echo "Which devices would you like to connect to? "
    read ADEV
}

get_app()
{
    echo "Listing apps on device $ADEV:"
    $ADHD -dev $ADEV --list-apps 
    echo "Which devices would you like to download files from? "
    read APP
}

gen_db_cli()
{
    echo "To download and create txt and html from database:"
    echo $ADHD --device $ADEV $APP database
}

gen_serialized_cli()
{
    echo "To download serialized file, type:"
    echo $ADHD --device $ADEV $APP serialized
}

verify_sw
get_device
get_app
gen_db_cli
gen_serialized_cli



