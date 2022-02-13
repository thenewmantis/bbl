#!/bin/sh
# bbl: Read the Holy Bible from your terminal
# License: Public domain

SELF="$0"
BIBLE=""

get_data() {
	sed '1,/^#EOF$/d' < "$SELF" | tar xz -O "$1"
}

if [ -z "$PAGER" ]; then
	if command -v less >/dev/null; then
		PAGER="less"
	else
		PAGER="cat"
	fi
fi

show_help() {
	exec >&2
	echo "usage: $(basename "$0") [flags] [bible] [reference...]"
	echo
        echo "  Flags:"
	echo "  -l, --list              list books"
	echo "  -W, --no-line-wrap      no line wrap"
        echo "  -c, --cat               echo text to STDOUT"
	echo "  -h, --help              show help"
        echo "  Bibles:"
	echo "  -d, --douay             Douay-Rheims Bible"
        echo "  -g, --greek             Greek Bible (Septuagint + SBL NT)"
	echo "  -j, --jerusalem         New Jerusalem Bible"
	echo "  -k, --kjv               King James Bible"
	echo "  -n, --knox              Knox Bible"
    echo "  -r, --rsv               Revised Standard Version: Catholic Edition"
	echo "  -v, --vulgate           Clementine Vulgate"
	echo
	echo "  Reference types:"
	echo "      <Book>"
	echo "          Individual book"
	echo "      <Book>:<Chapter>"
	echo "          Individual chapter of a book"
	echo "      <Book>:<Chapter>:<Verse>[,<Verse>]..."
	echo "          Individual verse(s) of a specific chapter of a book"
	echo "      <Book>:<Chapter>:<Verse>[,<Chapter>:<Verse>]..."
	echo "          Individual verses of different chapters of a book"
	echo "      <Book>:<Chapter>-<Chapter>"
	echo "          Range of chapters in a book"
	echo "      <Book>:<Chapter>:<Verse>-<Verse>"
	echo "          Range of verses in a book chapter"
	echo "      <Book>:<Chapter>:<Verse>-<Chapter>:<Verse>"
	echo "          Range of chapters and verses in a book"
	echo
	echo "      /<Search>"
	echo "          All verses that match a pattern"
	echo "      <Book>/<Search>"
	echo "          All verses in a book that match a pattern"
	echo "      <Book>:<Chapter>/<Search>"
	echo "          All verses in a chapter of a book that match a pattern"
    echo
	echo "      @ <Number-of-Verses>?"
	echo "          Random verse or assortment of verses from any book/chapter"
	echo "      <Book> @ <Number-of-Verses>?"
	echo "          Random verse or assortment of verses from any chapter in a given book"
	echo "      <Book>:<Chapter> @ <Number-of-Verses>?"
	echo "          Random verse or assortment of verses from the given book:chapter"
	exit 2
}

set_bible() {
    if [ -z "${BIBLE}" ]; then
        BIBLE=$1
    else
        #For cross-referencing
        BIBLE=${BIBLE}" "$1
    fi
}

opts="$(getopt -o lWchdgjknrv -l list,no-line-wrap,cat,help,douay,greek,jerusalem,kjv,knox,rsv,vulgate -- "$@")"
eval set -- "$opts"
while [ $# -gt 0 ]; do
    case $1 in
        --)
                shift
                break ;;
        -l|--list)
                # List all book names with their abbreviations
                get_data knx.tsv | awk -v cmd=list "$(get_data bbl.awk)"
                exit ;;
        -W|--no-line-wrap)
                export KJV_NOLINEWRAP=1
                shift ;;
        -c|--cat)
                # Cat text to standard output instead of using $PAGER
                PAGER=cat
                shift ;;
        -h|--help)
                show_help ;;
        -d|--douay)
                set_bible drb
                shift ;;
        -g|--greek)
                set_bible grb
                shift ;;
        -j|--jerusalem)
                set_bible njb
                shift ;;
        -k|--kjv)
                set_bible kjv
                shift ;;
        -n|--knox)
                set_bible knx
                shift ;;
        -r|--rsv)
                set_bible rsv
                shift ;;
        -v|--vulgate)
                set_bible vul
                shift ;;
         *)
                # Use Knox Bible if none is specified in command line options
                set_bible knx
                break ;;
    esac
done

cols=$(tput cols 2>/dev/null)
if [ $? -eq 0 ]; then
        versions=0
        for b in $BIBLE; do
            versions=$(( versions + 1 ))
        done
        [ $versions -eq 0 ] && versions=1 # For interactive mode
        spaceBetween=$(( 8 * (versions - 1)))
        export KJV_MAX_WIDTH="$(( (cols - spaceBetween) / versions ))"
fi

if [ $# -eq 0 ]; then
	if [ ! -t 0 ]; then
		show_help
	fi

	# Interactive mode
	while true; do
		printf "knx> "
		if ! read -r ref; then
			break
		fi
		get_data knx.tsv | awk -v cmd=ref -v ref="$ref" "$(get_data bbl.awk)" | ${PAGER}
	done
	exit 0
fi

i=0
myTempDir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
for version in $BIBLE; do
    get_data ${version}.tsv 2>/dev/null | awk -v cmd=ref -v ref="$*" -v cross_ref="${i}" "$(get_data bbl.awk)" 2>/dev/null > "${myTempDir}/${i}-${version}.txt"
    i=$((i + 1))
done

oldDir="$(pwd)"
cd "${myTempDir}"
if [ ${i} -gt 1 ]; then
    paste $(ls) -d "@" | column -t -s "@" -o "	" | sed '/^[a-zA-Z]/s/^/\t/;1s/^ *//;' | ${PAGER}
else
    myFile="$(ls)"
    fullPath="${myTempDir}/${myFile}"
    cd "${oldDir}"
    lastLine="$(tail -n1 ${fullPath})"

    echo $lastLine | grep -q '~~~RANDOMS:'
    if [ $? -eq 0 ]; then
        numberOfVerses=$(echo "${lastLine}" | grep -o '[0-9]*')
        linesInFile=$(($(wc -l "$fullPath" | awk '{print $1}') - 1))
        sedCmd=$(shuf -i 1-$linesInFile -n $numberOfVerses | sort -n | tr '\n' ' ' | sed 's/ /p;/g' | sed 's/..$/{p;q}/')
        sed -n "$sedCmd" "$fullPath" > "${myTempDir}/randomVerses"
        awk -v cmd=clean "$(get_data bbl.awk)" "${myTempDir}/randomVerses" 2>/dev/null > "${fullPath}"
    fi

    ${PAGER} "${fullPath}"

fi
rm -rf "${myTempDir}"
