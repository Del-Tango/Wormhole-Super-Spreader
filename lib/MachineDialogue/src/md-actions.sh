#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# ACTIONS

function action_back () {
    return 1
}

function action_clear_log_file () {
    check_file_exists "${MD_DEFAULT['log-file']}"
    if [ $? -ne 0 ]; then
        warning_msg "Log file ${RED}${MD_DEFAULT['log-file']}${RESET}"\
            "not found."
        return 1
    fi
    echo -n > "${MD_DEFAULT['log-file']}"
    check_file_empty "${MD_DEFAULT['log-file']}"
    if [ $? -ne 0 ]; then
        error_msg "Something went wrong."\
            "Could not clear ${BLUE}$SCRIPT_NAME${RESET}"\
            "log file ${RED}${MD_DEFAULT['log-file']}${RESET}."
        return 4
    fi
    ok_msg "Successfully cleared ${BLUE}$SCRIPT_NAME${RESET}"\
        "log file ${GREEN}${MD_DEFAULT['log-file']}${RESET}."
    return 0
}

function action_log_view_tail () {
    check_file_exists "${MD_DEFAULT['log-file']}"
    if [ $? -ne 0 ]; then
        warning_msg "Log file ${RED}${MD_DEFAULT['log-file']}${RESET}"\
            "not found."
        return 1
    fi
    echo; tail -n ${MD_DEFAULT['log-lines']} ${MD_DEFAULT['log-file']}
    return $?
}

function action_log_view_head () {
    check_file_exists "${MD_DEFAULT['log-file']}"
    if [ $? -ne 0 ]; then
        warning_msg "Log file ${RED}${MD_DEFAULT['log-file']}${RESET}"\
            "not found."
        return 1
    fi
    echo; head -n ${MD_DEFAULT['log-lines']} ${MD_DEFAULT['log-file']}
    return $?
}

function action_log_view_more () {
    check_file_exists "${MD_DEFAULT['log-file']}"
    if [ $? -ne 0 ]; then
        warning_msg "Log file ${RED}${MD_DEFAULT['log-file']}${RESET}"\
            "not found."
        return 1
    fi
    echo; more ${MD_DEFAULT['log-file']}
    return $?
}

