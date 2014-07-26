# Makefile for handling various tasks of PyLint sources
PYVE=pyve
PIP=$(PYVE)/bin/pip
TOX=$(PYVE)/bin/tox

# this is default target, it should always be first in this Makefile
help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  tests       to run whole test suit of PyLint"
	@echo "  docs        to generate all docs including man pages and exemplary pylintrc"
	@echo "  deb         to build debian package"
	@echo "  lint        to check Pylint sources with itself"
	@echo "  all         to run all targets"


$(PIP):
	virtualenv $(PYVE)

$(TOX): $(PIP)
	$(PIP) install tox==1.7


ifdef TOXENV
toxparams?=-e $(TOXENV)
endif

tests: $(TOX)
	$(TOX) $(toxparams)

docs: $(PIP)
	rm -f /tmp/pylint
	ln -s -f $(CURDIR) /tmp/pylint
	$(PIP) install .
	PYTHONPATH=/tmp PATH=$(CURDIR)/pyve/bin:$(PATH) make all -C doc

deb:
	debuild -b -us -uc

lint: $(PIP)
	$(PIP) install .
	$(PYVE)/bin/pylint lint.py

clean:
	rm -rf $(PYVE)
	rm -rf .tox
	rm -rf /tmp/pylint1 /tmp/pylint2
	make clean -C doc
	debuild clean

all: clean lint tests docs deb

.PHONY: help tests docs deb lint clean all
