#! /usr/bin/env bash

function generate_hash {
    #
    # Generate a random alphanumeric hash
    #
    # globals:
    #
    # args:
    #   $1 number of characters
    #   $2 number of hashes
    #   $3 method
    #
    # returns:
    #

    unset __hash
    _generate_hash_"${3:-mktemp}" "$1" "$2"
}

function _generate_hash_mktemp {
    #
    # Generates hashes using mktemp
    #
    # globals:
    #
    # args:
    #   $1 number of characters
    #   $2 number of hashes
    #
    # returns:
    #   $__hash
    #

    local _p _pad
    _pad="$( eval printf 'X%.0s' "{1..${1}}" )"
    for (( i=0; i<$2; i++ ))
    do
        _p=( "$( mktemp -u tmp."${_pad}" )" )
        __hash+=( "${_p/tmp.}" )
    done

    return 0
}

function _generate_hash_urandom {
    #
    # Generates hashes using /dev/urandom
    #
    # globals:
    #
    # args:
    #   $1 number of characters
    #   $2 number of hashes
    #
    # returns:
    #   $__hash
    #

    local _p
    for (( i=0; i<$2; i++ ))
    do
        _p=""
        while read -r -n 1 _c
        do
            [[ ${_c:0:1} =~ [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789] ]] && {
            _p=$_p$_c
        }
        [[ ${#_p} -ge $1 ]] && break
        done < /dev/urandom
        __hash+=( "$_p" )
    done

    return 0
}
