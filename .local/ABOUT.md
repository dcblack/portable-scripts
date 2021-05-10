The portable-scripts collection
===============================

Scripts used to setup a familiar environment on new Linux hosts and build favorite tools. These should be useful to Doulos instructors. These should work on any Ubuntu installation including AWS, CoCalc and Docker. They are designed to work when you do not have `sudo` or `root` privileges.

It may not be obvious, but most of the utility is under a directory called `.local`. The intent is that you might locate it under `$HOME` or perhaps more profitably, create a symbolic link to it from `$HOME`.

WARNING: If symbolic links are employed, take care to avoid renaming or moving the location of this directory, lest you destroy critical functionality (e.g., .bashrc).

```sh
if [[ "$(basename $(pwd))" == "portable-scripts" ]]; then
  ln -s "$(pwd)"/.local "${HOME}/.local
else
  echo "ERROR: Please use this from just inside the portable-scripts directory" 1>&2
fi
```

The following describes some of the contents. most of the directories have a `README.md` or `ABOUT.md` that provided further information. These are markdown formatted text files. Directories marked with Ø are intentionally empty excepting perhaps a `README.md`.

```
dcblack_doulos.gpg ── my public GPG key
setup.profile
.local/
├── ARCHIVES/Ø ─ holds stuff downloaded by scripts
├── apps/ ─── default location for installation
│   ├── cmake/ ─ use with cmake esp. for SystemC
│   └── sc-templates/ ─ see `bin/new` script for more information
├── bin/ ─ utilities (esp. scripts to build tools from source)
├── dotfiles/ ─ replacements for .bashrc, .vimrc, etc.
├── lib/ ─ library stuff (e.g., for Perl)
├── misc/ ─ unclassified
├── scratch/Ø ─ place to put junk/temporaries
├── share/Ø ─ used by some installers
├── src/Ø ─ place to hold source used during builds
└── tests/ ───────────── Contains scripts that test things in bin/
```

##### The end
