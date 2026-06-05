#! /usr/bin/env bash

while true
do
	if pgrep bluetoothd >/dev/null
	then
		bt_device=$(bluetoothctl <<<info | awk -F ':' -- '/Name/ { sub(/ /, "", $2); print $2; }')
		bt_status=$([ -n "$bt_device" ] && echo -n "$bt_device" || echo -n "–")
	else
		bt_status=off
	fi

	if pgrep wpa_supplicant >/dev/null
	then
		wpa_status=$(wpa_cli status | awk -F '=' -- '/wpa_state.*/ { print $2; }')
		wifi_network=$(wpa_cli status | awk -F '=' -- '/^ssid.*/ { print $2; }')
		wifi_status=$([ $wpa_status = COMPLETED ] && echo -n "$wifi_network" || echo -n "–")
	else
		wifi_status=off
	fi

	if amixer >/dev/null
	then
		mic_status=$(amixer sget Capture | grep -oP '(?<=\[)[^]]+(?=\])' | head -n2 |
		if read level
		then
			read active
			echo -n $([ $active = on ] && echo -n "$level" || echo -n off)
		fi);

		speaker_status=$(amixer sget Master | grep -oP '(?<=\[)[^]]+(?=\])' | head -n2 |
		if read level
		then
			read active
			echo -n $([ $active = on ] && echo -n "$level" || echo -n off)
		fi);
	else
		mic_status=off
		speaker_status=off
	fi

	battery_path=/sys/class/power_supply/BAT0/
	battery_status="$(cat $battery_path/status), $(cat $battery_path/capacity)%"

	date_time=$(date +'%a %Y-%m-%d %H:%M')

	echo "Bluetooth: $bt_status | WIFI: $wifi_status | Mic: $mic_status | Speaker: $speaker_status | Battery: $battery_status | $date_time"
	sleep 1
done

