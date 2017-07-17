#! /usr/bin/env bash
# shellcheck disable=1091

source ./alnuminium.sh

_MAX_LENGTH=512
_MAX_STRINGS=4096

# mktemp requires a length of at least 3
_MIN_LENGTH=4
_MIN_STRINGS=1

_METHODS=( "mktemp" "urandom" )

_FILENAME=bench-results.csv

declare l h a r m s z p

IFSold="$IFS"
IFS=$' \t\n'

echo method,length,count,real,user,sys,pre-entropy,post-entropy > ~/"$_FILENAME"

for (( l=_MIN_LENGTH; l<=_MAX_LENGTH; (( l=l*2 )) ))
do
    for (( h=_MIN_STRINGS; h<=_MAX_STRINGS; (( h=h*2 )) ))
    do
        for a in "${_METHODS[@]}"
        do
            printf "Benchmarking: %s %d %d\n" "$a" $l $h
            p="$(cat /proc/sys/kernel/random/entropy_avail)"
            IFS=$'\n'
            readarray -t r <<< "$( { time generate_alnum $l $h "" "$a"; } 2>&1)"
            IFS=$' \t\n'
            # shellcheck disable=2116
            for (( i=1; i<${#r[*]}; i++ ))
            do
                read -r r[$i] <<< "${r[$i]#*$'\t'}"
                m=$( echo "${r[$i]%m*}" )
                s=$( echo "${r[$i]#*m}" )
                s=$( echo "${s%s*}" )
                r[$i]=$( awk "BEGIN {print $m*60+$s}" )
            done
                z="$a","$l","$h","${r[1]}","${r[2]}","${r[3]}",$p,"$( cat /proc/sys/kernel/random/entropy_avail )"
                echo "$z" >> ~/"$_FILENAME"
        done
    done
done

IFS="$IFSold"
