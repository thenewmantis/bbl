#!/bin/sh
# https://github.com/thenewmantis/bbl.git
# This script is intended to pull all verses of the Hebrew Bible from the web into plain text, with one verse per line, in the following format: (e.g.)
# בראשית	בר	א	א	א	בְּרֵאשִׁ֖ית בָּרָ֣א אֱלֹהִ֑ים אֵ֥ת הַשָּׁמַ֖יִם וְאֵ֥ת הָאָֽרֶץ׃
# Which, in the command line application that these verses are used for, would produce the following output:
# תישארב
# ׃ץֶרָֽאָה תֵ֥אְו םִיַ֖מָּׁשַה תֵ֥א םיִ֑הֹלֱא אָ֣רָּב תיִׁ֖שאֵרְּב	א:א
# (Rendered right-to-left, as is proper.)
# The operation of this script is, of course, dependent on the website that hosts the content keeping its URLS and HTML the same, or at least still compatible with the regex used.
# Please feel free to modify and reuse this script or another one like it in order to versify any text you find online
# Every line in the resulting file should match the following regex (typed exactly as it would be in a Vimscript command (but ignore the surrounding whitespace)):
#                      ^[א-ת]\+\t\%([א-ת]\+ \)\?[א-ת]\+\t[א-ת]\{1,2}\%(\tק\?[א-ת]\{0,2}\&.\+\)\{2}\t\D\+$
# To run, simply run: `./hebget.sh`. This will silently overwrite any file named "h.tsv" in the current directory.

printf="/usr/bin/env printf"
b='01'
bAbs=1
c=1
myFile="hebTemp.txt"
tsv="h.tsv"
>"$myFile"
>"$tsv"

download() {
    url="$($printf 'https://mechon-mamre.org/c/ct/c%s%02d.htm' "$b" "$c")"
    curl -L "$url" -o "$myFile"
}
nextBook() {
    bAbs=$(( bAbs + 1 ))
    next="$($printf '%02d' "$(($(echo "$b" | grep -o '[1-9][0-9]\?') + 1))")"
    for n in 08 09 25 35; do
        if [ "$b" = "${n}a" ]; then
            b="${n}b"
            return
        elif [ "$b" = "${n}b" ]; then
            if [ "$n" = 08 ]; then
                b='09a'
            else
                b="$next"
            fi
            return
        elif [ "$next" = "$n" ]; then
            b="${next}a"
            return
        fi
    done
    b="$next"
}
getAbbreviation() {
    case "$1" in
        "דברי ה*")
            echo 'ימ';;
        "שמות")
            echo 'שת';;
        "שמואל")
            echo 'של';;
        "מלכ*")
            echo 'מלכ';;
        "מלא*")
            echo 'מלא';;
        "יואל")
            echo 'יל';;
        "יונה")
            echo 'ינ';;
        *)
            echo "$1" | grep -o '^..'
    esac
}
hebNum() {
    # Gets the Hebrew numeral corresponding to the integer given--only intended for numbers 1-499
    case "$1" in
        0 | 00) ;;
        ? | 10)
            $printf "\u$($printf '%04x' $(( 1487 + $1 )))" ;;
        0?)
            hebNum "$(echo "$1" | cut -c2-2)" ;;
        15)
            $printf 'טו' ;;
        16)
            $printf 'טז' ;;
        ??)
            dig2="$(hebNum "$(echo "$1" | cut -c2-2)")"
            addend=1496
            if [ "$1" -ge 90 ]; then #because of tsade sofit
                addend=1501
            elif [ "$1" -ge 80 ]; then #because of pe sofit
                addend=1500
            elif [ "$1" -ge 50 ]; then #...because of nun sofit
                addend=1499
            elif [ "$1" -ge 40 ]; then #because of mem sofit
                addend=1498
            elif [ "$1" -ge 20 ]; then #because of kaf sofit
                addend=1497
            fi
            dig1hex="$($printf '%04x' "$(( addend + $(echo "$1" | cut -c1-1)))")"
            $printf "\u$dig1hex$dig2" ;;
        ???)
            digs="$(hebNum "$(echo "$1" | cut -c2-3)")"
            dig1hex="$($printf '%04x' "$((1510 + $(echo "$1" | cut -c1-1)))")"
            $printf "\u$dig1hex$digs" ;;
        *) ;;
    esac
}

download
while ! grep -qi '404 not found' "$myFile"; do
    title="$(grep -Po '(?<=<H1>)[^<]*' "$myFile" | cut -d ' ' -f1)"
    [ title = 'דברי' ] && title='דברי הימים'
    [ title = 'שיר' ] && title='שיר השירים'
    abbr="$(getAbbreviation "$title")"
    bNumHeb="$(hebNum "$bAbs")"
    while ! grep -qi '404 not found' "$myFile"; do
        cNumHeb="$(hebNum "$c")"
        awk "/<B>/{print \"$title\t$abbr\t$bNumHeb\t$cNumHeb\" \$0}" "$myFile" | sed -e 's/<B>\|<\/B> /\t/g' -e 's/\(\S\)<BR>\(\S\)/\1 \2/g' -e 's/<[^>]\+>//g' >> "$tsv"
        c=$(( c + 1 ))
        download
    done
    nextBook
    c=1
    download
done
