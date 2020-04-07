# scummvm-rpi
Docker Image configuration for building the Raspberry PI port for ScummVM.

Based on the work of Colin Snover (csnover) and Le Philousophe (lephilousophe).

This set up *does not* use the official toolchain which is provided by RaspberryPi team at their github (https://github.com/raspberrypi/tools.git). This is due to the fact that the official toolchain as of yet uses an old gcc version (4.9.3) which results in certain issues. Specifically, it won't be possible for ScummVM to compile with support for the current Fluidsynth developer package and the final build may have issues with memory management (eg. reporting free() calls on invalid pointers).

Hence, this project uses the toolchain provided as a Debian package for the armhf architecture. The result built executable was tested successfully on a Raspberry Pi 3B running Raspbian 3.2 (January 2020).

Base docker image is now: 
```
Debian 10.3
```

Third party libraries (developer packages) used (at the time of this document's update (Apr 7th 2020) are:
- gcc                    -- armhf 8.3.0-6
- a52dec                 -- liba52-0.7.4-dev armhf 0.7.4-19
- curl (with openssl)    -- libcurl4-openssl-dev:armhf (7.64.0-4+deb10u1)
- faad                   -- libfaad-dev armhf 2.8.8-3 
- ogg                    -- libogg-dev armhf 1.3.2-1+b1
- flac                   -- libflac-dev armhf 1.3.2-3
- fluidsynth             -- libfluidsynth-dev armhf 1.1.11-1
- freetype               -- libfreetype6 armhf 2.9.1-3+deb10u1
- jpeg-turbo             -- libjpeg62-turbo-dev armhf 1:1.5.2-2+b1
- mad                    -- libmad0-dev armhf 0.15.1b-10
- mpeg2                  -- libmpeg2-4-dev armhf 0.5.1-8
- png                    -- libpng16-16 armhf 1.6.36-6 
- SDL2                   -- libsdl2-dev armhf 2.0.9+dfsg1-1 
- SDL2-net               -- libsdl2-net-dev armhf 2.0.1+dfsg1-4
- libtheora              -- libtheora-dev armhf 1.1.1+dfsg.1-15
- libvorbis              -- libvorbis-dev armhf 1.3.6-2
- speechd                -- libspeechd-dev armhf 0.9.0-5
- zlib                   -- zlib1g-dev armhf 1:1.2.11.dfsg-1

Basic instructions:
- Install docker ("Docker Engine - Community" should work fine). Tested with version 19.03.8 (build afacb8b7f0) using containerd.io version 1.2.13 on Linux Ubuntu x64 16.04.6 LTS.
- Install docker-compose on your system. Tested with version 1.24.1, build 4667896b.

- Build the image with:
```
docker build -t "scummvm/scummvm-rpi:latest" -f "./Dockerfile" .
```

- Edit "docker-compose.override.yml" and replace the placeholder paths with your native system's paths, properly.

- Run the container with:
```
docker-compose run --rm raspberrypi
```

- From within the container, navigate to /data/sharedrepo, where the scummvm repo should be mounted.
```
cd /data/sharedrepo
```
- Then run the following sequence of commands (you can change the configure options to only build for some engines or disable certain scummvm features):
```
make clean; ./configure --host=raspberrypi --with-sdl-prefix=$RPI_ROOT/usr --with-png-prefix=$RPI_ROOT/usr --disable-debug --enable-release --enable-engine=testbed
make -j$(nproc)
```

- The output binary will be a file named "scummvm" in the current folder. Make sure to move or copy this file elsewhere before running "make clean", otherwise it will be deleted by the "make clean" commad. You can copy the resulting "scummvm" binary to a folder on your Rasbperry Pi SD card (the card that contains your OS for the Pi). Typically, the target path would be inside the "pi" user's home directory. For example, if you create a "scummvm" folder in your pi home directory on Raspbian and then mount your SD card on the Linux Ubuntu host PC, the target path might look like:
```
/media/<username>/rootfs/home/pi/scummvm
```

TODO:
- Test adding support for updated versions of the third party libraries (cross-compiled from source using scripts during the first phase of the Docker image)
- Ensure that the output binary will be created in a folder with other distribution related files (README, themes, translations.dat, engine related addons etc).

Reference links:
- Scummvm repository: https://github.com/scummvm/scummvm
- ScummVM wiki for compiling for RPi (may need updating): https://wiki.scummvm.org/index.php?title=Compiling_ScummVM/RPI
- https://github.com/csnover/scummvm-buildbot
- https://github.com/lephilousophe/dockerized-bb
