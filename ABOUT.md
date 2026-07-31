The portable-scripts collection
===============================

TLDR
----

Scripts created by David C Black (dcblack@mac.com or david.black@doulos.com) to simplify tasks on macos/*nix.

Quick install
-------------

```bash
git clone https://github.com/dcblack/portable-scripts ~/.portable-scripts
~/.portable-scripts/setup
```

The setup command supports `--help`, `--version`, `--check`, and `--dry-run`.
On an existing installation, run the legacy checkout's `setup --dry-run` if it
is still exposed through `~/.local`, then run the command to migrate it.
After migration, use `~/.portable-scripts/setup` for repeat installations.

Background
----------

The reason for this project is historical. I've used many computers, operating systems, and programming languages over the course of my career. Every time I encounter a new machine/OS, I end up wanting to install familiar "bits" that I use daily. Each of these "bits" has some unique installation aspect that can vary from one OS to the next.

Description
-----------

This project contains scripts used to setup a familiar environment on new Linux hosts and build favorite tools. These should be useful to Doulos instructors. These should work on almost any `*nix` installation including AWS, CoCalc and Docker. They are designed to work when you do not have `sudo` or `root` privileges.

The Git checkout belongs at `~/.portable-scripts`. The directory `~/.local` is
an ordinary XDG user directory and is not a portable-scripts checkout. Setup may
create `~/.local/bin` and add selected command links, but it never replaces or
relocates `~/.local/share`, `~/.local/state`, or `~/.local/cache`.

Set `PORTABLE_SCRIPTS_HOME` when testing an alternate checkout. Home dotfiles are
backed up before they are linked to sources under the repository. The backup
directory contains `MIGRATION.txt` with the source, destination, timestamp, and
rollback guidance.

Before migration, inspect `~/.local/bin`, `~/.local/share`, `~/.local/state`,
`~/.local/cache`, Snap data, Junie data, and application-specific symlinks. Only
directories containing an empty `MOVEALL` marker are moved, and their complete
contents are preflighted for collisions before transfer.

See `docs/MIGRATION-INVENTORY.md` for ownership boundaries and `docs/STATUS.md`
for the honest, platform-specific verification checklist.

The following describes some of the contents. Most of the directories have a `README.md` or `ABOUT.md` that provided further information. These are markdown formatted text files. Directories marked with Ø are intentionally empty excepting perhaps a `README.md`.

```
setup ───────────────── migration and installation entry point
~/.portable-scripts/
├── ABOUT.md ─────────── this documentation
├── REQUIRED.txt ─────── list of required files
├── LICENSE ──────────── Apache 2.0 license
├── docs/ ────────────── migration inventory and verification status
├── apps/ ────────────── application and template sources
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
