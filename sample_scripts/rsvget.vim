let books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Tobit", "Judith", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Wisdom", "Sirach (Ecclesiasticus)", "Isaiah", "Jeremiah", "Lamentations", "Baruch", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi", "1 Maccabees", "2 Maccabees", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"]
let abbrs = ["Gen", "Ex", "Lev", "Num", "Deut", "Josh", "Judg", "Ruth", "1Sam", "2Sam", "1Kings", "2Kings", "1Chron", "2Chron", "Ezra", "Neh", "Tob", "Jdt", "Esther", "Job", "Ps", "Prov", "Eccles", "Song", "Wis", "Sir", "Is", "Jer", "Lam", "Bar", "Ezek", "Dan", "Hos", "Joel", "Amos", "Obad", "Jon", "Mic", "Nahum", "Hab", "Zeph", "Hag", "Zech", "Mal", "1Mac", "2Mac", "Mt", "Mk", "Lk", "Jn", "Acts", "Rom", "1Cor", "2Cor", "Gal", "Eph", "Phil", "Col", "1Thess", "2Thess", "1Tim", "2Tim", "Tit", "Philem", "Heb", "Jas", "1Pet", "2Pet", "1Jn", "2Jn", "3Jn", "Jude", "Rev"]

" https://github.com/thenewmantis/bbl.git
" This script is intended to pull all verses of the Revised Standard Version: Catholic Edition from the web into plain text, with one verse per line, in the following format: (e.g.)
" Exodus	Exo	2	5	20	They met Moses and Aaron, who were waiting for them, as they came forth	from Pharaoh;
" The operation of this script is, of course, dependent on the website that hosts the content keeping its URLS and HTML the same, or at least still compatible with the regex used.
" Please feel free to modify and reuse this script or another one like it in order to versify any text you find online
" Every line in the resulting file should match the following regex (typed exactly as it would be in a Vimscript command (but ignore the surrounding whitespace)):
"                      ^\%(\%([1-4] \|The \|Song of \)\?\a\+\|Sirach (Ecclesiasticus)\)\t\%([1-4]\)\?\a\+\t\d\{1,2}\t\d\{1,3}\t\d\{1,3}\t\D\+$
" To run this script successfully, open an empty Vim buffer in the directory that this script is placed, give the buffer a filename and run the following ex command (from the empty buffer):
" :source rsvget.vim

for b in range(len(books))
	let c = 1
	while 1
		exe '!curl -f ''https://biblia.com/books/rsvce/'.abbrs[b].c.''' > rsv_output.log'
		!awk /\<div\ class=\"resourcetext\"\>/ rsv_output.log | perl -pe 's/<[^\/][^<]*?>[a-z]<\/.*?>//g; s/<.*?>//g; s/(\D)(\d+)/\1\n\2/g' > rsv_verses.log; [ -s rsv_verses.log ]

		if v:shell_error == 0
            " The first line is only the book name
            let verses = readfile('rsv_verses.log')[1:]

            let chapterTitle = ''
            if books[b] == 'Psalms'
            "The second (or rarely, third) line, in the case of some psalms, contains the title for that psalm. Otherwise it is just the chapter number (in which case, `chapterTitle` will remain a blank string)
                let line = substitute(verses[0], '\d\+\s\+', '', '')
                let verses = verses[1:]

                if match(line, 'PSALM') > -1
                    let line = substitute(verses[0], '\d\+\s\+', '', '')
                    let verses = verses[1:]
                endif

                if match(line, '\w') > -1
                        let chapterTitle = line
                endif
            else
                " The second line is empty
                let verses = verses[1:]
            endif


			for verse in verses
                let verseText = substitute(verse, '\d\+\W\?\s*', '', '')
                if (chapterTitle != '')
                    let verseText = '(' . chapterTitle . ') ' . verseText
                    let chapterTitle = ''
                endif
				pu =books[b].'	'.abbrs[b].'	'.(b+1).'	'.c.'	'.str2nr(verse).'	'.verseText
			endfor

			let c += 1
		else
            w
			break
		endif
	endw
endfor
%s/\s\+\ze)//eg
%s/\s\zs \+//eg
" Delete DOS-style carriage returns (may require that "edit" command), non-breaking spaces and asterisks (from footnotes)
w | edit ++ff=unix
%s/[ *]//eg
w
