---
layout: post
title:  "Move code to a new package and import from github"
date:   2024-01-08 09:23:00 +1100
published: true
toc: true
---

## Summary

Often we have code in a project that is replicated across multiple projects. This causes unnecessary coding increasing the length of code files in your project, and making your projects more prone to human error. It makes sense to extract this code as a separate package/s that can be shared with other developers and imported into projects that use it. If you're unsure whether to publish to PyPI, it is easy to import from github once it has been extracted into a new github repo.

A completed new package, e.g. `codesize` package, will have this structure:

```
codesize
├── .gitignore
├── LICENSE
├── Makefile
├── README.md
├── dist/
├── examples/
│   └── print_large_files.py
├── pyproject.toml
├── src/
│   ├── codesize/
│   │   ├── __init__.py
│   │   └── files.py
│   └── codesize.egg-info/
└── tests/
```

- LICENSE, README.md - required
- dist folder - build wheel and tarball
- pytproject.toml - package configuration and metadata
- src/codesize - src code
- src/codesize.egg-info - metadata
- Optional - examples folder, tests folder, Makefile

### Method

**Extract code as package**

1. In new folder create and activate a new pyenv virtual environment
2. Move code for your new package into `[package_name]/src/[package_name]` folder.
3. Add boiler plate files `README.md`, `LICENSE`, `src/[package_name]/__init__.py`
4. `pip install -e .` to test install.

**Setup new package**

5. `echo '[build-system]\nrequires = ["setuptools"]\nbuild-backend = "setuptools.build_meta"' > pyproject.toml` add build configuration using setuptools to pyproject.toml.
6. `python3 -m build` to test build.
7. Add package metadata in particular package name, version and requirements list to `pyproject.toml`.
8. Add package dist related folders to ``.gitignore`.
9. Create github repo for new package and commit project files

```
git init -b main
git add -A .
git commit -m "Initial"
git remote add origin https://github.com/[github_id]/[package_name].git
git push -u origin main
```

**Import package**

10. Add package github repo to your project dependencies.
```
dependencies = [
    ...,
    "[package_name] @ git+https://github.com/[github_user]/[package_name].git",
]
```
11. `python -m pip install -e .` - update project install to install the new package
12. `python -c "from [package] import [module]; [module].[method]([args])"` - test import and use of the package.
```


## Procedure

### Extracting the code to a new repo

Make a new project directory and clean virtual environment. Move your common code for the new package into the `src/package_name` subdirectory of the new project.

```
mkdir [package_name]
cd [package_name]
pyenv  local [py_version] [env_name]
pyenv activate [env_name]
mkdir src/[package_name]
```

Add boiler plate files `README.md`, `LICENSE`, `src/[package_name]/__init__.py`. [https://choosealicense.com/.](https://choosealicense.com/.) can be used to help select a license. `src/[package_name]/__init__.py` will tell Python that the [package] folder is a python package. Creating this file is required and it can be an empty file.

### Setup package build and metadata

Set build configuration using setuptools in pyproject.toml.

```
echo '[build-system]\nrequires = ["setuptools"]\nbuild-backend = "setuptools.build_meta"' > pyproject.toml
```

Add package metadata in particular package name, version and requirements list to `pyproject.toml`. As you make changes to your new package, dont forget to increment the version, so that it is automatically updated when others update their project installation (where they have your proejct listed as a requirement).

```
vim pyproject.toml
```
It should look like
```
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"


[project]
name = "[package_name]"
version = "0.0.1"
authors = [
  { name="[name]", email="[email]" },
]
description = "[description]"
readme = "README.md"
requires-python = ">=3.8"
keywords = ["", "", ""]  # Add keywords here
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: GPLv3 License",
    "Programming Language :: Python :: 3",
    "Operating System :: OS Independent",
]
dependencies = [
    "",  # Add requirements to this list 1/line
]


[project.urls]
Homepage = "[github url]"
Issues = "[github url]/issues"
```

Build the distribution which will build the wheel file and tarball in the `dist` folder.

```
python -m build
```

Test install your code in the new isolated package

```
python -m pip install -e .
```

### Upload to github

Create an ignore file to ignore python build folder and egg metadata which is regenerated when built with setuptools.

```
vim .gitignore
```
to add below

**.gitignore**
```
# Setuptools distribution folder.
/dist/

# Python egg metadata, regenerated from source files by setuptools.
/*.egg-info
/*.egg
```

Initialise the project as a repo with master branch named `main`.
```
git init -b main
```

Create a github repo with the name of your project. Commit your files, set the remote repo, and push your package to the repo.
```
git add -A .
git commit -m "First commit"
git remote add origin https://github.com/[github_user]/[package].git
git push -u origin main
```
### Import package to projects using the code

In your virtual environment of a project using the extracted code, install the new project from github.
```
python -m  pip install git+https://github.com/[github_user]/[package].git
```
Or for producible install, add the package to your project dependencies.
```
dependencies = [
    ...,
    "[package_name] @ git+https://github.com/[github_user]/[package_name].git",
]
```

If needed, import a specific branch or tag (See [https://matiascodesal.com/blog/how-use-git-repository-pip-dependency/](https://matiascodesal.com/blog/how-use-git-repository-pip-dependency/)).

Update the project installation to install the new package.

```
python -m pip install -e .
```
Now remove your extracted code, and instead import the new package and call the module that wraps the extracted code.  The install and function of your package can be tested on command line.

```
python -c "from [package] import [module]; [module].[method]([args])"`
```
E.g. importing our new `codesize` package in our `travelco2` project to run the large method in the files module, it shows there are 15 long py files longer than a good practice line limit of 400 lines and provides a useful printout of large file sizes.

```
python -c "from codesize import files; files.large(limit=400, ext='py')"
File                                                         Size
-----------------------------------------------------------------
./travel/utils/distance_emission.py                          2274
./travel/utils/support.py                                    1191
./travel/charts/bar.py                                       1188
./travel/utils/cluster.py                                    1113
./travel/constants.py                                        916
./travel/tables/college_portfolio.py                         853
./travel/utils/cleaning.py                                   844
./travel/utils/emissions.py                                  810
./travel/charts/scatter.py                                   686
./travel/utils/transport.py                                  530
./cluster.py                                                 479
./travel/utils/labelling.py                                  477
./travel/tables/yearly_summary.py                            444
./travel/utils/load_data.py                                  426
./pages/page_method.py                                       422

Large files: 15
```

### Optional

#### PyPI

Your new package can also be published to PyPI if desired.

#### Add examples and/or make rules

Python scrypts that provide demos of your code can be shared in an `examples` folder.

It can be useful to also have a `Makefile` with make rules to simplify common commands.

#### Add ruff

In your new packages, you may want to all [add ruff]({% post_url 2024-01-11-project-ruff-setup %}) to your new packages to ensure best code style.



## References

1. [https://packaging.python.org/en/latest/tutorials/packaging-projects/](https://packaging.python.org/en/latest/tutorials/packaging-projects/)
