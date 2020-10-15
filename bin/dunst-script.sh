#!/bin/sh

# The script will be called as follows:
#   script appname summary body icon urgency
# where urgency can be "LOW", "NORMAL" or "CRITICAL".

appname="${1}"
summary="${2}"
body="${3}"
icon="${4}"
urgency="${5}"

tty=/dev/cuaU0

printf 'appname: "%s"  summary: "%s"  body: "%s"  icon: "%s"  urgency: "%s"\n' "${appname}" "${summary}" "${body}" "${icon}" "${urgency}" >> /tmp/dunst.log

[ -c "${tty}" ] || exit 0
[ -d "${XDG_CACHE_HOME}" ] || exit 0

cache="${XDG_CACHE_HOME}/oled"
[ -d "${cache}" ] || mkdir "${cache}"

bg=
cleanup() {
  [ -n "${bg}" ] && kill "${bg}"
}
trap cleanup INT EXIT

inc_index() {
  n=$((n + 1))
  [ ${n} -gt 4 ] && n=1
  echo "${n}" > "${index}"
}

index="${cache}/index"
[ -f "${index}" ] || echo '1' > "${index}"
n=$(cat "${index}")

cat "${tty}" > /dev/null &
bg="${!}"
sleep 1

case "${appname}" in
  (Firefox)
    ma=$(printf '%s' "${summary}" | sed -E 's/New message (from|in) //')
    mb=$(printf '%s' "${body}" | sed -E 's/a message from //')
    opts='-background black -fill white -page 128x64 -size 128x64'
    image="$(convert ${opts} -font Noto-Sans-CJK-TC-Regular -pointsize 16 label:"${ma}"'\n'"${mb}" xbm:-)"
    inc_index

    cat <<EOF > "${tty}"

!U${n}\$
${image}
!11122\$
!23344\$

EOF
    true
    ;;
  (*)
    opts='-background black -fill white -page 128x64 -size 128x64'
    image="$(convert ${opts} -font Noto-Sans-CJK-TC-Regular -pointsize 16 label:"${appname}"'\n'"${icon}" xbm:-)"
    inc_index

    cat <<EOF > "${tty}"

!U${n}\$
${image}
!11122\$
!23344\$

EOF
    true
    ;;
esac
