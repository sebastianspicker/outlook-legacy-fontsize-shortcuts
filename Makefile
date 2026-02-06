LUAROCKS_TREE := .luarocks
LUAROCKS := luarocks --tree=$(LUAROCKS_TREE)
BIN := $(LUAROCKS_TREE)/bin

LUACHECK := $(BIN)/luacheck
BUSTED := $(BIN)/busted
STYLUA ?= stylua
LUA_FILES := init.lua outlook_legacy_fontsize.lua spec
LUACHECK_VERSION ?= 1.2.0-1
BUSTED_VERSION ?= 2.3.0-1

.PHONY: tools lint fmt fmt-check test check clean

tools:
	$(LUAROCKS) install luacheck $(LUACHECK_VERSION)
	$(LUAROCKS) install busted $(BUSTED_VERSION)

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
