# Cross-compiling template

This project is a template for quickly setting up a CMake+Docker-based cross-compiling environment for all the target systems supported by [Dockcross](https://github.com/dockcross/dockcross).

Dockcross is a powerful set of tools that greatly simplifies the task of cross-compiling for embedded (many) devices. If your project needs many external libraries, though, you still have to cross-compile those libraries, since Dockcross images come with the bare minimum for C/C++ compiling (i.e. the standard libraries).

This template aims at helping to **overcome this problem**.

The approach here is to cross-compile the dependencies within the docker image via proper Dockerfiles, so that you can build **tailored Dockcross images** that also contain your **cross-compiled dependencies**.

Furthermore, this template also provides a **basic backbone for a multiplatform project** plus three example Dockerfiles (for mipsel, ARMv7 and ARMv7a) that provide ncurses, readline, openssl, mosquitto, and lua5.3 libraries.

The project is based on CMake and has template targets for building static and shared libraries plus an executable. It also **uses Git tags for managing number versioning in-code**.

# Instructions

## Step 1: Customize and build your Dockcross image
Take as example the `arm7.Dockerfile`: there are several steps showing how different libraries are cross compiled within the image. If the provided libraries are not enough, just add your own. My suggestion is to start with the provided image, build it with
```bash
$ docker build -t arm7 .
$ docker run --rm arm7 > arm7 && chmod a+x arm7
```
then open a shell with `./arm7 bash`. Within this shell try to download, configure and cross compile the library you need, following the library instructiond on cross-compiling (this often needs to pass some options to the `configure` script or to the cmake command).
Once you figured out how to cross-compile the library you need, just add an additional `RUN` section at the end of the dockerfile.

When you are done, **remember to uncomment the latter lines** in the original dockerfile, removing unnecessary intermidiate build directories to save disk space in the resulting docker image.

From now on, you can prepend the `./arm7` command to build instructions.

## Step2: Configure your project
For configuring the project, the usual CMake command must be prepended with the magic `./arm7` (or whichever is the name of your cross-build image) command:
```bash
# from within your project root directory
$ ./arm7 cmake -Bxbuild -H. -DCMAKE_BUILD_TYPE=Debug
```
while if you want to configure for your current (host) platform:
```bash
$ cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=Debug
```

**IMPORTANT NOTE**: the Dockecross images mount the current working directory within the container, so that in order to access files in your project root you *must* invoke cmake from the project root. If you are tempred to do `cd xbuild; ./arm7 cmake ..` you will loose access to the project root and something probably will not work.

## Step 3: Build the project
For building, use the make command:
```bash
# from within your project root directory
$ ./arm7 make -Cxbuild
```
while if you want to build for your current (host) platform:
```bash
$ make -Cbuild
```

**IMPORTANT NOTE**: as per the note above, please invoke `./arm7 make` from the project root using the `-C` flag.

## Step 4: Installing the built binaries
You can now copy the binaries to the target platform according to your preferred procedure. I am here suggesting the one I find more effective and quick, though.

You have to set-up your target system by installing the `sshfs` package. This service allows you to mount a folder in the remote (target) system onto a folder of your development machine:
```bash
# from within your project root directory
$ sshfs user@target.ip:/path/to/prefix ./products
```

This command mounts the prefix directory on the target system onto the `products` subdir of your project directory. Since the Dockerfile install target is configured to install binaries into `products`, if you do
```bash
$ ./arm7 make -Cxbuild install
```
this installs the built stuff into `products/bin`, `products/lib`, `products/include`. In turn, since `products` mounts the prefix dir of the target system, the command `./arm7 make -Cxbuild install` compiles **and** copies the build results into the destination system in one single line. If you set `/usr/local` as prefix dir, your compiled stuff will end in `/usr/local/bin` etc.
