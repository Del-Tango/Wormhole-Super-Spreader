#!/bin/bash
#
# Regards, the Alveare Solutions society.
#
# DISPLAY

function display_wormhole_banner () {
    figlet -f lean -w 1000 "$SCRIPT_NAME" > "${MD_DEFAULT['tmp-file']}"
    clear; echo -n "${RED}`cat ${MD_DEFAULT['tmp-file']}`${RESET}
    "
    echo -n > ${MD_DEFAULT['tmp-file']}
    return 0
}

function display_wormhole_settings () {
    echo "[ ${CYAN}Conf File${RESET}           ]: ${YELLOW}${MD_DEFAULT['conf-file']}${RESET}
[ ${CYAN}Log File${RESET}            ]: ${YELLOW}${MD_DEFAULT['log-file']}${RESET}
[ ${CYAN}Temporary File${RESET}      ]: ${YELLOW}${MD_DEFAULT['tmp-file']}${RESET}
[ ${CYAN}Imported Payload${RESET}    ]: ${YELLOW}${PW_IMPORTS['payload-file']}${RESET}
[ ${CYAN}File Editor${RESET}         ]: ${MAGENTA}${MD_DEFAULT['file-editor']}${RESET}
[ ${CYAN}Code Insertion Mode${RESET} ]: ${MAGENTA}${MD_DEFAULT['insertion-mode']}${RESET}
[ ${CYAN}Log Lines${RESET}           ]: ${WHITE}${MD_DEFAULT['log-lines']}${RESET}
[ ${CYAN}Loaded Payloads${RESET}     ]: ${WHITE}${#PW_PAYLOAD[@]}${RESET}
[ ${CYAN}Silent${RESET}              ]: ${MD_DEFAULT['silent']}
[ ${CYAN}Safety${RESET}              ]: $MD_SAFETY
" | column
    echo; return 0
}

