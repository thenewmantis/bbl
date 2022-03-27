#!/bin/sh
# To TSV-ify webpages from https://www.thelatinlibrary.com/
# In this example, the Aeneid:

for n in $(seq 12); do
    curl -L "https://www.thelatinlibrary.com/vergil/aen$n.shtml" | sed -n '/<p class="internal_navigation"/,/<div class="footer"/{/^\w/p}' | sed -e 's/&nbsp;.*//' -e 's/<br>//' -e 's/&#151/—/g' | awk "{printf(\"Aeneid\tAen\t1\t${n}\t%d\t%s\n\", NR, \$0)}"
done > latinpoem.tsv
