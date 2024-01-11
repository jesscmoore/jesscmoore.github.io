---
layout: post
title:  "Move code to a new package and import from github"
date:   2024-01-08 09:23:00 +1100
published: false
toc: true
---

**Summary**

Often we have code in a project that is replicated across multiple projects. This causes unnecessary coding increasing the length of code files in your project, and making your projects more prone to human error. It makes sense to extract this code as a separate package/s that can be shared with other developers and imported into projects that use it. If you're unsure whether to publish to PyPI, it is easy to import from github once it has been extracted into a new github repo.

**Extracting the code to a new repo**

1. `mkdir ../[package_name]` - Make a new project directory and move your code there
2. `pyenv  local [py_version] [env_name]` - Create new virtual environment
3. `pyenv activate codesize_dev` - Activate the virtual environment
4. `mkdir src/[package]` folder and move the source code here.
4. create new github repo with necessary README, LICENSE and other boilerplate files.
2.
3. Add `pyproject.toml` with setuptools for building, version and basic metadata, including github url, and test installation with `pip install -e .`
4. Setup linting and formatting with ruff, including a ruff pre-commit hook to ensure clean readable code. Install `pre-commit` with `pip install pre-commit` and add your pre-commit configuration to your porject with `pre-commit install`. Then edit a file to test the ruff hook is working.
5. Add `Makefile` for easy package install and other common commands.
6. Update `README.md` with description, install and demo.
7. Ensure you have the current version of the build package ` python3 -m pip install --upgrade build;`
8. Generate distribution packages for the package. These are archives that are uploaded to the Python Package Index and can be installed with pip. Make the distribution package with`python3 -m build`. This create s the dist folder.

```
git init -b main
git add -A .
git commit -m "First commit"
```
Create github repo
```
git remote add origin https://github.com/jesscmoore/packaging_tutorial.git
git push -u origin main
```


**Updating the projects using this code**

7. In your virtual environment of a project using the extracted code, install the new project from github. `pip install git+https://github.com/jesscmoore/packaging_tutorial.git` or `python -m pip install ...`. Alternatively add the repo to your project requirements list in your `pyproject.toml` file by adding `"[package_name] @ git+https://github.com/jesscmoore/packaging_tutorial.git"` and then running `python -m pip install -e .` to reinstall the package.
8. Remove the extracted code, and instead import the new package and call the module that wraps the extracted code.  `python -c "from example_package_jesscmoore import example; example.add(2)"`
9. Test you get the expected functionality when importing your new package and running the desired module.


As you make changes to your new package, dont forget to increment the version, so that it is automatically updated when others update their project installation (where they have your proejct listed as a requirement).

Your new package can also be published to PyPI if desired.
