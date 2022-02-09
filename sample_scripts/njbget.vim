let books = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Tobit', 'Judith', 'Esther', '1 Maccabees', '2 Maccabees', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Songs', 'Wisdom', 'Sirach', 'Isaiah', 'Jeremiah', 'Lamentations', 'Baruch', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts of Apostles', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation']
let abbrs = ['Ge', 'Exo', 'Lev', 'Num', 'Deu', 'Josh', 'Jdgs', 'Ruth', '1Sm', '2Sm', '1Ki', '2Ki', '1Chr', '2Chr', 'Ezra', 'Neh', 'Tob', 'Jdt', 'Est', '1Mac', '2Mac', 'Job', 'Ps', 'Prov', 'Eccles', 'Song', 'Wis', 'Sir', 'Is', 'Jer', 'Lam', 'Bar', 'Ezek', 'Dan', 'Hos', 'Joel', 'Amos', 'Obad', 'Jon', 'Mic', 'Nahum', 'Hab', 'Zeph', 'Hag', 'Zech', 'Mal', 'Mt', 'Mk', 'Lk', 'Jn', 'Acts', 'Rom', '1Cor', '2Cor', 'Gal', 'Eph', 'Phil', 'Col', '1Th', '2Th', '1Tim', '2Tim', 'Tit', 'Phmn', 'Heb', 'Jas', '1Pet', '2Pet', '1Jn', '2Jn', '3Jn', 'Jude', 'Rev']

" https://github.com/thenewmantis/bbl.git
" This script is intended to pull all verses of the New Jerusalem Bible from the web into plain text, with one verse per line, in the following format: (e.g.)
" Exodus	Exo	2	5	20	As they left Pharaoh's presence, they met Moses and Aaron who were standing in their way.
" The operation of this script is, of course, dependent on the website that hosts the content keeping its URLS and HTML the same, or at least still compatible with the regex used.
" Please feel free to modify and reuse this script or another one like it in order to versify any text you find online
" Every line in the resulting file should match the following regex (typed exactly as it would be in a Vimscript command (but ignore the surrounding whitespace)):
"                      ^\%(\%([1-4] \|The \|Song of \)\?\a\+\|Sirach (Ecclesiasticus)\)\t\%([1-4]\)\?\a\+\t\d\{1,2}\t\d\{1,3}\t\d\{1,3}\t\D\+$
" To run this script successfully, open an empty Vim buffer in the directory that this script is placed, give the buffer a filename and run the following ex command (from the empty buffer):
" :source njbget.vim

for b in range(len(books))
	let c = 1
	while 1
		exe '!curl -f ''https://www.catholic.org/bible/book.php?id='.(b+1).'&bible_chapter='.c.''' > njb_output.log'
		!awk /\<a\ name=\"\[0-9\]+\"\>/ njb_output.log | perl -pe 's/<.*?>|//g; s/(\D)(\d+)/\1\n\2/g' > njb_verses.log; [ -s njb_verses.log ]

		if v:shell_error == 0
			let verses = readfile('njb_verses.log')

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
