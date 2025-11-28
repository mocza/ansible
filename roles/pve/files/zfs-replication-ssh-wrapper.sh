#!/bin/bash
# SSH forced-command wrapper for zfs-replication user
# Only allows zfs send and zfs receive commands for syncoid replication
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

# Only allow zfs commands
if [ "$CMD" != "zfs" ]; then
    echo "Access denied: Only zfs commands are allowed" >&2
    exit 1
fi

# Extract the zfs subcommand (second word)
ZFS_SUBCMD=$(echo "$ORIGINAL_CMD" | awk '{print $2}')

# Only allow send and receive subcommands
if [ "$ZFS_SUBCMD" != "send" ] && [ "$ZFS_SUBCMD" != "receive" ]; then
    echo "Access denied: Only 'zfs send' and 'zfs receive' commands are allowed" >&2
    exit 1
fi

# Execute the original command
exec $ORIGINAL_CMD

