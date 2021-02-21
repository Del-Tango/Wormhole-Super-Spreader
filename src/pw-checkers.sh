#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# CHECKERS

function check_python3_library_installed () {
    local LIBRARY="$1"
    python3 -c "import $LIBRARY" &> /dev/null
    return $?
}


