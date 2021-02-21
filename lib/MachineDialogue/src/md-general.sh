#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# GENERAL

function add_apt_dependency () {
    local APT_DEPENDENCY="$1"
    check_apt_dependency_set "$APT_DEPENDENCY"
    if [ $? -eq 0 ]; then
        nok_msg "Dependency ${RED}$APT_DEPENDENCY${RESET}"\
            "is already set to be installed using the APT package manager."
        return 1
    fi
    MD_APT_DEPENDENCIES+=( "$APT_DEPENDENCY" )
    ok_msg "Successfully set dependency ${GREEN}$APT_DEPENDENCY${RESET}"\
        "up to be installed using the APT package manager."
    return 0
}

function remove_apt_dependency () {
    local APT_DEPENDENCY="$1"
    check_apt_dependency_set "$APT_DEPENDENCY"
    if [ $? -ne 0 ]; then
        nok_msg "Dependency ${RED}$APT_DEPENDENCY${RESET}"\
            "is not set to be installed using the APT package manager."
        return 1
    fi
    MD_APT_DEPENDENCIES=( "${MD_APT_DEPENDENCIES[@]/$APT_DEPENDENCY}" )
    ok_msg "Successfully removed dependency ${GREEN}$APT_DEPENDENCY${RESET}."
    return 0
}

function bind_controller_option_to_menu () {
    local MENU_CONTROLLER="$1"
    local MENU_OPTION="$2"
    local MENU_RESOURCE="$3"
    check_menu_controller_exists "$MENU_CONTROLLER"
    if [ $? -ne 0 ]; then
        error_msg "Initial menu controller ${RED}$MENU_CONTROLLER${RESET}"\
            "not found."
        return 1
    fi
    debug_msg "Confirmed menu controller"\
        "${GREEN}$MENU_CONTROLLER${RESET} exists."
    check_controller_option_exists "$MENU_CONTROLLER" "$MENU_OPTION"
    if [ $? -ne 0 ]; then
        error_msg "Menu controller option ${RED}$MENU_OPTION${RESET}"\
            "not found."
        return 2
    fi
    debug_msg "Confirmed ${CYAN}$MENU_CONTROLLER${RESET} controller"\
        "option ${GREEN}$MENU_OPTION${RESET} exists."
    check_menu_controller_exists "$MENU_RESOURCE"
    if [ $? -ne 0 ]; then
        error_msg "Endpoint menu controller ${RED}$MENU_RESOURCE${RESET}"\
            "not found."
        return 3
    fi
    debug_msg "Confirmed bind target menu controller"\
        "${GREEN}$MENU_RESOURCE${RESET} exists."
    CONTROLLER_JUMP_KEY=`format_menu_controller_jump_key \
        "$MENU_CONTROLLER" "$MENU_OPTION"`
    debug_msg "${CYAN}$MENU_CONTROLLER${RESET} controller jump key is"\
        "${GREEN}$CONTROLLER_JUMP_KEY${RESET}."
    NEXT_MENU_OPTIONS=( `fetch_all_menu_controller_options "$MENU_CONTROLLER"` )
    debug_msg "${CYAN}$MENU_CONTROLLER${RESET} options are"\
        "${YELLOW}${NEXT_MENU_OPTIONS[@]}${RESET}."
    FUNCTION_RESOURCE=`format_menu_controller_jumper_function_resource \
        "$MENU_RESOURCE"`
    debug_msg "Function resource for controller option"\
        "${YELLOW}$MENU_OPTION${RESET} is ${GREEN}$FUNCTION_RESOURCE${RESET}."
    set_menu_controller_action_key "$CONTROLLER_JUMP_KEY" "$FUNCTION_RESOURCE"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        error_msg "Something went wrong."\
            "Could not set ${CYAN}$MENU_CONTROLLER${RESET}"\
            "option ${RED}$MENU_OPTION${RESET}"\
            "jump key ${RED}$CONTROLLER_JUMP_KEY${RESET}."
    fi
    return $EXIT_CODE
}

function bind_controller_option_to_action () {
    local MENU_CONTROLLER="$1"
    local MENU_OPTION="$2"
    local FUNCTION_RESOURCE="$3"
    check_menu_controller_exists "$MENU_CONTROLLER"
    if [ $? -ne 0 ]; then
        error_msg "Menu controller ${RED}$MENU_CONTROLLER${RESET}"\
            "not found."
        return 1
    fi
    check_controller_option_exists "$MENU_CONTROLLER" "$MENU_OPTION"
    if [ $? -ne 0 ]; then
        error_msg "Menu controller option ${RED}$MENU_OPTION${RESET}"\
            "not found."
        return 2
    fi
    check_function_is_defined "$FUNCTION_RESOURCE"
    if [ $? -ne 0 ]; then
        error_msg "Function ${RED}$FUNCTION_RESOURCE${RESET} not found."
        return 3
    fi
    CONTROLLER_ACTION_KEY=`format_menu_controller_action_key \
        "$MENU_CONTROLLER" "$MENU_OPTION"`
    set_menu_controller_action_key "$CONTROLLER_ACTION_KEY" "$FUNCTION_RESOURCE"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        error_msg "Something went wrong."\
            "Could not set ${CYAN}$MENU_CONTROLLER${RESET}"\
            "option ${RED}$MENU_OPTION${RESET}"\
            "action key ${RED}$CONTROLLER_ACTION_KEY${RESET}."
    fi
    return $EXIT_CODE
}

function bind_controller_option () {
    local BIND_TARGET="$1"
    local MENU_CONTROLLER="$2"
    local MENU_OPTION="$3"
    local OPTION_RESOURCE="$4"
    case "$BIND_TARGET" in
        'to_menu')
            bind_controller_option_to_menu "$MENU_CONTROLLER" \
                "$MENU_OPTION" "$OPTION_RESOURCE"
            ;;
        'to_action')
            bind_controller_option_to_action "$MENU_CONTROLLER" \
                "$MENU_OPTION" "$OPTION_RESOURCE"
            ;;
        *)
            error_msg "Invalid bind target ${RED}$BIND_TARGET${RESET}."
            return 1
            ;;
    esac
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not bind ${CYAN}$MENU_CONTROLLER${RESET} option"\
            "${RED}$MENU_OPTION${RESET} to target resource"\
            "${RED}$OPTION_RESOURCE${RESET}."
    else
        ok_msg "Menu option ${GREEN}$MENU_OPTION${RESET} bind to"\
            "${GREEN}$OPTION_RESOURCE${RESET} successful."
    fi
    return $EXIT_CODE
}

function remove_all_menu_controller_option_keys () {
    local MENU_CONTROLLER_LABEL="$1"
    REGEX_PATTERN="`fetch_action_key_regex_pattern`"
    KEY_COUNT=`fetch_action_key_count`
    CONTROLLER_ACTION_KEYS=( `fetch_action_keys` )
    SUCCESS_COUNT=0; FAILURE_COUNT=0
    for action_key in ${CONTROLLER_ACTION_KEYS[@]}; do
        check_string_matches_regex_pattern "$action_key" "$REGEX_PATTERN"
        if [ $? -ne 0 ]; then
            debug_msg "Skipping key $action_key."
            continue
        fi
        unset MD_CONTROLLER_OPTION_KEYS["$action_key"]
        if [ $? -ne 0 ]; then
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
            warning_msg "Something went wrong."\
                "Could not remove ${CYAN}$MENU_CONTROLLER_LABEL${RESET}"\
                "controller action key ${RED}$action_key${RESET}."
            continue
        fi
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        ok_msg "Successfully removed ${CYAN}$MENU_CONTROLLER_LABEL${RESET}"\
            "controller action key ${GREEN}$action_key${RESET}."
    done
    info_msg "Remove ${GREEN}$SUCCESS_COUNT${RESET}/${WHITE}$KEY_COUNT${RESET}"\
        "controller action keys. ${RED}$FAILURE_COUNT${RESET} removal failures."
    if [ $SUCCESS_COUNT -eq 0 ]; then
        warning_msg "No controller action keys removed."
        return 1
    fi
    return 0
}

function remove_menu_controller () {
    local MENU_CONTROLLER_LABEL="$1"
    check_menu_controller_exists "$MENU_CONTROLLER_LABEL"
    if [ $? -ne 0 ]; then
        warning_msg "Invalid menu controller"\
            "${RED}$MENU_CONTROLLER_LABEL${RESET}."
        return 1
    fi
    remove_all_menu_controller_option_keys "$MENU_CONTROLLER_LABEL"
    unset MD_CONTROLLERS["$MENU_CONTROLLER_LABEL"] &> /dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not remove menu controller"\
            "${RED}$MENU_CONTROLLER_LABEL${RESET}."
    else
        ok_msg "Successfully removed menu controller"\
            "${GREEN}$MENU_CONTROLLER_LABEL${RESET}."
    fi
    return $EXIT_CODE
}

function add_menu_controller () {
    local MENU_CONTROLLER_LABEL="$1"
    local MENU_CONTROLLER_DESCRIPTION="$2"
    set_menu_controller "$MENU_CONTROLLER_LABEL" "$MENU_CONTROLLER_DESCRIPTION"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not add new menu controller"\
            "${RED}$MENU_CONTROLLER_LABEL${RESET}."
    else
        ok_msg "Successfully added new menu controller"\
            "${GREEN}$MENU_CONTROLLER_LABEL${RESET}."
    fi
    return $EXIT_CODE
}

