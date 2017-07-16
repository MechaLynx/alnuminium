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
    #   $3 optional prefix
    #   $4 method
    #
    # returns:
    #

    unset __hash
    _generate_hash_"${4:-mktemp}" "$1" "$2" "$3"
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
    #   $3 optional prefix
    #
    # returns:
    #   $__hash
    #

    local _p _pad
    _pad="$( eval printf 'X%.0s' "{1..${1}}" )"
    for (( i=0; i<$2; i++ ))
    do
        _p=( "${3}$( mktemp -u tmp."${_pad}" )" )
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
    #   $3 optional prefix
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
            # the proper character classes don't work here for some reason
            # hence the ugly hack with the massive string of characters
            [[ ${_c:0:1} =~ [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789] ]] && {
            _p=$_p$_c
        }
        [[ ${#_p} -ge $1 ]] && break
        done < /dev/urandom
        __hash+=( "${3}$_p" )
    done

    return 0
}
