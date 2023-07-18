.PHONY: test

test: *.lua
	lua test.lua *_test.lua
