---
layout: post
title:  "Python package management with poetry"
date:   2024-03-10 22:10:52 +1100
published: false
toc: true
---

Useful poetry commands

### Initialise existing project

```
cd [project]
poetry init
```

### Establish new project

```
poetry new [project]
```

### Useful settings

Set the python project

```
[project]
requires-python = ">=3.9"
```

Turn off package mode (as only required if intending to build project as a package.)

```
[tool.poetry]
package-mode = false
```


### Useful commands

- `poetry run python xyz.py` - runs xyz.py in your environment
- `poetry add [package]` - installs package in environment and adds to project.toml file.
- `poetry remove [package]` - uninstalls package from environment and removes it from the project.toml file.
