#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# FORMATTERS

function format_menu_controller_jumper_function_resource () {
    local MENU_CONTROLLER_LABEL="$1"
    local FUNCTION_RESOURCE="init_menu $MENU_CONTROLLER_LABEL"
    echo "$FUNCTION_RESOURCE"
    return $?
}

function format_menu_controller_jump_key () {
    local MENU_CONTROLLER_LABEL="$1"
    local MENU_CONTROLLER_OPTION="$2"
    local FORMATTED_JUMP_KEY="$MENU_CONTROLLER_LABEL-jump-$MENU_CONTROLLER_OPTION"
    echo "$FORMATTED_JUMP_KEY"
    return $?
}

function format_menu_controller_action_key () {
    local MENU_CONTROLLER_LABEL="$1"
    local MENU_CONTROLLER_OPTION="$2"
    local FORMATTED_ACTION_KEY="$MENU_CONTROLLER_LABEL-$MENU_CONTROLLER_OPTION"
    echo "$FORMATTED_ACTION_KEY"
    return $?
}

function format_flag_colors () {
    local FLAG="$1"
    case "$FLAG" in
        'on')
            local DISPLAY="${GREEN}ON${RESET}"
            ;;
        'off')
            local DISPLAY="${RED}OFF${RESET}"
            ;;
        *)
            local DISPLAY=$FLAG
            ;;
    esac; echo $DISPLAY
    return 0
}

