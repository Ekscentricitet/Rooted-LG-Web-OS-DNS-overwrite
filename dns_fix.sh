#!/bin/bash
# Force the DNS resolver to use a custom DNS.

# Desired DNS configuration
DNS_ADDRESS="<YOUR_DNS_GOES_HERE>"  # Replace with your custom DNS address
LOG_FILE="dns_reset.log"
EXPECTED_DNS="nameserver $DNS_ADDRESS"
MAX_LOG_SIZE=1048576

# Delete the log file if it exceeds the log size.
if [ -f "$LOG_FILE" ]; then
    LOG_SIZE=$(stat -c %s "$LOG_FILE")
    if [ "$LOG_SIZE" -ge "$MAX_LOG_SIZE" ]; then
        rm -f "$LOG_FILE"
        echo "$(date) - Log file exceeded the max size. Deleted and recreated." > $LOG_FILE
    fi
else
    echo "$(date) - Log file not found, creating new one." > $LOG_FILE
fi

# Check if resolv.conf exists
if [ -f /etc/resolv.conf ]; then
    # Dump the current contents of resolv.conf into the log file
    echo "$(date) - Current /etc/resolv.conf contents before check:" >> $LOG_FILE
    cat /etc/resolv.conf >> $LOG_FILE

    # Read the current resolv.conf
    CURRENT_DNS=$(cat /etc/resolv.conf | grep "nameserver")

    # Check if the content is the same as expected
    if [[ "$CURRENT_DNS" == "$EXPECTED_DNS" ]]; then
        echo "$(date) - DNS is already set to $EXPECTED_DNS." >> $LOG_FILE
    else
        # Reset the DNS settings if it is not
        echo "$EXPECTED_DNS" > /etc/resolv.conf
        echo "$(date) - DNS has been reset to $EXPECTED_DNS." >> $LOG_FILE

    fi
else
    echo "$(date) - resolv.conf not found! Aborting." >> $LOG_FILE
fi
