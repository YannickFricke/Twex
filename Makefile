NODEMON_EXECUTABLE=npx nodemon
NODEMON_DEFAULT_ARGS=-w ./lib/ -w ./mix.exs -w ./test/ -e ex,exs

.PHONY: clear
clear:
	@cls || clear

.PHONY: install
install:
	mix deps.get

.PHONY: docs
docs:
	mix docs

.PHONY: watch-docs
watch-docs:
	${NODEMON_EXECUTABLE} ${NODEMON_DEFAULT_ARGS} -x "make clear docs"
