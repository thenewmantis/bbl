# bbl -- The Bible on the Command Line

A command line tool for searching and reading the Holy Bible.

Format and original implementation from [bontibon/kjv](https://github.com/bontibon/kjv). Also a derivative of [lukesmithxyz/vul](https://github.com/LukeSmithxyz/vul).
This implementation allows for numerous translations/versions of the Bible to be available under one executable.

## Usage

```

usage: bbl [flags] [bible] [reference...]

  Flags:
  -l, --list              list books
  -W, --no-line-wrap      no line wrap
  -V, --no-verse-numbers  no verse numbers are printed--just the book title at the top and a number for each chapter
  -C, --no-ch-numbers     no chapter headings either (implies -V)
  -T, --no-title          book title is not printed
  -B, --no-verse-break    No linebreaks at the end of each verse--each chapter runs like a continuous paragraph. Currently implies -V (I am working on changing that)
  -N, --no-format         Equivalent to -WCTB
  -c, --cat               echo text to STDOUT
  -h, --help              show help
  Bibles:
  -d, --douay             Douay-Rheims Bible
  -g, --greek             Greek Bible (Septuagint + SBL NT)
  -H, --hebrew            The Bible in Hebrew (with cantillation marks and niqqudim)
  -i, --ivrit             The Bible in Hebrew without cantillation marks and niqqudim
  -j, --jerusalem         New Jerusalem Bible
  -k, --kjv               King James Bible
  -n, --knox              Knox Bible
  -r, --rsv               Revised Standard Version: Catholic Edition
  -v, --vulgate           Clementine Vulgate

Specify multiple versions to cross-reference (view them in multi-column fashion).
This feature is not yet available for languages that are read right-to-left.
Specifying -i or -H will currently override all other translations and output only the Hebrew Bible.

  Reference types:
  NOTE: The colon between book and chapter is required for Hebrew, optional for everything else.
 References for Hebrew must be in Hebrew; for all else, must be in English.
      <Book>
          Individual book
      <Book>:<Chapter>
          Individual chapter of a book
      <Book>:<Chapter>:<Verse>[,<Verse>]...
          Individual verse(s) of a specific chapter of a book
      <Book>:<Chapter>:<Verse>[,<Chapter>:<Verse>]...
          Individual verses of different chapters of a book
      <Book>:<Chapter>-<Chapter>
          Range of chapters in a book
      <Book>:<Chapter>:<Verse>-<Verse>
          Range of verses in a book chapter
      <Book>:<Chapter>:<Verse>-<Chapter>:<Verse>
          Range of chapters and verses in a book

      /~?<Search>
          All verses that match a pattern
      <Book>/~?<Search>
          All verses in a book that match a pattern
      <Book>:<Chapter>/~?<Search>
          All verses in a chapter of a book that match a pattern
      In searches, the optional ~ indicates that the search should be approximate:
      Case and accent marks will be disregarded. Note that this will often take
      much longer than an exact search

      @ <Number-of-Verses>?
          Random verse or assortment of verses from any book/chapter
      <Book> @ <Number-of-Verses>?
          Random verse or assortment of verses from any chapter in a given book
      <Book>:<Chapter> @ <Number-of-Verses>?
          Random verse or assortment of verses from the given book:chapter


```

## Note

The default behaviour (without a flag to specify the Bible version) is to print from the Knox Bible.
To change this, set the environment variable "DEFAULT_BIBLE" to reflect the three-letter abbreviation of your translation of choice.
One can easily extend this program ad nauseam by simply adding new .tsv files and updating the getopt and the case statement in bbl.sh accordingly.

## Install

```
git clone https://github.com/thenewmantis/bbl.git
cd bbl
sudo make install
```

## License

The script is in the public domain.
