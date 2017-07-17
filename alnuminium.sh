#! /usr/bin/env bash

function generate_alnum {
    #
    # Generate a random alphanumeric string
    #
    # globals:
    #
    # args:
    #   $1 number of characters
    #   $2 number of strings
    #   $3 optional prefix
    #   $4 method
    #
    # returns:
    #

    unset __alnuminium
    _generate_alnum_"${4:-mktemp}" "${1:-8}" "${2:-1}" "$3"
}

function _generate_alnum_mktemp {
    #
    # Generates strings using mktemp
    #
    # globals:
    #
    # args:
    #   $1 number of characters
    #   $2 number of strings
    #   $3 optional prefix
    #
    # returns:
    #   $__alnuminium
    #

    [[ $1 -lt 4 ]] && { printf "mktemp requires at least 3 characters in length" 1>&2; return 1; }

    local _p _pad
    _pad="$( eval printf 'X%.0s' "{1..${1}}" )"
    for (( i=0; i<$2; i++ ))
    do
        _p=( "${3}$( mktemp -u tmp."${_pad}" )" )
        __alnuminium+=( "${_p/tmp.}" )
    done

    return 0
}

function _generate_alnum_urandom {
    #
    # Generates strings using /dev/urandom
    #
    # globals:
    #
    # args:
    #   $1 number of characters
    #   $2 number of strings
    #   $3 optional prefix
    #
    # returns:
    #   $__alnuminium
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
        __alnuminium+=( "${3}$_p" )
    done

    return 0
}
