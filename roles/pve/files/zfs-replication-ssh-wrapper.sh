#!/bin/bash
# SSH forced-command wrapper for zfs-replication user
# Only allows zfs send and zfs receive commands for syncoid replication
# Also allows basic connection test commands (echo, true, test) for syncoid connectivity checks

# Get the original command from SSH_ORIGINAL_COMMAND
ORIGINAL_CMD="${SSH_ORIGINAL_COMMAND}"

# Debug logging (remove after troubleshooting)
echo "DEBUG: SSH_ORIGINAL_COMMAND=[$SSH_ORIGINAL_COMMAND]" >&2
echo "DEBUG: ORIGINAL_CMD=[$ORIGINAL_CMD]" >&2

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

# Only allow zfs commands
if [ "$CMD" != "zfs" ]; then
    echo "Access denied: Only zfs commands are allowed" >&2
    exit 1
fi

# Extract the zfs subcommand (second word)
ZFS_SUBCMD=$(echo "$ORIGINAL_CMD" | awk '{print $2}')

# Allow list subcommand (needed by syncoid to check if datasets exist)
# Allow send and receive subcommands (needed for replication)
if [ "$ZFS_SUBCMD" != "send" ] && [ "$ZFS_SUBCMD" != "receive" ] && [ "$ZFS_SUBCMD" != "list" ]; then
    echo "Access denied: Only 'zfs list', 'zfs send' and 'zfs receive' commands are allowed" >&2
    exit 1
fi

# Execute the original command
exec $ORIGINAL_CMD

