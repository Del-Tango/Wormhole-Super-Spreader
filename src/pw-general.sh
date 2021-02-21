#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# GENERAL

function self_destruct () {
    if [ -z "${MD_DEFAULT['project-path']}" ]; then
        error_msg "No project path declared."
        return 1
    fi
    rm -rf "${MD_DEFAULT['project-path']}" &> /dev/null
    return $?
}
