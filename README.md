# shellfuncs

This repo serves as a repository of Bourne shell <code>sh</code> scripts that I wish to sync across *nix systems. Even though these scripts are for my personal needs, I also do attempt to generalize the scripts in the following ways:

* Exclude shell (any Bourne shell should work, compliant with POSIX) specfic code (e.g. '[[' for test and ';;&' for case statements in <code>bash</code>)
  * Unfortunately there is more bash specfic shell code than I imagined, so best bet currently is to use bash with shellfuncs
* Some of the scripts make use of environment vars in my personal dotfiles. The scripts will prompt for information they need.

When installed, in each new shell session, scripts inside the 'scripts' directory will be pulled into the shell session where the containing functions of each script (most scripts contain one function named after the file itself) can be invoked.

## Usage

My suggestion is to fork shellfuncs, as these scripts (and by extension repo) will constantly change.

## Installation

The install script can be piped into a different shell of choice, currently mine is <code>bash</code>.

**NOTE:** Running through the installation will modify <code>.profile</code> to include functions used by **shellfuncs** to pull updates to its local repo location and source the scripts from 'scripts' folder. If this is not desired, modify the install script accordingly.

```shell
curl --silent https://raw.githubusercontent.com/cavcrosby/shellfuncs/main/install | bash
```

## License

See LICENSE.
