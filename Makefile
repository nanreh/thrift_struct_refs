all:
	rm -rf out
	mkdir -p out/{good,bad}
	$(THRIFT) -r -out out/good -gen java good.thrift
	$(THRIFT) -r -out out/bad -gen java bad.thrift
	$(THRIFT) --version > out/thrift.version
	diff out/good out/bad > out/diff.txt; [ $$? -eq 1 ]

THRIFT=/usr/local/bin/thrift

.PHONY: all
