pkg = $(shell basename $(CURDIR))

all: build

NAMESPACE: R/*
	Rscript -e "devtools::document()"

README.html: README.md
	pandoc -o README.html README.md

../$(pkg)*.tar.gz: DESCRIPTION NAMESPACE README.md
	cd ../ && R CMD build $(pkg)

build: ../$(pkg)*.tar.gz

check: ../$(pkg)*.tar.gz
	cd ../ && R CMD check $(pkg)*.tar.gz
	rm ../$(pkg)*.tar.gz

install: ../$(pkg)*.tar.gz
	cd ../ && R CMD INSTALL $(pkg)*.tar.gz
	rm ../$(pkg)*.tar.gz

shiny: NAMESPACE
	Rscript -e "shiny::runApp()"

deploy: NAMESPACE
	Rscript -e "rsconnect::deployApp(appFiles = c("ui.R", "server.R", "R/word_count.R"), forceUpdate = TRUE)"
