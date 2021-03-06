
SHELL := /bin/bash
PATH  := ./node_modules/.bin:$(PATH)

SRC_FILES := $(shell find src -name '*.ts')

all: lib

lib: $(SRC_FILES) node_modules tsconfig.json
	tsc -p tsconfig.json --outDir lib
	touch lib

.PHONY: devserver
devserver: node_modules
	@onchange -i 'src/**/*.ts' 'config/*' -- ts-node src/server.ts | bunyan -o short

.PHONY: coverage
coverage: node_modules
	NODE_ENV=test nyc -r html -r text -e .ts -i ts-node/register mocha --exit --reporter nyan --require ts-node/register test/*.ts

.PHONY: test
test: node_modules
	NODE_ENV=test mocha --exit --require ts-node/register test/*.ts --grep '$(grep)'

.PHONY: ci-test
ci-test: node_modules
	nsp check
	tslint -p tsconfig.json -c tslint.json
	NODE_ENV=test nyc -r lcov -e .ts -i ts-node/register mocha --exit --reporter tap --require ts-node/register test/*.ts

.PHONY: lint
lint: node_modules
	NODE_ENV=test tslint -p tsconfig.json -c tslint.json -t stylish --fix

node_modules:
	yarn install --non-interactive

.PHONY: clean
clean:
	rm -rf lib/

.PHONY: distclean
distclean: clean
	rm -rf node_modules/
