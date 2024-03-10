---
layout: post
title:  "Commitlint pre-commit hook for linting commit messages"
date:   2024-03-10 22:21:07 +1100
published: true
toc: true
---

[Commitlint](https://commitlint.js.org/) is useful to enforce a particular commit message style. This prevents developers from unspecific commit messages like
```
git commit -m "update"
```

Using a [commitlint pre-commit hook](https://github.com/alessandrojcm/commitlint-pre-commit-hook) ensures that commit messages are checked on git commit to see if they comply with [Angular commit style](https://py-pkgs.org/07-releasing-versioning#automatic-version-bumping) required for commit parsing by `semantic-release version`. By ensuring angular commit messages, we can use semantic-release version to automatically bump your python package version and update the changelog file.



**Summary**

1. `poetry add commitlint --group dev` - Install commitlint python library and add to tool.poetry.group.dev.dependencies in `pyproject.toml`.
2. Configure commitlint by creating a `commitlint.config.js` file - see procedure for details.
3. Add commitlint hook to `.pre-commit-config.yaml` - see procedure for details.
4. `pre-commit install` - Install pre-commit hooks in .git folder.
5. `pre-commit autoupdate` - Check for and install any updates to pre-commit hooks.

## Procedure

### Install commitlint

Install commitlint python library. Using `poetry` for dependency management allows us to install `commitlint` and add it to the dependency list in `pyproject.toml` with the command below. By amending `--group dev`, we can add it to the tool.poetry.dev.dependencies list used for development, which allows them to only be installed when required.

```
poetry add commitlint --group dev
```

### Configure commitlint

Set commitlint to use Angular style by creating a new file `commitlint.config.js` in your project root directory with the following contents:
```
//comitling.config.js at the root of your repo
module.exports = {
    extends: ['@commitlint/config-angular'], // => commitlint/config-angular
};
```
Note: it was not possible to configure commitlint with a `commitlintrc.yaml`.

### Add pre-commit hook

Next, add a pre-commit hook for commitlint in a `.pre-commit-config.yaml` file in your project root directory. You can have multiple hooks below the "repos:" line.

```
repos:
# commitlint
- repo: https://github.com/alessandrojcm/commitlint-pre-commit-hook
  rev: 'v9.13.0'
  hooks:
      - id: commitlint
        stages: [commit-msg]
        additional_dependencies: ['@commitlint/config-angular']
```

### Install pre-commit hook

Install pre-commit hooks in .git folder of your project root directory.

```
pre-commit install
```

### Update pre-commit hook

Check for and install updates to the pre-commit hooks.

```
pre-commit autoupdate
```

### Using commitlint

Now, committing some code will required commit messages in Angular style, e.g.

```
git commit -m “feat: added button”
```
Longer commit messages comprise a title (limited to 72 characters) and a body separated by a blank line. These can be written using two `-m` where the first is for the message title and the second is for the message body. For example:
```
git commit -m "test: demonstrate multi-line commit message" -m "

After a blank line enter the message body. Press ENTER before closing the quotes to add a line break. Then close the quotes and hit ENTER twice to apply the commit.
"
```

The type of the commit must be one of set of allowed types allowed in [Angular commit style](https://py-pkgs.org/07-releasing-versioning#automatic-version-bumping).

**References**

- [Commitlint](https://commitlint.js.org/)
- [Commitlint pre-commit hook by alessandrojcm](https://github.com/alessandrojcm/commitlint-pre-commit-hook)
- [Angular commit style and semantic versining](https://py-pkgs.org/07-releasing-versioning#automatic-version-bumping)
- [Code with Goals: git+commitlint](https://medium.com/glassblade/code-should-be-written-with-goals-in-mind-git-commitlint-c50758b85920)
