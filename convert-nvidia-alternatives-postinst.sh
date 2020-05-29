#!/bin/sh

set -eu

private='nvidia/current'
new_private='nvidia/edc'

if ! [ -f "$1" ]; then
    echo "$1 is not a file" >&2
fi

dirs_exist() {
    local d
    for d in "$@"; do
	if [ -d "$d" ]; then
	    echo "$d"
	fi
    done
}

auto_major="$(sed -rn '/--install/{s/^.+([0-9]{3}).+$/\1/;p}' < "$1")"
major="${2:-$auto_major}"

echo "We think the postinst was for major version '$major'" >&2
echo "The resulting script might not work if it is not correct" >&2

cat "$1" |
sed "s,$private,$new_private,g" |
sed "s,$major,919,g" |
sed "\,add_slave /,d" |
sed "s,dpkg-trigger\s,\0--by-package nvidia-alternative ,g" |
sed -r "/^.+=\s+['\"]configure['\"].+\$/Q"

cat <<EOF
if [ "\$1" = remove ]; then
    update-alternatives --remove nvidia /usr/lib/$new_private
fi

if [ -z "\$1" ]; then
    exec "\$0" triggered
fi

EOF

exit 0
