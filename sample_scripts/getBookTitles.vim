" Run the following script on a .tsv file to copy the book titles and abbreviations from that file
set wrapscan
let books = []
let abbrs = []
0pu_ | +
while line('.') != 1
    let currLine = split(getline('.'), '\t')
    let books += [currLine[0]]
    let abbrs += [currLine[1]]
    exe ':norm /^\%(=currLine[0]\)\@!'
endw
redir @b>|let books
redir @a>|let abbrs
redir END
0pu a
norm ilet ela=lldt[
1d
0pu b
norm ilet ela=lldt[
1d
3d
echom "Done."
