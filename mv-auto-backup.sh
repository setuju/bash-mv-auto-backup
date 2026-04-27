#!/usr/bin/env bash
# ============================================================================
# mv-auto-backup.sh - Timestamped backup wrapper for the `mv` command
# ============================================================================
#
# When moving a file or directory into a destination that already contains
# an entry with the same name, the existing entry is renamed to:
#   name.ext.YYYY-MM-DD--HH-MM-SS.bak
#
# Example:
#   A.cpp.2026-04-27--15-30-22.bak
#   my_folder.2026-04-27--23-59-59.bak
#
# The backup only applies inside $HOME and is disabled when the target
# directory resides inside an active Python virtual environment.
#
# Author: Jack (https://github.com/setuju, https://passwords.t.me/)
# Repository: https://github.com/setuju/bash-mv-auto-backup
# License: MIT
# ============================================================================

mv() {
    # ------------------------------------------------------------------------
    # Helper: check if a directory is inside an active Python venv
    # ------------------------------------------------------------------------
    _is_in_venv() {
        local dir="$1"
        local venv_path="${VIRTUAL_ENV:-}"
        if [[ -n "$venv_path" ]]; then
            local real_dir=$(realpath "$dir" 2>/dev/null || echo "$dir")
            local real_venv=$(realpath "$venv_path" 2>/dev/null || echo "$venv_path")
            [[ "$real_dir" == "$real_venv"* ]] && return 0
        fi
        return 1
    }

    # ------------------------------------------------------------------------
    # Parse arguments: separate options, sources, and destination
    # ------------------------------------------------------------------------
    local opts=()
    local sources=()
    local dest=""
    local i=0
    local args=("$@")

    while [[ $i -lt ${#args[@]} ]]; do
        case "${args[$i]}" in
            --)
                opts+=("--")
                ((i++))
                while [[ $i -lt ${#args[@]} ]]; do
                    sources+=("${args[$i]}")
                    ((i++))
                done
                break
                ;;
            -*)
                opts+=("${args[$i]}")
                ((i++))
                ;;
            *)
                sources+=("${args[$i]}")
                ((i++))
                ;;
        esac
    done

    # If not enough arguments (source + destination), call the original mv
    if [[ ${#sources[@]} -lt 2 ]]; then
        command mv "$@"
        return $?
    fi

    dest="${sources[-1]}"
    unset 'sources[-1]'

    if [[ ${#sources[@]} -eq 0 ]]; then
        command mv "$@"
        return $?
    fi

    # ------------------------------------------------------------------------
    # Decide whether backup is allowed
    # ------------------------------------------------------------------------
    if [[ -d "$dest" ]]; then
        local target_dir_abs=$(realpath "$dest" 2>/dev/null || echo "$dest")
        local home_abs=$(realpath "$HOME" 2>/dev/null || echo "$HOME")
        local allow_backup=false

        # Only inside $HOME and NOT inside a Python venv
        if [[ "$target_dir_abs" == "$home_abs"* ]]; then
            _is_in_venv "$target_dir_abs" || allow_backup=true
        fi

        if [[ "$allow_backup" == true ]]; then
            for src in "${sources[@]}"; do
                local base
                base=$(basename "$src")
                local target="$dest/$base"

                # ------------------------------------------------------------
                # If the target already exists (file OR directory), backup first
                # ------------------------------------------------------------
                if [[ -e "$target" ]]; then
                    local name="${base%.*}"
                    local ext=""
                    if [[ "$base" == *.* ]]; then
                        ext=".${base##*.}"
                    fi
                    if [[ -z "$name" ]]; then
                        name="$base"
                        ext=""
                    fi

                    local timestamp
                    timestamp=$(date +"%Y-%m-%d--%H-%M-%S")
                    local backup_name="${name}${ext}.${timestamp}.bak"

                    # Avoid clash when the same second occurs
                    local counter=1
                    while [[ -e "$dest/$backup_name" ]]; do
                        backup_name="${name}${ext}.${timestamp}_${counter}.bak"
                        ((counter++))
                    done

                    # Rename the existing file/directory
                    command mv "$target" "$dest/$backup_name"
                fi

                # Move the source (file or directory)
                command mv "${opts[@]}" "$src" "$dest"
            done
        else
            command mv "${opts[@]}" "${sources[@]}" "$dest"
        fi
    else
        command mv "$@"
    fi
}

# ==============================================================================
# End of script #SERVER is DOWN #MAINHACK BROTHERHOOD https://serverisdown.t.me/
# ==============================================================================
