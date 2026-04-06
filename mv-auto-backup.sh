#!/usr/bin/env bash
# ============================================================================
# mv-auto-backup.sh - Wrapper for mv with automatic numbered backups
#
# This script overrides the 'mv' command in your shell. When moving a file
# into a directory that already contains a file with the same name, the
# existing file is renamed to 'filename.ext.001.bak', 'filename.ext.002.bak',
# etc. The backup is only performed inside $HOME and is disabled inside
# Python virtual environments (when VIRTUAL_ENV is set).
#
# Author: Jack (https://github.com/setuju, https://passwords.t.me/)
# Repository: https://github.com/setuju/bash-mv-auto-backup
# License: MIT
#
# FIX: Fixed octal interpretation of backup numbers (e.g., 008 caused error).
#      Now using base-10 conversion with 10#$num.
# ============================================================================

# ----------------------------------------------------------------------------
# mv() - Custom mv function with backup logic
# ----------------------------------------------------------------------------
mv() {
    # ------------------------------------------------------------------------
    # Helper function: Check if a directory is inside an active Python venv
    # ------------------------------------------------------------------------
    _is_in_venv() {
        local dir="$1"                    # Directory to check
        local venv_path="${VIRTUAL_ENV:-}" # Path to active venv (if any)

        # Only proceed if a virtual environment is active
        if [[ -n "$venv_path" ]]; then
            # Get absolute paths to avoid symlink issues
            local real_dir=$(realpath "$dir" 2>/dev/null || echo "$dir")
            local real_venv=$(realpath "$venv_path" 2>/dev/null || echo "$venv_path")
            # Return success (0) if the directory is inside the venv
            [[ "$real_dir" == "$real_venv"* ]] && return 0
        fi
        return 1  # Not in venv
    }

    # ------------------------------------------------------------------------
    # Step 1: Parse command line arguments
    #
    # We need to separate:
    #   - Options (like -i, -f, -n, -v, --)
    #   - Source files (one or more)
    #   - Destination (last argument)
    # ------------------------------------------------------------------------
    local opts=()          # Array for mv options
    local sources=()       # Array for source files/directories
    local dest=""          # Destination path
    local i=0
    local args=("$@")      # Copy all arguments into an array

    # Loop through each argument
    while [[ $i -lt ${#args[@]} ]]; do
        case "${args[$i]}" in
            --)  # End of options marker
                opts+=("--")               # Keep the '--' for mv
                ((i++))
                # Everything after '--' are sources
                while [[ $i -lt ${#args[@]} ]]; do
                    sources+=("${args[$i]}")
                    ((i++))
                done
                break
                ;;
            -*)  # Options start with a dash
                opts+=("${args[$i]}")
                ((i++))
                ;;
            *)   # Non-option: it's a source or destination
                sources+=("${args[$i]}")
                ((i++))
                ;;
        esac
    done

    # After parsing, we must have at least 2 arguments: source(s) + destination
    # If not, just call the original mv and exit (let it show the error)
    if [[ ${#sources[@]} -lt 2 ]]; then
        command mv "$@"
        return $?
    fi

    # The last element in sources is the destination
    dest="${sources[-1]}"
    unset 'sources[-1]'   # Remove it from the sources array

    # If no source remains, something is wrong; fallback to original mv
    if [[ ${#sources[@]} -eq 0 ]]; then
        command mv "$@"
        return $?
    fi

    # ------------------------------------------------------------------------
    # Step 2: Decide if backup should be performed
    #
    # Backup is allowed only if:
    #   - Destination is an existing directory
    #   - Destination is inside $HOME
    #   - Destination is NOT inside an active Python virtual environment
    # ------------------------------------------------------------------------
    if [[ -d "$dest" ]]; then
        # Get absolute paths for reliable comparison
        local target_dir_abs=$(realpath "$dest" 2>/dev/null || echo "$dest")
        local home_abs=$(realpath "$HOME" 2>/dev/null || echo "$HOME")

        local allow_backup=false

        # Check if destination is inside $HOME
        if [[ "$target_dir_abs" == "$home_abs"* ]]; then
            # Check if it's NOT inside a venv
            if ! _is_in_venv "$target_dir_abs"; then
                allow_backup=true
            fi
        fi

        # --------------------------------------------------------------------
        # Step 3: Perform backup for each source file
        # --------------------------------------------------------------------
        if [[ "$allow_backup" == true ]]; then
            # Process each source individually
            for src in "${sources[@]}"; do
                # Backup only regular files (not directories, symlinks, etc.)
                if [[ ! -f "$src" ]]; then
                    # Non-regular files: just move them normally
                    command mv "${opts[@]}" "$src" "$dest"
                    continue
                fi

                # Extract basename of the source
                local base=$(basename "$src")
                local target="$dest/$base"

                # Check if a file with the same name already exists in the destination
                if [[ -e "$target" ]]; then
                    # Split the basename into name and extension
                    local name="${base%.*}"          # Everything before the last dot
                    local ext=""
                    if [[ "$base" == *.* ]]; then
                        ext=".${base##*.}"          # The last dot and everything after
                    fi
                    # Edge case: filename starts with a dot and has no other dots
                    # e.g., .gitignore -> name=".gitignore", ext=""
                    if [[ -z "$name" ]]; then
                        name="$base"
                        ext=""
                    fi

                    # Find the highest existing backup number for this file
                    local max=0
                    # Pattern: name.ext.XXX.bak
                    # We use a glob to find all matching backup files
                    shopt -s nullglob   # Make pattern expand to nothing if no match
                    local backup_files=("$dest/$name${ext}".*.bak)
                    for f in "${backup_files[@]}"; do
                        if [[ -f "$f" ]]; then
                            # Extract the numeric part between the last dot and .bak
                            # Use sed to match the exact pattern and capture the number
                            local num=$(basename "$f" | sed -n "s/^${name//./\\.}${ext//./\\.}\.\([0-9]*\)\.bak$/\1/p")
                            if [[ -n "$num" && "$num" =~ ^[0-9]+$ ]]; then
                                # FIX: Convert number from octal to decimal to avoid "value too great for base" error
                                # Bash interprets numbers with leading zeros as octal (e.g., 008 is invalid).
                                # Using 10#$num forces base-10 interpretation.
                                num=$((10#$num))
                                (( num > max )) && max=$num
                            fi
                        fi
                    done
                    shopt -u nullglob   # Restore default behavior

                    # Next backup number (start from 1 if none exist)
                    local next=$((max + 1))
                    # Format with three leading zeros (e.g., 001, 010, 100)
                    local next_fmt
                    printf -v next_fmt "%03d" "$next"
                    local backup_name="${name}${ext}.${next_fmt}.bak"

                    # Rename the existing file to its backup name
                    command mv "$target" "$dest/$backup_name"
                fi

                # Finally, move the source file to the destination
                command mv "${opts[@]}" "$src" "$dest"
            done
        else
            # Backup not allowed: just forward all arguments to the original mv
            command mv "${opts[@]}" "${sources[@]}" "$dest"
        fi
    else
        # Destination is not a directory: call original mv as is
        command mv "$@"
    fi
}

#==============================================================================
# End of script #SERVER is DOWN #MAINHACK BROTHERHOOD https://serverisdown.t.me/
# ==============================================================================
