#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# LOADERS

function load_wormhole_config () {
    load_wormhole_script_name
    load_wormhole_prompt_string
    load_wormhole_safety
    load_settings_wormhole_default
    load_wormhole_logging_levels
}

function load_wormhole_safety () {
    if [ -z "$PW_SAFETY" ]; then
        warning_msg "No default safety flag value found. Defaulting to $MD_SAFETY."
        return 1
    fi
    MD_SAFETY=$PW_SAFETY
    check_item_in_set "$MD_SAFETY" 'on' 'off'
    if [ $? -ne 0 ]; then
        nok_msg "Invalid safety flag value (${RED}$MD_SAFETY${RESET})."
    else
        ok_mg "Successfully loaded safety flag value"\
            "(${GREEN}$MD_SAFETY${RESET})."
    fi
    return 0
}

function load_wormhole_prompt_string () {
    if [ -z "$PW_PS3" ]; then
        warning_msg "No default prompt string found. Defaulting to $MD_PS3."
        return 1
    fi
    set_project_prompt "$PW_PS3"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not load prompt string ${RED}$PW_PS3${RESET}."
    else
        ok_msg "Successfully loaded"\
            "prompt string ${GREEN}$PW_PS3${RESET}"
    fi
    return $EXIT_CODE
}

function load_wormhole_logging_levels () {
    if [ ${#PW_LOGGING_LEVELS[@]} -eq 0 ]; then
        warning_msg "No ${BLUE}$SCRIPT_NAME${RESET} logging levels found."
        return 1
    fi
    MD_LOGGING_LEVELS=( ${PW_LOGGING_LEVELS[@]} )
    ok_msg "Successfully loaded ${BLUE}$SCRIPT_NAME${RESET} logging levels."
    return 0
}

function load_settings_wormhole_default () {
    if [ ${#PW_DEFAULT[@]} -eq 0 ]; then
        warning_msg "No ${BLUE}$SCRIPT_NAME${RESET} defaults found."
        return 1
    fi
    for wormhole_setting in ${!PW_DEFAULT[@]}; do
        MD_DEFAULT[$wormhole_setting]=${PW_DEFAULT[$wormhole_setting]}
        ok_msg "Successfully loaded ${BLUE}$SCRIPT_NAME${RESET}"\
            "default setting"\
            "(${GREEN}$wormhole_setting - ${PW_DEFAULT[$wormhole_setting]}${RESET})."
    done
    done_msg "Successfully loaded ${BLUE}$SCRIPT_NAME${RESET} default settings."
    return 0
}

function load_wormhole_script_name () {
    if [ -z "$PW_SCRIPT_NAME" ]; then
        warning_msg "No default script name found. Defaulting to $SCRIPT_NAME."
        return 1
    fi
    set_project_name "$PW_SCRIPT_NAME"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        nok_msg "Something went wrong."\
            "Could not load script name ${RED}$PW_SCRIPT_NAME${RESET}."
    else
        ok_msg "Successfully loaded"\
            "script name ${GREEN}$PW_SCRIPT_NAME${RESET}"
    fi
    return $EXIT_CODE
}

# SETUP

function wormhole_project_setup () {
    lock_and_load
    load_wormhole_config
    create_wormhole_menu_controllers
    setup_wormhole_menu_controllers
}

function setup_wormhole_menu_controllers () {
    setup_wormhole_dependencies
    setup_main_menu_controller
    setup_log_viewer_menu_controller
    setup_settings_menu_controller
    setup_wormhole_menu_controller
    done_msg "${BLUE}$SCRIPT_NAME${RESET} controller setup complete."
    return 0
}

# SETUP DEPENDENCIES

function setup_wormhole_dependencies () {
    setup_wormhole_apt_dependencies
    return 0
}

function setup_wormhole_apt_dependencies () {
    if [ ${#PW_APT_DEPENDENCIES[@]} -eq 0 ]; then
        warning_msg "No ${RED}$SCRIPT_NAME${RESET} apt dependencies found"\
            "to install using APT."
        return 1
    fi
    FAILURE_COUNT=0
    SUCCESS_COUNT=0
    for util in ${PW_APT_DEPENDENCIES[@]}; do
        add_apt_dependency "$util"
        if [ $? -ne 0 ]; then
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
        else
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        fi
    done
    done_msg "(${GREEN}$SUCCESS_COUNT${RESET}) ${BLUE}$SCRIPT_NAME${RESET}"\
        "dependencies staged for installation using the APT package manager."\
        "(${RED}$FAILURE_COUNT${RESET}) failures."
    return 0
}

# WORMHOLE MENU SETUP

function setup_wormhole_menu_controller () {
    setup_wormhole_menu_option_release_super_spreader
    setup_wormhole_menu_option_controlled_test_run
    setup_wormhole_menu_option_help
    setup_wormhole_menu_option_back
    done_msg "(${CYAN}$WORMHOLE_CONTROLLER_LABEL${RESET}) controller"\
        "option binding complete."
    return 0
}

function setup_wormhole_menu_option_release_super_spreader () {
    info_msg "Binding ${CYAN}$WORMHOLE_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Release-Super-Spreader${RESET}"\
        "to function ${MAGENTA}action_release_super_spreader${RESET}..."
    bind_controller_option \
        'to_action' "$WORMHOLE_CONTROLLER_LABEL" \
        'Release-Super-Spreader' "action_release_super_spreader"
    return $?
}

function setup_wormhole_menu_option_controlled_test_run () {
    info_msg "Binding ${CYAN}$WORMHOLE_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Release-Super-Spreader${RESET}"\
        "to function ${MAGENTA}action_release_super_spreader${RESET}..."
    bind_controller_option \
        'to_action' "$WORMHOLE_CONTROLLER_LABEL" \
        'Controlled-Test-Run' "action_controlled_test_run"
    return $?
}

function setup_wormhole_menu_option_help () {
    info_msg "Binding ${CYAN}$WORMHOLE_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Help${RESET}"\
        "to function ${MAGENTA}action_wormhole_help${RESET}..."
    bind_controller_option \
        'to_action' "$WORMHOLE_CONTROLLER_LABEL" \
        'Help' "action_wormhole_help"
    return $?
}

function setup_wormhole_menu_option_back () {
    info_msg "Binding ${CYAN}$WORMHOLE_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Back${RESET}"\
        "to function ${MAGENTA}action_back${RESET}..."
    bind_controller_option \
        'to_action' "$WORMHOLE_CONTROLLER_LABEL" 'Back' "action_back"
    return $?
}

# MAIN MENU SETUP

function setup_main_menu_controller () {
    setup_main_menu_option_wormhole
    setup_main_menu_option_log_viewer
    setup_main_menu_option_control_panel
    setup_main_menu_option_self_destruct
    setup_main_menu_option_back
    done_msg "${CYAN}$MAIN_CONTROLLER_LABEL${RESET} controller option"\
        "binding complete."
    return 0
}

function setup_main_menu_option_self_destruct () {
    info_msg "Binding ${CYAN}$MAIN_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Self-Destruct${RESET}"\
        "to action ${MAGENTA}action_self_destruct${RESET}..."
    bind_controller_option \
        'to_action' "$MAIN_CONTROLLER_LABEL" \
        'Self-Destruct' "action_self_destruct"
    return $?
}

function setup_main_menu_option_wormhole () {
    info_msg "Binding ${CYAN}$MAIN_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Wormhole${RESET}"\
        "to controller ${MAGENTA}$WORMHOLE_CONTROLLER_LABEL${RESET}..."
    bind_controller_option \
        'to_menu' "$MAIN_CONTROLLER_LABEL" \
        'Wormhole' "$WORMHOLE_CONTROLLER_LABEL"
    return $?
}

function setup_main_menu_option_log_viewer () {
    info_msg "Binding ${CYAN}$MAIN_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Log-Viewer${RESET}"\
        "to controller ${CYAN}$LOGVIEWER_CONTROLLER_LABEL${RESET}..."
    bind_controller_option \
        'to_menu' "$MAIN_CONTROLLER_LABEL" \
        'Log-Viewer' "$LOGVIEWER_CONTROLLER_LABEL"
    return $?
}

function setup_main_menu_option_control_panel () {
    info_msg "Binding ${CYAN}$MAIN_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Control-Panel${RESET}"\
        "to controller ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET}..."
    bind_controller_option \
        'to_menu' "$MAIN_CONTROLLER_LABEL" \
        'Control-Panel' "$SETTINGS_CONTROLLER_LABEL"
    return $?
}

function setup_main_menu_option_back () {
    info_msg "Binding ${CYAN}$MAIN_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Back${RESET}"\
        "to function ${MAGENTA}action_back${RESET}..."
    bind_controller_option \
        'to_action' "$MAIN_CONTROLLER_LABEL" 'Back' "action_back"
    return $?
}

# LOG VIEWER MENU SETUP

function setup_log_viewer_menu_controller () {
    setup_log_viewer_menu_option_display_tail
    setup_log_viewer_menu_option_display_head
    setup_log_viewer_menu_option_display_more
    setup_log_viewer_menu_option_clear_log_file
    setup_log_viewer_menu_option_back
    done_msg "${CYAN}$LOGVIEWER_CONTROLLER_LABEL${RESET} controller option"\
        "binding complete."
    return 0
}

function setup_log_viewer_menu_option_clear_log_file () {
    info_msg "Binding ${CYAN}$LOGVIEWER_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Clear-Log${RESET}"\
        "to function ${MAGENTA}action_clear_log_file${RESET}..."
    bind_controller_option \
        'to_action' "$LOGVIEWER_CONTROLLER_LABEL" \
        'Clear-Log' "action_clear_log_file"
    return $?
}

function setup_log_viewer_menu_option_display_tail () {
    info_msg "Binding ${CYAN}$LOGVIEWER_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Display-Tail${RESET}"\
        "to function ${MAGENTA}action_display_log_tail${RESET}..."
    bind_controller_option \
        'to_action' "$LOGVIEWER_CONTROLLER_LABEL" \
        'Display-Tail' "action_log_view_tail"
    return $?
}

function setup_log_viewer_menu_option_display_head () {
    info_msg "Binding ${CYAN}$LOGVIEWER_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Display-Head${RESET}"\
        "to function ${MAGENTA}action_display_log_head${RESET}..."
    bind_controller_option \
        'to_action' "$LOGVIEWER_CONTROLLER_LABEL" \
        'Display-Head' "action_log_view_head"
    return $?
}

function setup_log_viewer_menu_option_display_more () {
    info_msg "Binding ${CYAN}$LOGVIEWER_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Display-More${RESET}"\
        "to function ${MAGENTA}action_display_log_more${RESET}..."
    bind_controller_option \
        'to_action' "$LOGVIEWER_CONTROLLER_LABEL" \
        'Display-More' "action_log_view_more"
    return $?
}

function setup_log_viewer_menu_option_back () {
    info_msg "Binding ${CYAN}$LOGVIEWER_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Back${RESET}"\
        "to function ${MAGENTA}action_back${RESET}..."
    bind_controller_option \
        'to_action' "$LOGVIEWER_CONTROLLER_LABEL" 'Back' "action_back"
    return $?
}

# SETTINGS MENU SETUP

function setup_settings_menu_controller () {
    setup_settings_menu_option_set_safety_off
    setup_settings_menu_option_set_safety_on
    setup_settings_menu_option_set_temporary_file
    setup_settings_menu_option_set_log_file
    setup_settings_menu_option_set_log_lines
    setup_settings_menu_option_set_file_editor
    setup_settings_menu_option_set_payload
    setup_settings_menu_option_set_silent_on
    setup_settings_menu_option_set_silent_off
    setup_settings_menu_option_set_victim_directory
    setup_settings_menu_option_set_code_insertion_mode
    setup_settings_menu_option_import_payload_file
    setup_settings_menu_option_edit_payload_file
    setup_settings_menu_option_install_dependencies
    setup_settings_menu_option_back
    done_msg "${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} controller option"\
        "binding complete."
    return 0
}

function setup_settings_menu_option_set_payload () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Payload${RESET}"\
        "to function ${MAGENTA}action_set_payload${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Payload" 'action_set_payload'
    return $?
}

function setup_settings_menu_option_set_silent_on () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Silent-ON${RESET}"\
        "to function ${MAGENTA}action_set_silent_flag_on${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Silent-ON" 'action_set_silent_flag_on'
    return $?
}

function setup_settings_menu_option_set_silent_off () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Silent-OFF${RESET}"\
        "to function ${MAGENTA}action_set_silent_flag_off${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Silent-OFF" 'action_set_silent_flag_off'
    return $?
}

function setup_settings_menu_option_set_victim_directory () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Victim-Directory${RESET}"\
        "to function ${MAGENTA}action_set_victim_directory_path${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Victim-Directory" 'action_set_victim_directory_path'
    return $?
}

function setup_settings_menu_option_set_code_insertion_mode () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Insertion-Mode${RESET}"\
        "to function ${MAGENTA}action_set_code_insertiom_mode${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Insertion-Mode" 'action_set_code_insertion_mode'
    return $?
}

function setup_settings_menu_option_import_payload_file () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Import-Payload${RESET}"\
        "to function ${MAGENTA}action_import_payload_file${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Import-Payload" 'action_import_payload_file'
    return $?
}

function setup_settings_menu_option_edit_payload_file () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Edit-Payload${RESET}"\
        "to function ${MAGENTA}action_edit_payload_file${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Edit-Payload" 'action_edit_payload_file'
    return $?
}

function setup_settings_menu_option_set_safety_on () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Safety-ON${RESET}"\
        "to function ${MAGENTA}action_set_safety_on${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Safety-ON" 'action_set_safety_on'
    return $?
}

function setup_settings_menu_option_set_safety_off () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Safety-OFF${RESET}"\
        "to function ${MAGENTA}action_set_safety_off${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Safety-OFF" 'action_set_safety_off'
    return $?
}

function setup_settings_menu_option_set_file_editor () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-File-Editor${RESET}"\
        "to function ${MAGENTA}action_set_file_editor${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-File-Editor" 'action_set_file_editor'
    return $?
}

function setup_settings_menu_option_set_temporary_file () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Temporary-File${RESET}"\
        "to function ${MAGENTA}action_set_temporary_file${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Temporary-File" 'action_set_temporary_file'
    return $?
}

function setup_settings_menu_option_set_log_file () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Log-File${RESET}"\
        "to function ${MAGENTA}action_set_log_file${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Log-File" 'action_set_log_file'
    return $?
}

function setup_settings_menu_option_set_log_lines () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Set-Log-Lines${RESET}"\
        "to function ${MAGENTA}action_set_log_lines${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Set-Log-Lines" 'action_set_log_lines'
    return $?
}

function setup_settings_menu_option_install_dependencies () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Install-Dependencies${RESET}"\
        "to function ${MAGENTA}action_install_dependencies${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" \
        "Install-Dependencies" 'action_install_dependencies'
    return $?
}

function setup_settings_menu_option_back () {
    info_msg "Binding ${CYAN}$SETTINGS_CONTROLLER_LABEL${RESET} option"\
        "${YELLOW}Back${RESET}"\
        "to function ${MAGENTA}action_back${RESET}..."
    bind_controller_option \
        'to_action' "$SETTINGS_CONTROLLER_LABEL" 'Back' "action_back"
    return $?
}

# CODE DUMP

