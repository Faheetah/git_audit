# GitAudit

**WARNING: This script will recursively check directories, which may be CPU intensive for very large directories.**

Recursively traverses directories and determines if the directory has a .git subdirectory, then checks whether the repo is dirty or if there are any unpushed commits. The script will stop traversing when a directory contains a .git directory, to avoid unnecessarily recursing into vendored dependencies. Helpful to audit a local development environment for work that has not been pushed.

## Installation

GitAudit includes a mix task that can be globally installed.

`mix archive.install github faheetah/git_audit`

## Usage

Run the git_audit task with a path. That's it. It will recursively audit the path.

`mix git_audit PATH`

For no colors, use the `--no-ansi` flag, i.e.

`mix get_audit PATH --no-ansi`
