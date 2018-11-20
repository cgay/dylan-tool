# Dylan Tool

## Overview

The `dylan-tool` simplifies the creation of Dylan workspaces and
package management by using a config file to specify packages that are
under active development and managing a single "registry" for the user
in what should (hopefully) become a standard development setup for
Dylan hackers. This should eliminate the need to manage registries by
hand and the need to use git submodules to track dependencies.

A key part of this tool is the package manager (tentatively named
"pacman") and its catalog of packages, the "pacman-catalog"
repository. For any package to be downloadable it must have an entry
in pacman-catalog. The catalog entry specifies the location of the
package and its dependencies, among other attributes.

In addition, a package may have a `pkg.json` file in its top-level
directory. This file, if it exists, overrides dependency information
in the catalog. This is important when its necessary to add a
dependency during new development, but unfortunately there is some
duplication with the catalog here. Hopefully a better solution can be
found.

A "workspace" is just a directory containing a `workspace.json` file
at top-level. The workspace file primarily specifies "active"
packages. These are the packages you're actively developing, as
opposed to packages installed in `${DYLAN}/pkg/`, which should never
be modified since that directory is the package manager's domain and
it might decide to delete anything there at any time, for example to
reinstall it.

## Quick Start

1.  Make sure the `DYLAN` environment variable is set to wherever you
    do your Dylan hacking. For example:

        $ export DYLAN=${HOME}/dylan

    Dylan packages, including the
    [pacman-catalog](https://github.com/dylan-lang/pacman-catalog)
    package which describes where to find other packages, will be
    installed under `${DYLAN}/pkg/`.

    **Note:** Don't ever put files you want to keep in the
    `${DYLAN}/pkg/` directory. The expectation should be that anything
    in this directory may be deleted at any time by the package
    manager.

1.  Clone and build the `dylan-tool` project:

        $ git clone --recursive git@github.com:dylan-lang/dylan-tool
        $ cd dylan-tool
        $ dylan-compiler -build dylan-tool.lid
        $ export PATH=`pwd`/_build/bin:${PATH}

1.  Create a new workspace. For example if you want to work on the
    http library:

        $ cd ${DYLAN}     # or wherever you want your workspace
        $ dylan-tool new ws.http http

    This creates the ws.http directory and ws.http/workspace.json.

1.  Run `dylan-tool update` to download the active packages (http in
    this case), install their dependencies, and create a registry with
    everything you need:

        $ cd ws.http
        $ dylan-tool update

    You should see some `git clone` output along with package and
    registry updates.

    **Note:** It should be safe to modify `workspace.json` and run
    `dylan-tool update` at any time from anywhere inside the workspace
    directory. It will only write to the registry and download/install
    packages that haven't already been downloaded or installed.

1.  Build and run your code (still in the ws.http directory):

        $ dylan-compiler -build http-server-demo
        $ _build/bin/http-server-demo

If you want to create a new package, rather than doing development on
one that already exists, you must manually add it to the
`workspace.json` file (see below) and then run `dylan-tool
update`. These are the steps:

1.  Create a new directory and git repo for your package in the
    workspace directory. (Hint: use `make-dylan-app` to create a
    library skeleton.)
1.  Create a `pkg.json` file that lists your package dependencies
    (deps). You could copy from [this
    one](https://github.com/dylan-lang/dylan-tool/blob/master/pkg.json).
1.  Add the package name to the "active" list in the `workspace.json`
    file.
1.  Run `dylan-tool update` to install the deps and update the
    registry.

You may run the `dylan-tool` command from anywhere inside the
workspace directory tree; it will search up to find the
"workspace.json" file.  In general you should invoke `dylan-compiler`
in the top-level workspace directory so that all the active packages
are built into the same "_build" directory and so that
`dylan-compiler` can find the auto-generated "registry" directory.

## The Workspace File

A workspace is defined by a `workspace.json` file containing a single
JSON object. Example:

    {
        "active": {
            "dylan-tool": {},
            "pacman": {},
            "uncommon-dylan": {}
        }
    }

(**Note:** There are currently no options so each package name simply
maps to an empty dictionary: `{}`.)

The "active" attribute describes the set of packages under active
development in this workspace. These packages will be cloned into the
workspace directory rather than being searched for in the installed
packages directory. (Git via SSH is currently assumed as the source
control tool, and all repositories are currently on GitHub so you will
need a GitHub account.)

After initial checkout you may create a new branch or perform whatever
git operations are necessary. If you decide to add a new dependency,
just add it to the "deps" in `pkg.json` and run `dylan-tool update`
again.

Each key under "active" specifies a package that will be under active
development. If you're working on existing packages then these should
match the name of an existing package in the
[Catalog](https://github.com/dylan-lang/pacman-catalog), and if a
subdirectory by this name doesn't exist in the workspace file's
directory, `dylan-tool` will do the initial checkout for you. If
you're creating a new package then you'll need to create the
subdirectory yourself, create a `pkg.json` file inside it, and then
run `dylan-tool update` and it will fetch the package's dependencies
for you.

## The Registry

Open Dylan uses "registries" to locate library sources. Setting up a
development workspace historically involved a lot of manual git
cloning and creating registry files for each used library.

The main purpose of specifying active packages is so that `dylan-tool`
can clone those packages into the workspace directory and create the
registry files for you accurately.  The registry points to the
workspace directory for active package libraries but points to the
installation directory, `${DYLAN}/pkg/...`, for all other
dependencies.

`dylan-tool` scans each active package for LID files and writes a
registry file for each one, with two exceptions:

1. If the .lid file has a Platforms: keyword in it and the current
   platform (e.g., x86_64-linux) isn't one of the values listed. (If
   there is no Platforms: keyword then the library is assumed to work
   on all platforms.)

1. If the .lid file is itself included in another LID file via the
   LID: keyword.

**Note:** If you use the same workspace directory on multiple
platforms (e.g., a network mounted directory or shared by a virtual
machine) you will need to run `dylan-tool update` on **both**
platforms so that the correct platform-specific registry entries are
created.  `dylan-tool` makes no attempt to figure out which packages
are "generic" and which are platform-specific, so it always writes
platform-specific registry files.

## Building Open Dylan in a Workspace

You can build Open Dylan itself with a workspace instead of using the
method described in
[opendylan/README.rst](https://github.com/dylan-lang/opendylan/blob/master/README.rst).
This section describes how to do that, but assumes you've read
[opendylan/README.rst](https://github.com/dylan-lang/opendylan/blob/master/README.rst)
to figure out what your build command should be.

The advantage of building this way is that there's no need to use Git
submodules. Not a huge benefit in and of itself, but in the long run
we expect use of the Dylan package system to be less of a maintenance
burden.

1.  Follow the first two steps in the Quick Start above to build
    `dylan-tool`.

1.  Create a workspace:

        $ dylan-tool new ws.od opendylan
        $ cd ws.od
        $ dylan-tool update

1.  Build Open Dylan. Here I'll assume we're building on Linux with
    MPS but your build command may differ. The **one** main difference
    from what's described in
    [opendylan/README.rst](https://github.com/dylan-lang/opendylan/blob/master/README.rst)
    is that you **must** pass `SKIP_SUBMODULE_CHECK=1` when you call
    `make`.  In this example we assume MPS is in the `${DYLAN}`
    directory and we put the final product in a directory called
    `opendylan-master`, but you can of course put them both wherever
    you want to.

        $ cd _build      # So that intermediate build products go here.
        $ ../opendylan/autogen.sh
        $ ../opendylan/configure --prefix=${DYLAN}/opendylan-master \
            --with-mps=${DYLAN}/mps-kit-1.114.0
        $ make SKIP_SUBMODULE_CHECK=1    # <-- THIS IS NEW
        $ make install

If all went well, you should now be able to run
`${DYLAN}/opendylan-master/bin/dylan-compiler -version` and see
something like "Version 2018.1pre".

As long as people still build Open Dylan with submodules, of course,
they need to be maintained alongside the package dependencies listed
in
[opendylan/pkg.json](https://github.com/dylan-lang/opendylan/blob/master/pkg.json).
If a dependency is added to (or removed from) Open Dylan, simple add
(or remove) it to the pkg.json file and run `dylan-tool
update` and commit that file with your change.

## Bugs

If you have a feature request, think something should be designed
differently, or find bugs, file a bug report
[here](https://github.com/cgay/dylan-tool/issues).

## TODO List

This only lists important items. There are TODOs in the code as well,
but mostly for smaller or less important items. Some of the items on
this list are more for pacman than dylan-tool.

### For 0.1.0

Version 0.1.0 will primarily work with packages at HEAD since that's
the way everyone currently expects to work on Dylan.  Better support
for numbered versions can come later.

* Improve output a bit. For example, don't display git clone output
  but do log all events somewhere for debugging purposes.

* Make a standard workspace for developing Open Dylan itself, such
  that it doesn't require the use of any submodules.

  - The airport examples are duplicated in documentation/ and
    dylan-programming/ so they're written to the registry twice and
    the last one "wins". Can one copy be deleted?  Make them into
    their own package? (The main effect of this is some annoying
    output when updating the workspace. Not urgent.)

  - Why didn't collection-extensions get checked out?:
    Wrote /home/cgay/dylan/opendylan.workspace/registry/x86_64-linux/testworks-specs
    No such file or directory: Can't start listing of /home/cgay/dylan/pkg/collection-extensions/head/src/
    No such file or directory: Can't start listing of /home/cgay/dylan/pkg/collection-extensions/head/src/
    Breaking into debugger.
    Trace/breakpoint trap
    Removing the 'head' directory above fixed it. Pretty sure this is from when I C-c'd out
    the first time because I was prompted to enter my ssh key. Need to be resilient to C-c.
    Write a "done" file, when the package download is complete?


### After 0.1.0

* Separate the dylan-tool command and the workspace library so that
  the latter can be re-used by deft. (Perhaps put the dylan-tool
  command-line in the tests/ subdirectory so it can be used as a
  manual test, if I decide deft is the way to go.)

* Integrate pacman and workspace tool into Deft.

* Think about whether and how it makes sense to integrate knowledge of
  packages and versioned dependencies into Open Dylan itself.

* Remove the assumption that git (and specifically github) is where
  all packages reside. Support tarballs and/or zip files.

* Improve version dependency specs. Can get inspiration from Cargo
  here.
