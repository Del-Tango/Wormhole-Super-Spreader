#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# FETCHERS

function fetch_data_from_user () {
    local PROMPT="$1"
    local OPTIONAL="${@:2}"
    while :
    do
        if [[ $OPTIONAL == 'password' ]]; then
            read -sp "$PROMPT: " DATA
        else
            read -p "$PROMPT> " DATA
        fi
        if [ -z "$DATA" ]; then
            continue
        elif [[ "$DATA" == ".back" ]]; then
            return 1
        fi
        echo "$DATA"; break
    done
    return 0
}

function fetch_ultimatum_from_user () {
    PROMPT="$1"
    while :
    do
        local ANSWER=`fetch_data_from_user "$PROMPT"`
        case "$ANSWER" in
            'y' | 'Y' | 'yes' | 'Yes' | 'YES')
                return 0
                ;;
            'n' | 'N' | 'no' | 'No' | 'NO')
                return 1
                ;;
            *)
        esac
    done
    return 2
}

function fetch_selection_from_user () {
    local PROMPT="$1"
    local OPTIONS=( "${@:2}" "Back" )
    local OLD_PS3=$PS3
    PS3="$PROMPT> "
    select opt in "${OPTIONS[@]}"; do
        case "$opt" in
            'Back')
                PS3="$OLD_PS3"
                return 1
                ;;
            *)
                local CHECK=`check_item_in_set "$opt" "${OPTIONS[@]}"`
                if [ $? -ne 0 ]; then
                    warning_msg "Invalid option."
                    continue
                fi
                PS3="$OLD_PS3"
                echo "$opt"
                return 0
                ;;
        esac
    done
    PS3="$OLD_PS3"
    return 2
}

function fetch_menu_controllers_with_extended_banner () {
    debug_msg "Detected (${WHITE}${#MD_CONTROLLER_BANNERS[@]}${RESET})"\
        "controllers with extended banners:"\
        "${YELLOW}${!MD_CONTROLLER_BANNERS[@]}${RESET}"
    echo ${!MD_CONTROLLER_BANNERS[@]}
    return $?
}

function fetch_controller_option_id () {
    local CONTROLLER_LABEL="$1"
    local OPTION_LABEL="$2"
    VALID_JUMP_KEYS=( `fetch_jump_keys` )
    debug_msg "Valid jumper keys found: ${YELLOW}${VALID_JUMP_KEYS[@]}${RESET}"
    check_item_in_set "$CONTROLLER_LABEL-jump-$OPTION_LABEL" ${VALID_JUMP_KEYS[@]}
    if [ $? -ne 0 ]; then
        KEY_TO_SEARCH_BY="$CONTROLLER_LABEL-$OPTION_LABEL"
        debug_msg "Menu controller action ${YELLOW}$KEY_TO_SEARCH_BY${RESET}"\
            "triggered."
    else
        KEY_TO_SEARCH_BY="$CONTROLLER_LABEL-jump-$OPTION_LABEL"
        debug_msg "Menu controller jumper ${YELLOW}$KEY_TO_SEARCH_BY${RESET}"\
            "triggered."
    fi
    echo "$KEY_TO_SEARCH_BY"
    return $?
}

function fetch_jump_keys () {
    JUMP_KEYS=()
    for action_key in "${!MD_CONTROLLER_OPTION_KEYS[@]}"; do
        check_string_matches_regex_pattern "$action_key" "*-jump-*"
        if [ $? -ne 0 ]; then
            debug_msg "Action key ${RED}$action_key${RESET} does not match"\
                "pattern ${RED}*-jump-*${RESET}"
            continue
        fi
        JUMP_KEYS=( ${JUMP_KEYS[@]} "$action_key" )
        debug_msg "Controller jumper key ${GREEN}$action_key${RESET} detected."
    done
    echo ${JUMP_KEYS[@]}
    return $?
}

function fetch_action_keys () {
    debug_msg "Detected (${WHITE}${#MD_CONTROLLER_OPTION_KEYS[@]}${RESET})"\
        "option keys: ${YELLOW}${!MD_CONTROLLER_OPTION_KEYS[@]}${RESET}."
    if [ ${#MD_CONTROLLER_OPTION_KEYS[@]} -eq 0 ]; then
        error_msg "No ${BLUE}$SCRIPT_NAME${RESET}"\
            "${RED}action keys${RESET} found."
        return 1
    fi
    echo ${!MD_CONTROLLER_OPTION_KEYS[@]}
    return $?
}

function fetch_all_menu_controller_options () {
    local MENU_CONTROLLER_LABEL="$1"
    CONTROLLER_OPTIONS=(
        `echo "${MD_CONTROLLER_OPTIONS[$MENU_CONTROLLER_LABEL]}" | tr ',' ' '`
    )
    debug_msg "Controller: ${CYAN}$MENU_CONTROLLER_LABEL${RESET},"\
        "Options: ${YELLOW}${CONTROLLER_OPTIONS[@]}${RESET}."
    echo "${CONTROLLER_OPTIONS[@]}"
    return $?
}

function fetch_action_key_count () {
    KEY_COUNT=${#MD_CONTROLLER_OPTION_KEYS[@]}
    debug_msg "Detected (${WHITE}$KEY_COUNT${RESET}) action keys."
    echo $KEY_COUNT
    return $?
}

function fetch_action_key_regex_pattern () {
    local MENU_CONTROLLER_LABEL="$1"
    local REGEX_PATTERN="$MENU_CONTROLLER_LABEL-"
    debug_msg "Computed action key REGEX pattern ${YELLOW}$REGEX_PATTERN${RESET}."
    echo "$REGEX_PATTERN"
    return $?
}

function fetch_menu_controllers () {
    debug_msg "Detected (${WHITE}${#MD_CONTROLLERS[@]}${RESET})"\
        "menu controllers: ${YELLOW}${!MD_CONTROLLERS[@]}${RESET}."
    if [ ${#MD_CONTROLLERS[@]} -eq 0 ]; then
        echo; error_msg "No ${BLUE}$SCRIPT_NAME${RESET}"\
            "${RED}menu controllers${RESET} found."
        return 1
    fi
    echo ${!MD_CONTROLLERS[@]}
    return $?
}

function fetch_set_log_levels () {
    if [ ${#MD_LOGGING_LEVELS[@]} -eq 0 ]; then
        echo; error_msg "No ${BLUE}$SCRIPT_NAME${RESET}"\
            "${RED}logging levels${RESET} found."
        return 1
    fi
    echo ${MD_LOGGING_LEVELS[@]}
    return 0
}


