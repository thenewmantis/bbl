
PREFIX = /usr/local

bbl: bbl.sh bbl.awk *.tsv
	cat bbl.sh > $@
	echo 'exit 0' >> $@
	echo "#EOF" >> $@
	tar cz bbl.awk *.tsv >> $@
	chmod +x $@

test: bbl.sh bbl.awk
	shellcheck -s sh -S error bbl.sh
	echo -n | gawk --lint=invalid -f bbl.awk

clean:
	rm -f bbl

install: bbl
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f bbl $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/bbl

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/bbl

.PHONY: test clean install uninstall
