neo.phyte_00.tar: 0x00/
	make -C $< clean
	tar -cf $@ $<

web: */*md
	mkdir -p www/
	cp .md2html/index.html .
	md2html 0x00/*md > www/body.html
	sed "/{{CONTENT}}/r www/body.html" .md2html/temp.html \
		| sed '/{{CONTENT}}/d' > www/neo.phyte_00.html
	rm www/body.html
	git checkout -b www
	git add -f www index.html
	git commit -m "website"
	git push -f
	git checkout master
	git branch -D www

clean:
	rm *.tar
	rm -rf www

.PHONY: clean web
