#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# SETTERS

function set_loaded_payload () {
    local PAYLOAD_LABEL="$1"
    check_item_in_set "$PAYLOAD_LABEL" ${!PW_PAYLOAD[@]}
    if [ $? -ne 0 ]; then
        error_msg "Invalid payload label (${RED}$PAYLOAD_LABEL${RESET})."
        return 1
    fi
    PW_IMPORTS['payload-file']=${PW_PAYLOAD[$PAYLOAD_LABEL]}
    return 0
}

function set_silent_flag () {
    local SILENCE="$1"
    if [[ "$SILENCE" != 'on' ]] && [[ "$SILENCE" != 'off' ]]; then
        error_msg "Invalid silence value ${RED}$SILENCE${RESET}."\
            "Defaulting to ${GREEN}ON${RESET}."
        MD_DEFAULT['silent']='on'
        return 1
    fi
    MD_DEFAULT['silent']="$SILENCE"
    return 0
}

function set_victim_directory_path () {
    local DIR_PATH="$1"
    check_directory_exists "$DIR_PATH"
    if [ $? -ne 0 ]; then
        error_msg "Directory (${RED}$DIR_PATH${RESET}) does not exist."
        return 1
    fi
    MD_DEFAULT['victim-dir']="$DIR_PATH"
    return 0
}

function set_code_insertion_mode () {
    local INSERTION_MODE="$1"
    check_item_in_set "$INSERTION_MODE" "write" "insert" "append"
    if [ $? -ne 0 ]; then
        error_msg "Invalid (${BLUE}$SCRIPT_NAME${RESET}) code insertion"\
            "priority mode (${RED}$INSERTION_MODE${RESET})."
        return 1
    fi
    MD_DEFAULT['insertion-mode']="$INSERTION_MODE"
    return 0
}

function set_imported_payload_file () {
    local FILE_PATH="$1"
    check_file_exists "$FILE_PATH"
    if [ $? -ne 0 ]; then
        if [[ "$FILE_PATH" != "" ]]; then
            error_msg "File (${RED}$FILE_PATH${RESET}) does not exist."
            return 1
        fi
    fi
    PW_IMPORTS['payload-file']="$FILE_PATH"
    return 0
}

function set_payload_code () {
    local PAYLOAD_CODE="$@"
    if [ -z "$PAYLOAD_CODE" ] && [[ "$PAYLOAD_CODE" != '' ]]; then
        error_msg "No payload code specified."
        return 1
    fi
    MD_DEFAULT['payload-code']="$PAYLOAD_CODE"
    return 0
}

function set_log_file () {
    local FILE_PATH="$1"
    check_file_exists "$FILE_PATH"
    if [ $? -ne 0 ]; then
        error_msg "File (${RED}$FILE_PATH${RESET}) does not exist."
        return 1
    fi
    MD_DEFAULT['log-file']="$FILE_PATH"
    return 0
}

function set_log_lines () {
    local LOG_LINES=$1
    if [ -z "$LOG_LINES" ]; then
        error_msg "Log line value (${RED}$LOG_LINES${RESET}) is not a number."
        return 1
    fi
    MD_DEFAULT['log-lines']=$LOG_LINES
    return 0
}


