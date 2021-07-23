The portable-scripts collection
===============================

Scripts used to setup a familiar environment on new Linux hosts and build favorite tools. These should be useful to Doulos instructors. These should work on any Ubuntu installation including AWS, CoCalc and Docker. They are designed to work when you do not have `sudo` or `root` privileges.

It may not be obvious, but most of the utility is under a directory called `.local`. The intent is that you locate a symbolic link to `$(pwd)/portablescripts/.local` under `$HOME`. You could also copy or move it there, but that might make it more difficult to update. If you really want to move it to `$HOME`, consider putting the entire contents of `portablescripts` there. A simple approach to this latter approach would be:

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

The following describes some of the contents. most of the directories have a `README.md` or `ABOUT.md` that provided further information. These are markdown formatted text files. Directories marked with Ø are intentionally empty excepting perhaps a `README.md`.

```
dcblack_doulos.gpg ── my public GPG key
setup.profile
.local/
├── ARCHIVES/ ────────── holds stuff downloaded by scripts
├── apps/ ────────────── default location for installation
│   ├── cmake/ ───────── use with cmake esp. for SystemC
│   ├── sc_templates/ ── use with cmake esp. for SystemC
│   └── src/ ─────────── see `bin/new` script for more information
├── bin/ ─────────────── utilities (esp. scripts to build tools from source)
├── dotfiles/ ────────── replacements for .bashrc, .vimrc, etc.
├── lib/ ─────────────── library stuff (e.g., for Perl)
├── misc/ ────────────── unclassified
├── scratch/ ─────────── place to put junk/temporaries
├── share/ ───────────── used by some installers
├── src/ ─────────────── place to hold source used during builds
└── tests/ ───────────── contains scripts that test things in bin/
```

##### The end
