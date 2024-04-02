#Variables
STRUCTURIZR_CLI  := docker run -it --rm -u $(id -u):$(id -g) -v ${PWD}/model:/usr/local/structurizr/model structurizr/cli
DOCUSAURUS_CLI   := docker run -it --rm -u $(id -u):$(id -g) -v ${PWD}/website:/website -w /website -p 3000:3000 node:latest
PLANTUML_CLI     := docker run --rm -u $(id -u):$(id -g) -v ${PWD}:/plantuml -w /plantuml plantuml/plantuml:latest

MODEL_SOURCES    := $(shell find model/ -name '*.dsl')

clean:
	rm -fR website/build website/static/diagrams model/.generated

clean-node:
	rm -fR website/node_modules website/.docusaurus

depend:
	${DOCUSAURUS_CLI} npm install

generate-puml: ${MODEL_SOURCES}
	${STRUCTURIZR_CLI} export -w model/workspace.dsl -f plantuml/c4plantuml -o model/.generated
	${PLANTUML_CLI} -svg -o /plantuml/website/static/diagrams /plantuml/model/.generated

build: generate-puml
	${DOCUSAURUS_CLI} npm run build

run-local: build
	${DOCUSAURUS_CLI} npm run serve

all: depend build

.PHONY: all build depend generate-puml run-local clean clean-node
