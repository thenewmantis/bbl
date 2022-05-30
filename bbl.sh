#!/bin/sh
# bbl: Read the Holy Bible from your terminal
# License: Public domain

SELF="$0"
BIBLE=""

data_exists() {
    sed '1,/^#EOF$/d' < "$SELF" | tar tz "$1.tsv" > /dev/null 2>&1
}
get_data() {
	sed '1,/^#EOF$/d' < "$SELF" | tar xz -O "$1"
}
list_readings() {
    sed '1,/^#EOF$/d' < "$SELF" | tar tz --wildcards "*.tsv" | sed 's/\.tsv$//'
    exit 0
}

if [ ! -t 1 ]; then
    # If output is not a terminal, prevent the default behavior of opening the data in the pager only to send it down the pipeline
    PAGER="cat"
elif [ -z "$PAGER" ]; then
	if command -v less >/dev/null; then
		PAGER="less"
	else
		PAGER="cat"
	fi
fi

show_help() {
	exec >&2
	echo "usage: $(basename "$0") [flags] [reference...]"
	echo
    echo "  Flags:"
    echo "  -l, --list-books        list book names (for the reading chosen)"
    echo "  -L, --list              list options for readings (Vulgate, KJV, Latin poems, etc.)"
    echo "  -o                      choose a reading by name (i.e. by the name of the corresponding TSV file, sans file extension)"
	echo "  -W, --no-line-wrap      no line wrap"
	echo "  -V, --no-verse-numbers  no verse numbers are printed--just the book title at the top and a number for each chapter"
    echo "  -C, --no-ch-numbers     no chapter headings either (implies -V)"
    echo "  -T, --no-title          book title is not printed"
    echo "  -B, --no-verse-break    No linebreaks at the end of each verse--each chapter runs like a continuous paragraph. Currently implies -V (I am working on changing that)"
	echo "  -N, --no-format         Equivalent to -WCTB"
        echo "  -c, --cat               echo text to STDOUT"
	echo "  -h, --help              show help"
        echo "  Bibles:"
	echo "  -d, --douay             Douay-Rheims Bible"
    echo "  -g, --greek             Greek Bible (Septuagint + SBL NT)"
    echo "  -H, --hebrew            The Bible in Hebrew (with cantillation marks and niqqudim)"
	echo "  -i, --ivrit             The Bible in Hebrew without cantillation marks and niqqudim"
	echo "  -j, --jerusalem         New Jerusalem Bible"
	echo "  -k, --kjv               King James Bible"
	echo "  -n, --knox              Knox Bible"
        echo "  -r, --rsv               Revised Standard Version: Catholic Edition"
	echo "  -v, --vulgate           Clementine Vulgate"
    echo
    echo "Specify multiple versions to cross-reference (view them in multi-column fashion)."
    echo "This feature is not yet available for languages that are read right-to-left."
    echo "Specifying -i or -H will currently override all other translations and output only the Hebrew Bible."
	echo
	echo "  Reference types:"
    echo "  NOTE: The colon between book and chapter is required for Hebrew, optional for everything else."
    echo " References for Hebrew must be in Hebrew; for all else, must be in English."
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
	echo "      /~?<Search>"
	echo "          All verses that match a pattern"
	echo "      <Book>/~?<Search>"
	echo "          All verses in a book that match a pattern"
	echo "      <Book>:<Chapter>/~?<Search>"
	echo "          All verses in a chapter of a book that match a pattern"
	echo "      In searches, the optional ~ indicates that the search should be approximate:"
	echo "      Case and accent marks will be disregarded. Note that this will often take"
	echo "      much longer than an exact search"
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
    if [ -z "${BIBLE}" ] || [ "$nocrossref" ]; then
        BIBLE=$1
    else
        #For cross-referencing
        BIBLE=${BIBLE}" "$1
    fi
}
default_bible() {
    [ "$DEFAULT_BIBLE" ] && BIBLE="$DEFAULT_BIBLE" || BIBLE="knx"
}

lang="en" # Language of text being used--most are English
list=""
nocrossref=""
opts="$(getopt -o lLo:WVCTBNchdgHijknrv -l list-books,list,no-line-wrap,no-verse-numbers,no-chapter-headings,no-title,no-verse-break,-no-format,cat,help,douay,greek,hebrew,ivrit,jerusalem,kjv,knox,rsv,vulgate -- "$@")"
eval set -- "$opts"
while [ $# -gt 0 ]; do
    case $1 in
        --)
                shift
                break;;
        -l|--list-books)
                # List all book names of the named reading with their abbreviations
                list=1
                shift ;;
        -L|--list)
                list_readings ;;
        -o)
                shift
                nocrossref='y'
                data_exists "$1" && set_bible "$1" ||
                { echo "Error: $1.tsv not found."; exit 1
                }
                shift ;;
        -W|--no-line-wrap)
                export KJV_NOLINEWRAP=1
                shift ;;
        -V|--no-verse-numbers)
                export KJV_NOVERSENUMBERS=1
                shift ;;
        -C|--no-chapter-headings)
                export KJV_NOCHAPTERHEADINGS=1
                shift ;;
        -T|--no-title)
                export KJV_NOTITLE=1
                shift ;;
        -B|--no-verse-break)
                export KJV_NOVERSEBREAK=1
                shift ;;
        -N|--no-format)
                export KJV_NOFORMAT=1
                shift ;;
        -c|--cat)
                # Cat text to standard output instead of using $PAGER
                PAGER="cat"
                shift ;;
        -h|--help)
                show_help ;;
        -d|--douay)
                set_bible drb
                shift ;;
        -g|--greek)
                set_bible grb
                lang="el"
                shift ;;
        -H|--hebrew|-i|--ivrit)
                nocrossref='y'
                set_bible heb
                lang="he"
                # If reading in terminal, use `rev` to put it right-to-left
                case $1 in
                    -i|--ivrit)
                        r2l="y";;
                    *)
                        [ "$UNICODE_TERM" ] || noTerm='y' ;;
                esac
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
                lang="la"
                shift ;;
    esac
done

[ -z "$BIBLE" ] && default_bible

if [ "$list" ]; then
    get_data "$(echo "${BIBLE}" | cut -d " " -f 1).tsv" | awk -v cmd=list "$(get_data bbl.awk)" | ${PAGER}
    exit
fi

if cols=$(tput cols 2>/dev/null); then
        versions=0
        for b in $BIBLE; do
            versions=$(( versions + 1 ))
        done
        spaceBetween=$(( 8 * (versions - 1)))
        export KJV_MAX_WIDTH="$(( (cols - spaceBetween) / versions ))"
fi

if [ $# -eq 0 ]; then
	if [ ! -t 0 ]; then
		show_help
	fi

	# Interactive mode
    b="$(echo "$BIBLE" | cut -d ' ' -f 1)"
	while true; do
		printf '%s> ' "$b"
		if ! read -r ref; then
			break
		fi
		get_data "$b.tsv" | awk -v cmd=ref -v ref="$ref" -v lang="$lang" "$(get_data bbl.awk)" | ${PAGER}
	done
	exit 0
fi

i=0
tempDirPattern="${TMPDIR:-/tmp/}$(basename "$0")."
myTempDir=$(mktemp -d "${tempDirPattern}XXXXXXXXXXXX")
exitCode=0
for version in $BIBLE; do
    filename="${myTempDir}/${i}-${version}.txt"
    get_data "${version}".tsv 2>/dev/null | awk -v cmd=ref -v ref="$*" -v cross_ref="${i}" -v lang="$lang" "$(get_data bbl.awk)" 2>/dev/null > "$filename"
    i=$((i + 1))
done

if [ ${i} -gt 1 ]; then
    filename="${myTempDir}/crossref.txt"
    paste -d '@' $(ls -d "${myTempDir}/"*) | column -t -s "@" -o "	" | sed '/^[a-zA-Z]/s/^/\t/;1s/^ *//;' > "$filename"
    # Remove all files in the tmpdir with a hyphen in the name, i.e. everything except the file we just created
    rm "$myTempDir"/*-*
else
    lastLine="$(tail -n1 "${filename}")"

    if echo "$lastLine" | grep -q '~~~RANDOMS:'; then
        numberOfVerses=$(echo "${lastLine}" | grep -o '[0-9]*')
        linesInFile=$(($(wc -l "$filename" | awk '{print $1}') - 1))
        sedCmd=$(shuf -i 1-$linesInFile -n "$numberOfVerses" | sort -n | tr '\n' ' ' | sed 's/ /p;/g' | sed 's/..$/{p;q}/')
        sed -n "$sedCmd" "$filename" > "${myTempDir}/randomVerses"
        awk -v cmd=clean "$(get_data bbl.awk)" "${myTempDir}/randomVerses" 2>/dev/null > "${filename}"
    fi
fi

if [ "$noTerm" ]; then
    if command -v "$BROWSER" > /dev/null 2>&1; then
        setsid -f "$BROWSER" "$filename" >/dev/null 2>&1
        mv "$myTempDir" "${tempDirPattern}K"
    else
        echo "$0: Text may not be terminal-compatible and BROWSER environment variable is not set or cannot be invoked."
        echo "To suppress this error and try to display on the terminal no matter what, set the environment"
        echo "variable 'UNICODE_TERM' to a non-empty string"
        exitCode=1
    fi
elif [ "$r2l" ]; then
    rev "${filename}" | $PAGER
else
    $PAGER "$filename"
fi

rm -rf "$tempDirPattern"??*
mv "${tempDirPattern}K" "$myTempDir" 2>/dev/null # Preserves browser-viewable files for only one invocation
exit "$exitCode"
