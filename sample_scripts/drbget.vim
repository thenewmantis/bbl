let books = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Josue', 'Judges', 'Ruth', '1 Kings', '2 Kings', '3 Kings', '4 Kings', '1 Paralipomena', '2 Paralipomena', '1 Esdras', '2 Esdras', 'Tobias', 'Judith', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Songs', 'Wisdom', 'Ecclesiasticus', 'Isaiah', 'Jeremiah', 'Lamentations', 'Baruch', 'Ezechiel', 'Daniel', 'Osee', 'Joel', 'Amos', 'Abdias', 'Jonas', 'Michaeas', 'Nahum', 'Habacuc', 'Sophonias', 'Aggaeus', 'Zacharias', 'Malachias', '1 Machabees', '2 Machabees', 'Matthew', 'Mark', 'Luke', 'John', 'The Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Apocalypse']
let abbrs = ['Gen', 'Ex', 'Lev', 'Num', 'Dt', 'Jos', 'Jdg', 'Ruth', '1Ki', '2Ki', '3Ki', '4Ki', '1Par', '2Par', 'Esd', 'Neh', 'Tob', 'Jdt', 'Est', 'Job', 'Ps', 'Prv', 'Eccles', 'Cant', 'Wis', 'Ecclus', 'Is', 'Jer', 'Lam', 'Bar', 'Eze', 'Dan', 'Os', 'Joel', 'Amos', 'Abd', 'Jon', 'Mic', 'Nah', 'Hab', 'Sop', 'Agg', 'Zac', 'Mal', '1Mac', '2Mac', 'Mt', 'Mk', 'Lk', 'Jn', 'Acts', 'Rom', '1Cor', '2Cor', 'Gal', 'Eph', 'Phil', 'Col', '1Thess', '2Thess', '1Tim', '2Tim', 'Tit', 'Phm', 'Heb', 'Jas', '1Pet', '2Pet', '1Jn', '2Jn', '3Jn', 'Jude', 'Apoc']

" https://github.com/thenewmantis/bbl.git
" This script is intended to pull all verses of the Douay-Rheims Bible from the web into plain text, with one verse per line, in the following format: (e.g.)
" Exodus	Exo	2	5	20	And they met Moses and Aaron, who stood over against them as they came out from Pharao:
" The operation of this script is, of course, dependent on the website that hosts the content keeping its URLS and HTML the same, or at least still compatible with the regex used.
" Please feel free to modify and reuse this script or another one like it in order to versify any text you find online
" Every line in the resulting file should match the following regex (typed exactly as it would be in a Vimscript command (but ignore the surrounding whitespace)):
"                      ^\%(\%([1-4] \|The \|Song of \)\?\a\+\|Sirach (Ecclesiasticus)\)\t\%([1-4]\)\?\a\+\t\d\{1,2}\t\d\{1,3}\t\d\{1,3}\t\D\+$
" To run this script successfully, open an empty Vim buffer in the directory that this script is placed, give the buffer a filename and run the following ex command (from the empty buffer):
" :source drbget.vim

for b in range(len(books))
    let c = 1
    while 1
        exe printf('!curl -Lf ''http://drbo.org/chapter/%02d%03d.htm'' > drb_output.log', b+1, c)
        !awk '/\<a href="\/cgi-bin/' drb_output.log | perl -pe 's/<.*?>|[\[\]]//g' > drb_verses.log; [ -s drb_verses.log ]

        if v:shell_error == 0
            let verses = readfile('drb_verses.log')

            for verse in verses
                let verseText = substitute(verse, '\d\+\W\?\s*', '', '')
                pu =books[b].'	'.abbrs[b].'	'.(b+1).'	'.c.'	'.str2nr(verse).'	'.verseText
			endfor

			let c += 1
        else
            break
        endif
    endw
endfor
w
