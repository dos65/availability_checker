#!/bin/sh

ANY=false

usage() {
    printf "Usage options:\n"
    printf "\t-f : path to file with services adresses\n"
    printf "\t     file must contans lines formatted 'host:port'\n"
    printf "\t-a : print first available and exit\n"
    printf "\t-h : help\n"
}

while getopts ":f:ah" opt; do
    case $opt in
        f)
          FILE=$OPTARG
          ;;
        a)
          ANY=true
          ;;
        h)
          usage
          exit 0
          ;;
        *)
          usage
          exit 1
          ;;
    esac
done

if [ -z $FILE ]; then
    usage
    exit 1
fi


SUCCESS=false
TIMEOUT=3
while read line; do
    HOST=$(echo $line | cut -d ':' -f1)
    PORT=$(echo $line | cut -d ':' -f2)
    nc -w $TIMEOUT -zv $HOST $PORT 1>>/dev/null 2>>/dev/null
    if [ $? != 0 ]; then
        echo $line
        if $ANY ; then
            exit 0
        fi
        SUCCESS=true
    fi
done < $FILE

if $SUCCESS; then
    exit 0
else 
    printf "All services are not available\n"
    exit 1
fi
