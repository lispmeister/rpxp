# Raspberry Pi cross-compilation for Pony in a Docker container.

Installs
[the Raspberry Pi cross-compilation Pony toolchain](https://github.com/ponylang/ponyc)
onto the
[ubuntu:trusty Docker image](https://registry.hub.docker.com/_/ubuntu/).

This project is available as
[lispmeister/rpxp](https://registry.hub.docker.com/u/lispmeister/rpxp)
on [Docker Hub](https://hub.docker.com/), and as
[lispmeister/rpxp](https://github.com/lispmeister/rpxp) on [GitHub](https://github.com).

Please raise any issues on the [GitHub issue tracker](https://github.com/lispmeister/rpxp).

## Features

* the gcc-linaro-arm-linux-gnueabihf-raspbian toolchain from [raspberrypi/tools](https://github.com/raspberrypi/tools)
* commands in the container are run as the calling user, so that any created files have the expected ownership (ie. not root)
* make variables (`CC`, `LD` etc) are set to point to the appropriate tools in the container
* `ARCH`, `CROSS_COMPILE` and `HOST` environment variables are set in the container
* symlinks such as `rpxp-ponyc` are created in `/usr/local/bin`
* current directory is mounted as the container's workdir, `/build`
* works with boot2docker on OSX

## Installation

This image is not intended to be run manually. Instead, there is a helper script which comes bundled with the image.

To install the helper script, run the image with no arguments, and redirect the output to a file.

eg.
```
docker run lispmeister/rpxp > rpxp
chmod +x rpxp
mv rpxp ~/bin/
```

## Usage

`rpxp [command] [args...]`

Execute the given command-line inside the container.

If the command matches one of the rpxc built-in commands (see below), that will be executed locally, otherwise the command is executed inside the container.

---

`rpxp -- [command] [args...]`

To force a command to run inside the container (in case of a name clash with a built-in command), use `--` before the command.

### Built-in commands

`rpxp update-image`

Fetch the latest version of the docker image.

---

`rpxp update-script`

Update the installed rpxp script with the one bundled in the image.

----

`rpxp update`

Update both the docker image, and the rpxp script.

## Configuration

The following command-line options and environment variables are used. In all cases, the command-line option overrides the environment variable.

### RPXP_CONFIG / --config &lt;path-to-config-file&gt;

This file is sourced if it exists.

Default: `~/.rpxp`

### RPXP_IMAGE / --image &lt;docker-image-name&gt;

The docker image to run.

Default: sdt4docker/raspberry-pi-cross-compiler

### RPXP_ARGS / --args &lt;docker-run-args&gt;

Extra arguments to pass to the `docker run` command.

## Examples

`rpxp make`

Build the Makefile in the current directory.

---

`rpxp rpxp-ponyc -o hello-world hello-world.c`

Standard bintools are available by adding an `rpxp-` prefix.

---

`rpxp bash -c 'find . -name \*.o | sort > objects.txt'`

Note that commands are executed verbatim. If you require any shell processing for environment variable expansion or redirection, please use `bash -c 'command args...'`.

---

More examples can be found in the [examples directory](examples).

## Acknowledgements
This project is loosly based on
[sdt4docker/raspberry-pi-cross-compiler](https://github.com/sdt/docker-raspberry-pi-cross-compiler)
by Stephen Thirlwall.
