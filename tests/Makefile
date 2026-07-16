FONT_ESC := $(shell printf '\033')
FONT_BOLD := ${FONT_ESC}[1m
FONT_NC := ${FONT_ESC}[0m # No colour

TEST_SELECTOR_OPTS :=
ifneq ($(selector),)
	TEST_SELECTOR_OPTS := -k "$(selector)"
endif

all:
	@echo "Use a specific goal. To list all goals, type 'make help'"

.PHONY: install # Install dependencies
install:
	@pip3 install '.[dev]'

.PHONY: test # Runs tests; optional arguments:~selector=[test selector expression]: only run tests which match the given substring expression.
test:
	@pytest -vs --cache-clear --capture=no $(TEST_SELECTOR_OPTS) -m "$(marker)" --cov=src --cov-append --cov-report xml:coverage.xml ./src

.PHONY: scenario-test # Runs scenario tests; optional arguments:~selector=[test selector expression]: only run tests which match the given substring expression.
scenario-test:
	@$(MAKE) test marker="scenario"

.PHONY: clean # Cleans up build directories
clean:
	@$(RM) -rf .pytest_cache
	@$(RM) -rf dist
	@$(RM) -rf build
	@$(RM) -rf src/*.egg-info
	@$(RM) .coverage

.PHONY: help # Generate list of goals with descriptions
help:
	@echo "Available goals:\n"
	@grep '^.PHONY: .* #' Makefile | sed "s/\.PHONY: \(.*\) # \(.*\)/${FONT_BOLD}\1: ${FONT_NC}\2~~/" | sed $$'s/~~/\\\n/g' | sed $$'s/~/\\\n\\\t\\\t/g'
