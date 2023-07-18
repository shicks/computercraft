.PHONY: test

test: *.lua
	for a in *_test.lua; do lua $$a; done
