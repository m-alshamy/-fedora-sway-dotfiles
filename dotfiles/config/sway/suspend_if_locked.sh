#!/bin/bash
if pgrep -x "swaylock" > /dev/null; then
    systemctl suspend
fi
