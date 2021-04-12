# bbl -- The Bible on the Command Line

A command line tool for searching and reading the Holy Bible.

Format and original implementation from [bontibon/kjv](https://github.com/bontibon/kjv). Also a derivative of [lukesmithxyz/vul](https://github.com/LukeSmithxyz/vul).
This implementation allows for numerous translations/versions of the Bible to be available under one executable.

## Usage

usage: bbl [flags] [bible] [reference...]

  Flags:
  -l, --list              list books
  -W, --no-line-wrap      no line wrap
  -c, --cat               echo text to STDOUT
  -h, --help              show help
  Bible:
  -d, --douay             Douay-Rheims Bible
  -g, --greek             Greek Bible (Septuagint + SBL NT)
  -j, --jerusalem         New Jerusalem Bible
  -k, --kjv               King James Bible
  -n, --knox              Knox Bible
  -v, --vulgate           Clementine Vulgate

  Reference types:
      <Book>
          Individual book
      <Book>:<Chapter>
          Individual chapter of a book
      <Book>:<Chapter>:<Verse>[,<Verse>]...
          Individual verse(s) of a specific chapter of a book
      <Book>:<Chapter>-<Chapter>
          Range of chapters in a book
      <Book>:<Chapter>:<Verse>-<Verse>
          Range of verses in a book chapter
      <Book>:<Chapter>:<Verse>-<Chapter>:<Verse>
          Range of chapters and verses in a book

      /<Search>
          All verses that match a pattern
      <Book>/<Search>
          All verses in a book that match a pattern
      <Book>:<Chapter>/<Search>
          All verses in a chapter of a book that match a pattern

## Note

The default behaviour (without a flag to specify the Bible version) is to print from the Knox Bible.
This is easy to change by changing line 7 of bbl.sh (BIBLE=knx) to reflect the three-letter abbreviation of your translation of choice.
One can easily extend this program ad nauseam by simply adding new .tsv files and updating the getopt and the case statement in bbl.sh accordingly.

## Install

```
git clone https://github.com/thenewmantis/bbl.git
cd bbl
sudo make install
```

## License

The script is in the public domain.
