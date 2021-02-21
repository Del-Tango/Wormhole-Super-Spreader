#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# INSTALLERS

function pip3_install_dependency () {
    local LIBRARY="$1"
    check_python3_library_installed "$LIBRARY"
    symbol_msg "${GREEN}+${RESET}" \
        "Installing library ${YELLOW}$LIBRARY${RESET}..."
    pip3 install $LIBRARY
    return $?
}

function pip3_install_dependencies () {
    if [ ${#PW_PIP3_DEPENDENCIES[@]} -eq 0 ]; then
        info_msg 'No dependencies to fetch using the pip3 package manager.'
        return 1
    elif [ $EUID -ne 0 ]; then
        warning_msg "${BLUE}$SCRIPT_NAME${RESET}"\
            "dependency install requires escalated privileges."
        info_msg "Try running ${YELLOW}$0${RESET} as root."
        return 2
    fi
    local FAILURE_COUNT=0
    info_msg "Installing dependencies using pip3 package manager:"
    for package in "${PW_PIP3_DEPENDENCIES[@]}"; do
        check_python3_library_installed "$LIBRARY"
        if [ $? -eq 0 ]; then
            ok_msg "${BLUE}$SCRIPT_NAME${RESET} dependency"\
                "${GREEN}$package${RESET} is already installed."
            continue
        fi
        pip3_install_dependency $package
        if [ $? -ne 0 ]; then
            nok_msg "Failed to install ${BLUE}$SCRIPT_NAME${RESET}"\
                "dependency ${RED}$package${RESET}!"
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
        else
            ok_msg "Successfully installed ${BLUE}$SCRIPT_NAME${RESET}"\
                "dependency ${GREEN}$package${RESET}."
            INSTALL_COUNT=$((INSTALL_COUNT + 1))
        fi
    done
    if [ $FAILURE_COUNT -ne 0 ]; then
        warning_msg "${RED}$FAILURE_COUNT${RESET} dependency"\
            "installation failures!"\
            "Try installing the packages manually ${GREEN}:)${RESET}"
    fi
    return 0
}

