.PHONY: clear
clear:
	@cls || clear

.PHONY: install
install:
	mix deps.get

.PHONY: docs
docs:
	mix docs
