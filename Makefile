neo.phyte_00.tar: 0x00/
	make -C $< clean
	tar -cf $@ $<

clean:
	rm *.tar

.PHONY: clean
