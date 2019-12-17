#!/bin/sh
set -ex

user=root
password=123456
database=""

set -- `getopt -o u:p:d: --long user:,password:,database: -- "$@"`

while [ -n "$1" ]
do
    case "$1" in
        -u|--user)
            user=$2
            shift
            ;;
        -p|--password)
            password=$2
            shift
            ;;
        -d|--database)
            database=$2
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "invalid option $1"
            break
            ;;
    esac
    shift
done

if [ -z $database ]; then
    echo "no database selected"
    exit
fi

old=$HOME/backup/$database-$(date -d '-7 days' +%Y%m%d).sql
new=$HOME/backup/$database-$(date +%Y%m%d).sql

mkdir -p $HOME/backup

if [ -f $old ]; then
    rm -f $old
fi

docker exec mariadb sh -c "mysqldump -u$user -p$password $database" > $new
