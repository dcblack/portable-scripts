The portable-scripts collection
===============================

Quick install
-------------

```bash
cd SOMEWHERE_SUITABLE
git clone https://github.com/dcblack/portable-scripts.git
source portable-scripts/setup ;#<-- sets up a symbolic link ~/.local to the portable scripts
```

Background
----------

The reason for this project is historical. I've used many computers, operating systems, and programming languages over the course of my career. Every time I encounter a new machine/OS, I end up wanting to install familiar "bits" that I use daily. Each of these "bits" has some unique installation aspect that can vary from one OS to the next.

Description
-----------

This project contains scripts used to setup a familiar environment on new Linux hosts and build favorite tools. These should be useful to Doulos instructors. These should work on almost any `*nix` installation including AWS, CoCalc and Docker. They are designed to work when you do not have `sudo` or `root` privileges.

It may not be obvious, but most of the utility is under a directory called `.local/`. The intent is that you locate a symbolic link to `$(pwd)/portablescripts/.local` under `$HOME`. You could also copy or move it there, but that might make it more difficult to update. If you really want to move it to `$HOME`, consider putting the entire contents of `portablescripts` there. A simple approach to this latter approach would be:

```bash
git clone https/github.com/dcblack/portable-scripts.git "${HOME}"
```

WARNING: If symbolic links are employed, take care to avoid renaming or moving the location of this directory, lest you destroy critical functionality (e.g., .bashrc).

```sh
if [[ "$(basename $(pwd))" == "portable-scripts" ]]; then
  ln -s "$(pwd)"/.local "${HOME}/.local
else
  echo "ERROR: Please use this from just inside the portable-scripts directory" 1>&2
fi
```

The following describes some of the contents. Most of the directories have a `README.md` or `ABOUT.md` that provided further information. These are markdown formatted text files. Directories marked with Ø are intentionally empty excepting perhaps a `README.md`.

```
setup@ ───────────────── symbolic link to .local/bin/portable-setup
.local/
├── ABOUT.md ─────────── this documentation
├── REQUIRED.txt ─────── list of required files
├── LICENSE ──────────── Apache 2.0 license
├── ARCHIVES/ ────────── holds stuff downloaded by scripts
├── apps/ ────────────── default location for installation
│   ├── cmake/ ───────── use with cmake esp. for SystemC
│   ├── sc_templates/ ── use with cmake esp. for SystemC (see `bin/new` script for more information)
│   └── src/ ─────────── shared source for development (also possible for builds, but prefer .local/src)
├── bin/ ─────────────── utilities (esp. scripts to build tools from source)
├── dotfiles/ ────────── replacements for .bashrc, .vimrc, etc.
├── lib/ ─────────────── library stuff (e.g., for Perl)
├── man/ ─────────────── man pages
├── misc/ ────────────── unclassified
├── modules/ ─────────── for use with `modulecmd`
├── scratch/ ─────────── place to put junk/temporaries
├── scripts/ ─────────── various scripts (e.g. bash functions)
├── share/ ───────────── used by some installers
├── src/ ─────────────── source used during builds (i.e., temporary)
└── tests/ ───────────── contains scripts that test things in bin/
```

##### The end
