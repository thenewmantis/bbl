#!/bin/sh
# To TSV-ify webpages from https://www.thelatinlibrary.com/
author="vergil"
title="ec"
max=10
b=2

for n in $(seq $max); do
    curl -L "https://www.thelatinlibrary.com/$author/$title$n.shtml" | sed -n '/<p class="internal_navigation"/,/<div class="footer"/{/^\w/p}' | sed 's/<BR>/\n/' | sed -e 's/&nbsp;.*//' -e 's/<.*>//g' -e '/^\s*$/d' | awk "{printf(\"Eclogues\tEcl\t${b}\t${n}\t%d\t%s\n\", NR, \$0)}"
done >> latinpoem.tsv
