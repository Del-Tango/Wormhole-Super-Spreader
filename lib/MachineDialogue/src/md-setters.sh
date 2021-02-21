#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# SETTERS

function set_menu_controller_extended_banner () {
    local MENU_CONTROLLER="$1"
    local DISPLAY_BANNER_FUNCTION_NAME="$2"
    check_function_is_defined "$DISPLAY_BANNER_FUNCTION_NAME"
    if [ $? -ne 0 ]; then
        error_msg "Display banner function"\
            "${RED}$DISPLAY_BANNER_FUNCTION_NAME${RESET} not found."
        return 1
    fi
    MD_CONTROLLER_BANNERS["$MENU_CONTROLLER"]="$DISPLAY_BANNER_FUNCTION_NAME"
    return 0
}

function set_requiered_privileges () {
    local PRIVILEGES="$1"
    if [[ "$PRIVILEGES" != 'on' ]] && [[ "$PRIVILEGES" != 'off' ]]; then
        error_msg "Invalid superuser privileges flag value"\
            "${RED}$PRIVILEGES${RESET}. Defaulting to ${GREEN}ON${RESET}."
        MD_ROOT='on'
        return 1
    fi
    MD_ROOT=$PRIVILEGES
    return 0
}

function set_project_name () {
    local PROJECT_NAME="$1"
    SCRIPT_NAME="$PROJECT_NAME"
    return 0
}

function set_project_prompt () {
    local PROJECT_PROMPT="$1"
    PS3="$PROJECT_PROMPT"
    return 0
}

function set_menu_controller_action_key () {
    local CONTROLLER_ACTION_KEY="$1"
    local CONTROLLER_ACTION_RESOURCE="$2"
    REGISTERED_ACTION_KEYS=( `fetch_action_keys` )
    check_item_in_set "$CONTROLLER_ACTION_KEY" ${REGISTERED_ACTION_KEYS[@]}
    if [ $? -eq 0 ]; then
        warning_msg "Controller action key"\
            "${RED}$CONTROLLER_ACTION_KEY${RESET} already exists."
        return 1
    fi
    MD_CONTROLLER_OPTION_KEYS["$CONTROLLER_ACTION_KEY"]="$CONTROLLER_ACTION_RESOURCE"
    return 0
}

function set_menu_controller_options () {
    local MENU_CONTROLLER_LABEL="$1"
    local MENU_CONTROLLER_OPTIONS="$2"
    check_menu_controller_exists "$MENU_CONTROLLER_LABEL"
    if [ $? -ne 0 ]; then
        warning_msg "Menu controller"\
            "${RED}$MENU_CONTROLLER_LABEL${RESET} does not exists."
        return 1
    fi
    MD_CONTROLLER_OPTIONS["$MENU_CONTROLLER_LABEL"]="$MENU_CONTROLLER_OPTIONS"
    return 0
}

function set_menu_controller_description () {
    local MENU_CONTROLLER_LABEL="$1"
    local MENU_CONTROLLER_DESCRIPTION="${@:2}"
    check_menu_controller_exists "$MENU_CONTROLLER_LABEL"
    if [ $? -ne 0 ]; then
        warning_msg "Menu controller"\
            "${RED}$MENU_CONTROLLER_LABEL${RESET} does not exists."
        return 1
    fi
    MD_CONTROLLERS["$MENU_CONTROLLER_LABEL"]="$MENU_CONTROLLER_DESCRIPTION"
    return 0
}

function set_menu_controller () {
    local MENU_CONTROLLER_LABEL="$1"
    local MENU_CONTROLLER_DESCRIPTION="${@:2}"
    check_menu_controller_exists "$MENU_CONTROLLER_LABEL"
    if [ $? -eq 0 ]; then
        warning_msg "Menu controller"\
            "${RED}$MENU_CONTROLLER_LABEL${RESET} already exists."
        return 1
    fi
    MD_CONTROLLERS["$MENU_CONTROLLER_LABEL"]="$MENU_CONTROLLER_DESCRIPTION"
    return 0
}

function set_file_editor () {
    local FILE_EDITOR="$1"
    check_util_installed "$FILE_EDITOR"
    if [ $? -ne 0 ]; then
        warning_msg "Editor ${RED}$FILE_EDITOR${RESET} not installed."
        return 1
    fi
    MD_DEFAULT['file-editor']=$FILE_EDITOR
    return 0
}

function set_logging () {
    local LOGGING="$1"
    if [[ "$LOGGING" != 'on' ]] && [[ "$LOGGING" != 'off' ]]; then
        error_msg "Invalid logging value ${RED}$LOGGING${RESET}."\
            "Defaulting to ${GREEN}ON${RESET}."
        MD_LOGGING='on'
        return 1
    fi
    MD_LOGGING=$LOGGING
    return 0
}

function set_safety () {
    local SAFETY="$1"
    if [[ "$SAFETY" != 'on' ]] && [[ "$SAFETY" != 'off' ]]; then
        error_msg "Invalid safety value ${RED}$SAFETY${RESET}."\
            "Defaulting to ${GREEN}ON${RESET}."
        MD_SAFETY='on'
        return 1
    fi
    MD_SAFETY=$SAFETY
    return 0
}

function set_temporary_file () {
    local FILE_PATH="$1"
    check_file_exists "$FILE_PATH"
    if [ $? -ne 0 ]; then
        error_msg "File ${RED}$FILE_PATH${RESET} not found."
        return 1
    fi
    MD_DEFAULT['tmp-file']="$FILE_PATH"
    return 0
}


