#!/usr/bin/env bash

# Minimal Synth-Shell Installer for Fedora

# Include function to source other scripts
include() {
    local script="$1"
    if [ -f "$script" ]; then
        . "$script"
    else
        echo "Include failed: $script not found"
        exit 1
    fi
}

include 'bash-tools/bash-tools/user_io.sh'
include 'bash-tools/bash-tools/shell.sh'

# Function to install or uninstall scripts
installScript() {
    local operation=$1
    local script_name=$2

    if [ -z $INSTALL_DIR ]; then echo "INSTALL_DIR not set"; exit 1; fi
    if [ -z $RC_FILE ]; then echo "RC_FILE not set"; exit 1; fi
    if [ -z $CONFIG_DIR ]; then echo "CONFIG_DIR not set"; exit 1; fi

    local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    local script="${INSTALL_DIR}/${script_name}.sh"
    local source_script="${dir}/synth-shell/${script_name}.sh"

    local hook=$(printf '%s'\
        "\n## ${script_name}\n"\
        "if [ -f ${script} ] && [ -n \"\$( echo \$- | grep i )\" ]; then\n"\
        "\tsource ${script}\n"\
        "fi")

    case "$operation" in
        uninstall)
            sed -i "/## ${script_name}/,+4d" "$RC_FILE"
            rm -f "$script"
            ;;
        install)
            mkdir -p "$INSTALL_DIR"
            cp "$source_script" "$script"
            chmod 755 "$script"
            echo "$hook" >> "$RC_FILE"
            ;;
        *)
            echo "Usage: $0 {install|uninstall}"
            exit 1
            ;;
    esac
}

# User-specific installation
installerUser() {
    local option=$1
    local INSTALL_DIR="${HOME}/.config/synth-shell"
    local CONFIG_DIR="${HOME}/.config/synth-shell"
    local RC_FILE="${HOME}/.bashrc"

    case "$option" in
        uninstall) installScript uninstall "synth-shell-prompt" ;;
        install)   installScript install "synth-shell-prompt" ;;
        *)         echo "Usage: $0 {install|uninstall}"
                   exit 1 ;;
    esac
}

# Main installer function
installer() {
    local option=${1:-install}
    installerUser "$option"
}

installer "$@"
