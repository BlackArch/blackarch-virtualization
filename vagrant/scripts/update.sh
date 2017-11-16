#!/usr/bin/env bash
# This script will update the build iso and checksum for black arch
YEAR=$(date +%Y)
MONTH=$(date +%m)


function set_checksum()
{
	MD5SUM=$(curl --silent https://mirror.rackspace.com/archlinux/iso/${YEAR}.${MONTH}.01/md5sums.txt | grep archlinux-${YEAR}.${MONTH}.01-x86_64.iso | awk ' { print $1 } ')
	echo "updating checksum"
	sed -i "s/\"iso_checksum\": \"[a-z0-9].*/\"iso_checksum\": \"$MD5SUM\",/g" template.json
}

function set_iso_file()
{
	if curl -s --output /dev/null --silent --head --fail "https://mirror.rackspace.com/archlinux/iso/${YEAR}.${MONTH}.01/archlinux-${YEAR}.${MONTH}.01-x86_64.iso"; then
		echo "updating URL"
		sed -i "s;\"iso_url\": \"http.*\",$;\"iso_url\": \"https://mirror.rackspace.com/archlinux/iso/${YEAR}.${MONTH}.01/archlinux-${YEAR}.${MONTH}.01-x86_64.iso\",;g" template.json
		set_checksum
		return 0
	else
		if ${MONTH} -eq 1; then
			MONTH=12
			$((YEAR--))
		else
			$((MONTH--))
		fi
		set_iso_file
	fi
}
set_iso_file
