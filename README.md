# Pony (Intel to ARM) Cross Compiler

## Purpose

This ``Dockerfile`` creates a sandboxed, runnable `Pony Compiler
<http://ponylang.org>`_ environment based on the latest commit to master
on GitHub. We are cross compiling to the armhf (Raspberry Pi) platform.

## Credits

This project was inspired by
https://github.com/rbrewer123/docker_ponyc


## Requirements

This is tested with the following software:

* llvm-3.6
* docker 1.9.0 (running on OSX 10.11.2)

Since its main dependency is docker, it should run on any platform with
docker installed (e.g. OS X).  It may or may not work with earlier
versions of docker.  To install docker on your system, see the official
`docker installation instructions <https://docs.docker.com/installation>`_.


## Installation

To build the docker image::

```
  make build
```

To test your new image::

``` 
  make test
  make version
```

To push your new image::

```
  make push
```

You can see your new image with this command::

```
  docker images
```

Grab the ``ponyc`` script from github like this::

```
  git clone https://github.com/lispmeister/rpxp
```

## Run


To run ``ponyc`` from within the container, simply run the ``ponyc`` script::

  rpxp/ponyc --help


## Limitations 

If you discover any limitations or bugs, please submit a GitHub issue.

