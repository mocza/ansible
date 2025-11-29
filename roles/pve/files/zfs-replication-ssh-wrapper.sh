#!/bin/bash
# SSH forced-command wrapper for zfs-replication user
# Only allows sudo zfs commands for syncoid replication
# Also allows basic connection test commands (echo, true, test) for syncoid connectivity checks

# Get the original command from SSH_ORIGINAL_COMMAND
ORIGINAL_CMD="${SSH_ORIGINAL_COMMAND}"

# If no command was provided, deny access
if [ -z "$ORIGINAL_CMD" ]; then
    echo "Access denied: No command provided" >&2
    exit 1
fi

# Extract the command (first word)
CMD=$(echo "$ORIGINAL_CMD" | awk '{print $1}')

# Allow basic connection test commands used by syncoid
if [ "$CMD" = "echo" ] || [ "$CMD" = "true" ] || [ "$CMD" = "test" ]; then
    exec $ORIGINAL_CMD
fi

# Allow sudo zfs commands (syncoid uses sudo to run zfs commands)
if [ "$CMD" = "sudo" ]; then
    # Extract the actual command after sudo
    SUDO_CMD=$(echo "$ORIGINAL_CMD" | sed 's/^sudo\s*\(-[a-zA-Z0-9]\+\s*\)*//' | awk '{print $1}')
    
    # Only allow zfs commands via sudo
    if [ "$SUDO_CMD" != "zfs" ]; then
        echo "Access denied: Only 'sudo zfs' commands are allowed (got: $CMD $SUDO_CMD)" >&2
        exit 1
    fi
    
    # Extract the zfs subcommand
    ZFS_SUBCMD=$(echo "$ORIGINAL_CMD" | sed 's/^sudo\s*\(-[a-zA-Z0-9]\+\s*\)*//' | awk '{print $2}')
    
    # Allow list, send, and receive subcommands
    if [ "$ZFS_SUBCMD" != "send" ] && [ "$ZFS_SUBCMD" != "receive" ] && [ "$ZFS_SUBCMD" != "list" ]; then
        echo "Access denied: Only 'sudo zfs list', 'sudo zfs send' and 'sudo zfs receive' commands are allowed (got: sudo zfs $ZFS_SUBCMD)" >&2
        exit 1
    fi
    
    # Execute the sudo command
    exec $ORIGINAL_CMD
fi

# Deny all other commands
echo "Access denied: Only 'sudo zfs' commands or connection tests are allowed (got: $CMD)" >&2
exit 1

