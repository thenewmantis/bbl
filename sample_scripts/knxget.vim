let books = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Josue', 'Judges', 'Ruth', '1 Kings', '2 Kings', '3 Kings', '4 Kings', '1 Paralipomena', '2 Paralipomena', '1 Esdras', '2 Esdras', 'Tobias', 'Judith', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Songs', 'Wisdom', 'Ecclesiasticus', 'Isaiah', 'Jeremiah', 'Lamentations', 'Baruch', 'Ezechiel', 'Daniel', 'Osee', 'Joel', 'Amos', 'Abdias', 'Jonas', 'Michaeas', 'Nahum', 'Habacuc', 'Sophonias', 'Aggaeus', 'Zacharias', 'Malachias', '1 Machabees', '2 Machabees', 'Matthew', 'Mark', 'Luke', 'John', 'The Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Apocalypse']
let abbrs = ['Gen', 'Ex', 'Lev', 'Num', 'Dt', 'Jos', 'Jdg', 'Ru', '1Kgs', '2Kgs', '3Kgs', '4Kgs', '1Par', '2Par', 'Esd', 'Neh', 'Tob', 'Jdt', 'Est', 'Job', 'Ps', 'Prv', 'Eccl', 'Cant', 'Wis', 'Eccle', 'Isa', 'Jer', 'Lam', 'Bar', 'Eze', 'Dan', 'Os', 'Joel', 'Am', 'Abd', 'Jon', 'Mic', 'Nah', 'Hab', 'Sop', 'Agg', 'Zac', 'Mal', '1Mac', '2Mac', 'Mat', 'Mk', 'Lk', 'Jn', 'Acts', 'Rom', '1Cor', '2Cor', 'Gal', 'Eph', 'Phi', 'Col', '1Th', '2Th', '1Tim', '2Tim', 'Tit', 'Phm', 'Heb', 'Jas', '1Pet', '2Pet', '1Jn', '2Jn', '3Jn', 'Jud', 'Apoc']
" https://github.com/thenewmantis/bbl.git
" This script is intended to pull all verses of the Knox Version of the Bible from the web into plain text, with one verse per line, in the following format: (e.g.)
" Exodus	Exo	2	5	20	and meeting Moses and Aaron face to face, as they came away from Pharao’s audience,
" The operation of this script is, of course, dependent on the website that hosts the content keeping its URLS and HTML the same, or at least still compatible with the regex used.
" Please feel free to modify and reuse this script or another one like it in order to versify any text you find online
" Every line in the resulting file should match the following regex (typed exactly as it would be in a Vimscript command (but ignore the surrounding whitespace)):
"                      ^\%(\%([1-4] \|The \|Song of \)\?\a\+\|Sirach (Ecclesiasticus)\)\t\%([1-4]\)\?\a\+\t\d\{1,2}\t\d\{1,3}\t\d\{1,3}\t\D\+$
" To run this script successfully, open an empty Vim buffer in the directory that this script is placed, give the buffer a filename and run the following ex command (from the empty buffer):
" :source knxget.vim

let t = 'OT'
let lastOT = index(books, '2 Machabees')

for b in range(len(books))
    let c = 1
    while 1
        if b > lastOT
            let t = 'NT'
        en
        let a = abbrs[b]
        if a == 'Joel'
            let a = 'Jo'
        elseif match(a, '^\d') > -1
            let abbr = abbr[0] . '_' . abbr[1:]
        endif
        exe '!curl -f ''http://catholicbible.online/knox/'.t.'/'.abbr.'/ch_'.c.''' > knx_output.log'

        if v:shell_error == 0
            !awk /vers-no\|vers-content/ knx_output.log | perl -pe 's/^.*?>|<.*?>|✻//g' > knx_verses.log

            let verses = readfile('knx_verses.log')
            let verseNum = 0

            for verse in verses
                let tryVerseNumber = str2nr(verse)
                if tryVerseNumber
                    let verseNum = tryVerseNumber
                else
                    pu =books[b].'	'.abbrs[b].'	'.(b+1).'	'.c.'	'.verseNum.'	'.verse
                en
            endfor

            let c += 1
        else
            break
        endif
    endw
endfor
" Delete DOS-style carriage returns (may require that "edit" command), non-breaking spaces and asterisks (from footnotes)
w | edit ++ff=unix
%s/[ *]//eg
w
