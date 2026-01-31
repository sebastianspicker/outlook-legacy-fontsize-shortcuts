LUAROCKS_TREE := .luarocks
LUAROCKS := luarocks --tree=$(LUAROCKS_TREE)
BIN := $(LUAROCKS_TREE)/bin

LUACHECK := $(BIN)/luacheck
BUSTED := $(BIN)/busted
STYLUA ?= stylua
LUA_FILES := init.lua outlook_legacy_fontsize.lua spec

.PHONY: tools lint fmt fmt-check test check clean

tools:
	$(LUAROCKS) install luacheck
	$(LUAROCKS) install busted

lint:
	$(LUACHECK) .

fmt:
	$(STYLUA) $(LUA_FILES)

fmt-check:
	$(STYLUA) --check $(LUA_FILES)

test:
	$(BUSTED) -v

check: lint fmt-check test

clean:
	rm -rf $(LUAROCKS_TREE) lua_modules
