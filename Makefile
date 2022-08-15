
PREFIX = /usr/local

bbl: bbl.sh bbl.awk readings/*/*.tsv readings/*/*.aliases
	cat bbl.sh > $@
	echo 'exit 0' >> $@
	echo "#EOF" >> $@
	tar cf bbl.tar bbl.awk
	(cd readings && \
	for d in $$(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do \
		(cd "$$d" && \
		common_aliases="$$d.aliases"; \
		[ -f "$$common_aliases" ] && tar rf ../../bbl.tar "$$common_aliases"; \
		for f in *.tsv; do \
			aliases_file="$${f%%.tsv}.aliases"; \
			[ -f "$$aliases_file" ] && tar rf ../../bbl.tar "$$aliases_file"; \
			tar rf ../../bbl.tar "$$f"; \
		done; )\
	done)
	gzip -c bbl.tar >> $@
	rm -f bbl.tar
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
