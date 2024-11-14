#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

AETHERSX2_CFG="/storage/.config/aethersx2/inis/PCSX2.ini"
LOG_FILE="/var/log/cheevos.log"

# Extract username and password from emuelec.conf
username=$(get_setting "global.retroachievements.username")
password=$(get_setting "global.retroachievements.password")
token=$(get_setting "global.retroachievements.token")
enabled=$(get_setting "global.retroachievements")

if [ ! ${enabled} = 1 ]; then
    echo "RetroAchievements are not enabled, please turn them on in Emulation Station." > ${LOG_FILE}
    sed -i '/\[Achievements\]/,/^\s*$/s/Enabled =.*/Enabled = false/' ${AETHERSX2_CFG}
    exit 1
fi

# Test the token if empty exit 1.
if [ -z "${token}" ]; then
    echo "RetroAchievements token is empty, please log in with your RetroAchievements credentials in Emulation Station." > ${LOG_FILE}
    exit 1
fi

# Variables for checking if [Cheevos] or enabled true or false are present.
zcheevos=$(grep -Fx "[Achievements]" ${AETHERSX2_CFG})
datets=$(date +%s%N | cut -b1-13)

if [ -z "${zcheevos}" ]; then
    sed -i "\$a [Achievements]\nEnabled = true\nUsername = ${username}\nToken = ${token}\nLoginTimestamp = ${datets}" ${AETHERSX2_CFG}
else
    sed -i '/\[Achievements\]/,/^\s*$/s/Enabled =.*/Enabled = true/' ${AETHERSX2_CFG}

    if ! grep -q "^Username = " ${AETHERSX2_CFG}; then
        sed -i "/^\[Achievements\]/a Username = ${username}" ${AETHERSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^Username = .*/Username = ${username}/;}" ${AETHERSX2_CFG}
    fi

    if ! grep -q "^Token = " ${AETHERSX2_CFG}; then
        sed -i "/^\[Achievements\]/a Token = ${token}" ${AETHERSX2_CFG}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${AETHERSX2_CFG}
    fi
    sed -i "/^\[Achievements\]/,/^\[/{s/^LoginTimestamp = .*/LoginTimestamp = ${datets}/;}" ${AETHERSX2_CFG}
fi
