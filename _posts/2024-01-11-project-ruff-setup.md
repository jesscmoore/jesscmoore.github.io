---
layout: post
title:  "Setup ruff in your project"
date:   2024-01-11 12:23:00 +1100
published: true
toc: true
---

## Summary

Setup linting and formatting with ruff, including a ruff pre-commit hook to ensure clean readable code. Ruff is described as the one ring to rule them all providing integration for the main linting tools `pylint`, `black`, `pep`, `flake`, `pydocstyle`, `isort`, amongst others.

## Procedure

### Configure ruff

The configuration below will provide:
- `line-too-long` - allowing you to check for long lines, by default limited to <= 80 characters
- `UP` - pyupgrade
- `D` - pydocstyle
- `I` - isort
- `W` - pycodestyle
- `PLR0915` - pylint too-many-statements by default limits method length to <= 50 lines
- `C90` - McCabe complexity - by default limits complexity to <=5


1. `brew install ruff` - install ruff
2. `vim pyproject.toml` - add ruff configuration to your pyproject.toml.

```
[tool.ruff]
line-length = 80  # Set the maximum line length


[tool.ruff.lint]
extend-select = [
    "E501",    # Add the `line-too-long`
    "UP",      # pyupgrade
    "D",       # pydocstyle
    "I",       # isort
    "W",       # pycodestyle
    "PLR0915",  # pylint too-many-statements
    "C90",     # McCabe complexity
]
ignore = [  # Ignore rules
    "D100",  # Missing docstring in public module
    "D104",  # Missing docstring in public package
    "D107",  # Missing docstring in `__init__`
    "E902",  # No such file or directory (os error 2)
]


[tool.ruff.lint.pydocstyle]
convention = "google"  # Using pydocstyle rules for google style


[tool.ruff.lint.pylint]
max-statements = 50  # Default: 50 (max code lines in a method)

[tool.ruff.lint.mccabe]
# Flag errors (`C901`) whenever the complexity level exceeds 5.
max-complexity = 5 (mccabe complexity)
```

### Setup pre-commit

It's particularly useful to have your ruff configuration checked at commit. This can be easily done with [pre-commit](https://pre-commit.com/)

1. `pip install pre-commit` - install pre-commit
2. `vim .pre-commit-config.yaml` - add ruff hook to a new precommit configuration file .pre-commit-config.yaml.

```
repos:
- repo: https://github.com/astral-sh/ruff-pre-commit
  # Ruff version.
  rev: 'v0.1.11'
  hooks:
    # Run the linter.
    - id: ruff
      types_or: [ python, pyi, jupyter ]
      args: [--fix]  # Optional additional arg --exit-non-zero-on-fix
    # Run the formatter.
    - id: ruff-format
      types_or: [ python, pyi, jupyter ]
```
3. `pre-commit install` - to install your pre-commit hook in your project.
4. Then edit a file, `git add ...` and `git commit ...` to test the ruff hook is working.

### Add make rules (optional)

5. `vim Makefile` - optionally add make rules for common commands.

```
########################################################################
# DEFAULTS
#

# File path used by ruff to constrain scope
FILE?=.

# Ruff rule of interest or rule prefix, default `D1` which is all
# ruff rules for missing docstrings
RULE?=D1

# Default large file threshold
LIMIT?=500

########################################################################
# LOCAL TARGETS
#

prep:
	ruff check $(FILE)

prep_rules:
	ruff check . |grep $(RULE) | cut -d':' -f1,3 | sort | uniq -c | sort -r

prep_stats:
	ruff --statistics check $(FILE)

prep_fix:
	ruff --fix check $(FILE)
```

Best practice is to also create a help option

```
APP=codesize
VER=0.0.1
DATE=$(shell date +%Y-%m-%d)

########################################################################
# HELP
#
# Help for targets defined in this Makefile.

define HELP
$(APP) cli:

  prep                             Run ruff linter in check mode on
                                   full project `make prep` or specific file
                                   `make prep FILE=[file]`
  prep_rules                       Format ruff output to show each file
                                   and issue occurance for specific
                                   rule. Default `D1` to show all missing doc strings. Eg. for D1 rules
                                   `make prep_rules` or for E501 rule `make prep_rules RULE=E501`
  prep_stats                       Show statistics of ruff in check mode
                                   on full project `make prep_stats` or
                                   specific file `make prep_stats FILE=[file]`
  prep_fix                         Run ruff linter in fix mode on full
                                   project `make prep_fix` or specific file
                                   `make prep_fix FILE=[file]`

endef
export HELP

help::
	@echo "$$HELP"

```
