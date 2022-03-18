BEGIN {
	#  $1 Book name
	#  $2 Book abbreviation
	#  $3 Book number
	#  $4 Chapter number
	#  $5 Verse number
	#  $6 Verse
	FS = "\t"

	MAX_WIDTH = 80
    NO_LINE_WRAP = envbool("KJV_NOLINEWRAP")
    NO_VERSE_NUMBERS = envbool("KJV_NOVERSENUMBERS")
    NO_CHAPTER_HEADINGS = envbool("KJV_NOCHAPTERHEADINGS")
    NO_TITLE = envbool("KJV_NOTITLE")
    NO_VERSE_BREAK = envbool("KJV_NOVERSEBREAK")
    if (NO_VERSE_BREAK) {
        NO_VERSE_NUMBERS = 1
    }
    if(envbool("KJV_NOFORMAT")) {
        NO_LINE_WRAP = 1
        NO_CHAPTER_HEADINGS = 1
        NO_TITLE = 1
        NO_VERSE_BREAK = 1
    }
	if (ENVIRON["KJV_MAX_WIDTH"] ~ /^[0-9]+$/) {
		if (int(ENVIRON["KJV_MAX_WIDTH"]) < MAX_WIDTH) {
			MAX_WIDTH = int(ENVIRON["KJV_MAX_WIDTH"])
		}
	}

	if (cmd == "ref") {
		mode = parseref(ref, p)
		p["book"] = cleanbook(p["book"])
	}
}

cmd == "clean" {
    processline()
}

cmd == "list" {
	if (!($2 in seen_books)) {
		printf("%s (%s)\n", $1, $2)
		seen_books[$2] = 1
	}
}

function envbool(str){
    return ENVIRON[str] != "" && ENVIRON[str] != "0"
}

function parseref(ref, arr) {
	# 1. <book>
	# 2. <book>:?<chapter>
	# 2a. <book>:?<chapter>[, ?<chapter>]...
	# 3. <book>:?<chapter>:<verse>
	# 3a. <book>:?<chapter>:<verse>[, ?<verse>]...
	# 3b. <book>:?<chapter>:<verse>[, ?<chapter>:<verse>]...
	# 4. <book>:?<chapter>-<chapter>
	# 5. <book>:?<chapter>:<verse>-<verse>
	# 6. <book>:?<chapter>[:<verse>]-<chapter>:<verse>
	# 7. /~?<search>
	# 8. <book>/~?search
	# 9. <book>:?<chapter>/~?search
        #10. @ <number of verses>?
        #11. <book> @ <number of verses>?
        #12. <book>:?<chapter> @ <number of verses>?

	if (match(ref, "^[1-9]?[a-zA-Z ]+")) {
            # 1, 2, 2a, 3, 3a, 3b, 4, 5, 6, 8, 9, 11, 12
            arr["book"] = substr(ref, 1, RLENGTH)
            ref = substr(ref, RLENGTH + 1)
	} else if (sub("^ */ *", "", ref)) {
            # 7
            if (sub("^~ *", "", ref)) {
                arr["search"] = roughpattern(ref)
                return "rough_search"
            } else {
                arr["search"] = ref
                return "search"
            }
	}

	if (match(ref, "^:?[1-9]+[0-9]*")) {
            # 2, 2a, 3, 3a, 3b, 4, 5, 6, 9, 12
            if (sub("^:", "", ref)) {
                    arr["chapter"] = int(substr(ref, 1, RLENGTH - 1))
                    ref = substr(ref, RLENGTH)
            } else {
                    arr["chapter"] = int(substr(ref, 1, RLENGTH))
                    ref = substr(ref, RLENGTH + 1)
            }
	} else if (sub("^ */ *", "", ref)) {
            # 8
            if (sub("^~ *", "", ref)) {
                arr["search"] = roughpattern(ref)
                return "rough_search"
            } else {
                arr["search"] = ref
                return "search"
            }
	} else if (ref == "") {
            # 1
            return "exact"
	}

	if (match(ref, "^:[1-9]+[0-9]*")) {
            # 3, 3a, 3b, 5, 6
            arr["verse"] = int(substr(ref, 2, RLENGTH - 1))
            ref = substr(ref, RLENGTH + 1)
	} else if (match(ref, "^-[1-9]+[0-9]*$")) {
            # 4
            arr["chapter_end"] = int(substr(ref, 2))
            return "range"
	} else if (sub("^ */ *", "", ref)) {
            # 9
            if (sub("^~ *", "", ref)) {
                arr["search"] = roughpattern(ref)
                return "rough_search"
            } else {
                arr["search"] = ref
                return "search"
            }
	} else if (ref == "") {
            # 2
            return "exact"
	} else if (match(ref, "^(, ?[1-9]+[0-9]*)+$")) {
            # 2a
            arr["chapter", arr["chapter"]] = 1
            delete arr["chapter"]
            while (match(ref, "^, ?[1-9]+[0-9]*")) {
                    if(sub("^, ", "", ref)) {
                        arr["chapter", substr(ref, 1, RLENGTH - 2)] = 1
                        ref = substr(ref, RLENGTH - 1)
                    } else {
                        arr["chapter", substr(ref, 2, RLENGTH - 1)] = 1
                        ref = substr(ref, RLENGTH + 1)
                    }
            }

            if (ref != "") {
                    return "unknown"
            }

            return "exact_ch_set"
	} else if (match(ref, "^ *@ *")) {
            # 10, 11, 12
            ref = substr(ref, RLENGTH + 1)
            if (match(ref, "^[1-9][0-9]*")) {
                arr["numberOfVerses"] = int(ref)
            } else {
                arr["numberOfVerses"] = 1
            }
            NO_LINE_WRAP = 1
            return "random"
	}

	if (match(ref, "^-[1-9]+[0-9]*$")) {
            # 5
            arr["verse_end"] = int(substr(ref, 2))
            return "range"
	} else if (match(ref, "-[1-9]+[0-9]*")) {
            # 6
            arr["chapter_end"] = int(substr(ref, 2, RLENGTH - 1))
            ref = substr(ref, RLENGTH + 1)
	} else if (ref == "") {
            # 3
            return "exact"
	} else if (match(ref, "^(, ?[1-9]+[0-9]*)+$")) {
            # 3a
            arr["verse", arr["verse"]] = 1
            delete arr["verse"]
            while (match(ref, "^, ?[1-9]+[0-9]*")) {
                    if(sub("^, ", "", ref)) {
                        arr["verse", substr(ref, 1, RLENGTH - 2)] = 1
                        ref = substr(ref, RLENGTH - 1)
                    } else {
                        arr["verse", substr(ref, 2, RLENGTH - 1)] = 1
                        ref = substr(ref, RLENGTH + 1)
                    }
            }

            if (ref != "") {
                    return "unknown"
            }

            return "exact_set"
        } else if (match(ref, "^, ?[1-9]+[0-9]*:[1-9]+[0-9]*")) {
            # 3b
            arr["chapter:verse", arr["chapter"] ":" arr["verse"]] = 1
            delete arr["chapter"]
            delete arr["verse"]
            do {
                    if(sub("^, ", "", ref)) {
                        arr["chapter:verse", substr(ref, 1, RLENGTH - 2)] = 1
                        ref = substr(ref, RLENGTH - 1)
                    } else {
                        arr["chapter:verse", substr(ref, 2, RLENGTH - 1)] = 1
                        ref = substr(ref, RLENGTH + 1)
                    }
            } while (match(ref, "^, ?[1-9]+[0-9]*:[1-9]+[0-9]*"))

            if (ref != "") {
                    return "unknown"
            }

            return "exact_set"
	} else {
            return "unknown"
	}

	if (match(ref, "^:[1-9]+[0-9]*$")) {
            # 6
            arr["verse_end"] = int(substr(ref, 2))
            return "range_ext"
	} else {
            return "unknown"
	}
}

function cleanbook(book) {
	book = tolower(book)
	gsub(" +", "", book)
	return book
}

function bookmatches(book, bookabbr, query) {
	book = cleanbook(book)
	if (book == query) {
		return book
	}

	bookabbr = cleanbook(bookabbr)
	if (bookabbr == query) {
		return book
	}

	if (substr(book, 1, length(query)) == query) {
		return book
	}
}

function roughpattern(regex) {
    # TODO Can mess with search pattern if regex is used on command line
    regex = tolower(regex)
    switch(lang) {
        case "el":
            polytonic["α"] = "[αάἀ-ἆὰᾀ-ᾆᾳ-ᾷ]"
            polytonic["ε"] = "[εέἐ-ἕὲ]"
            polytonic["η"] = "[ηήἠ-ἧὴᾐ-ᾗῃ-ῇ]"
            polytonic["ι"] = "[ιίΐϊἰ-ἷὶῒ-ῖ]"
            polytonic["ο"] = "[οόὀ-ὅὸ]"
            polytonic["υ"] = "[υΰϋύὐ-ὗὺῢῦ]"
            polytonic["ω"] = "[ωώὠ-ὧὼᾠ-ᾧῳ-ῷ]"
            for (letter in polytonic) {
                gsub(letter, polytonic[letter], regex)
            }
            break
        case "la":
            gsub("e", "[eë]", regex)
            break
    }
    return regex
}

function printverse(verse,    word_count, characters_printed) {
	if (NO_LINE_WRAP) {
        if (NO_VERSE_BREAK) {
            printf("%s ", verse)
        } else {
            printf("%s\n", verse)
        }
		return
	}

	word_count = split(verse, words, " ")
	for (i = 1; i <= word_count; i++) {
		if (characters_printed + length(words[i]) + (characters_printed > 0 ? 1 : 0) > MAX_WIDTH - 8) {
            if(cross_ref || NO_VERSE_BREAK) {
                printf("\n")
            } else {
                printf("\n\t")
            }
			characters_printed = 0
		}
		if (characters_printed > 0) {
			printf(" ")
			characters_printed++
		}
		printf("%s", words[i])
		characters_printed += length(words[i])
	}
    if (NO_VERSE_BREAK) {
        printf(" ")
    } else {
        printf("\n")
    }
}

function processline() {
    newbook = (last_book_printed != $2)
	if (newbook) {
        if(cross_ref) {
            print("")
        } else if (NO_TITLE) {
            if (last_book_printed) {
                print("")
            }
        } else {
            print($1)
        }
        last_book_printed = $2
	}

    if (cross_ref || NO_CHAPTER_HEADINGS || NO_VERSE_NUMBERS) {
        if (NO_VERSE_NUMBERS && last_chapter_printed != $4) {
            if (cross_ref) {
                if(NO_CHAPTER_HEADINGS) {
                    print("")
                } else {
                    print("\n")
                }
            } else if (NO_CHAPTER_HEADINGS) {
                if (last_chapter_printed) {
                    print("")
                }
            } else {
                if (NO_VERSE_BREAK && !newbook) {
                    print("")
                }
                printf("%d\n", $4)
            }
            last_chapter_printed = $4
        }
    } else {
        printf("%d:%d\t", $4, $5)
    }
	printverse($6)
	outputted_records++
}

cmd == "ref" && mode == "exact" && bookmatches($1, $2, p["book"]) && (p["chapter"] == "" || $4 == p["chapter"]) && (p["verse"] == "" || $5 == p["verse"]) {
	processline()
}

cmd == "ref" && mode == "random" && (p["book"] == "" || bookmatches($1, $2, p["book"])) && (p["chapter"] == "" || $4 == p["chapter"]) {
    print
    outputted_records++
}

cmd == "ref" && mode == "exact_ch_set" && bookmatches($1, $2, p["book"]) && p["chapter", $4] {
	processline()
}

cmd == "ref" && mode == "exact_set" && bookmatches($1, $2, p["book"]) && (((p["chapter"] == "" || $4 == p["chapter"]) && p["verse", $5]) || p["chapter:verse", $4 ":" $5]) {
	processline()
}

cmd == "ref" && mode == "range" && bookmatches($1, $2, p["book"]) && ((p["chapter_end"] == "" && $4 == p["chapter"]) || ($4 >= p["chapter"] && $4 <= p["chapter_end"])) && (p["verse"] == "" || $5 >= p["verse"]) && (p["verse_end"] == "" || $5 <= p["verse_end"]) {
	processline()
}

cmd == "ref" && mode == "range_ext" && bookmatches($1, $2, p["book"]) && (($4 == p["chapter"] && $5 >= p["verse"] && p["chapter"] != p["chapter_end"]) || ($4 > p["chapter"] && $4 < p["chapter_end"]) || ($4 == p["chapter_end"] && $5 <= p["verse_end"] && p["chapter"] != p["chapter_end"]) || (p["chapter"] == p["chapter_end"] && $4 == p["chapter"] && $5 >= p["verse"] && $5 <= p["verse_end"])) {
	processline()
}

cmd == "ref" && (mode == "search" || mode == "rough_search") && (p["book"] == "" || bookmatches($1, $2, p["book"])) && (p["chapter"] == "" || $4 == p["chapter"]) && match(mode == "rough_search" ? tolower($6) : $6, p["search"]) {
	processline()
}

END {
	if (cmd == "ref") {
        if (outputted_records == 0) {
		    print "Unknown reference: " ref
        } else if (mode == "random") {
            printf("~~~RANDOMS: %d\n", p["numberOfVerses"])
        }
	}
}
