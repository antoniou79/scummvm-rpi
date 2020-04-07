ARG DEFAULT_OS_IMAGE=debian:10.3
FROM ${DEFAULT_OS_IMAGE} AS compiler
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
#
# [FIRST STAGE]
# INSTALLING THE TOOLCHAIN AND THIRD PARTY LIB (Developer packages)
#
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
USER root

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	       ccache \
	       dumb-init \
	       git \
	       gzip \
	       make \
	       rsync \
	       xz-utils \
	       zip \
	       unzip \
	       wget && \
	rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
# INSTALL THE TOOLCHAIN AND THE THIRD PARTY LIBRARIES
# --------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------
#
# Using (at the time this document was last updated):
# [*] gcc                    -- armhf 8.3.0-6
# [*] a52dec                 -- liba52-0.7.4-dev armhf 0.7.4-19
# [*] curl (with openssl)    -- libcurl4-openssl-dev:armhf (7.64.0-4+deb10u1)
# [*] faad                   -- libfaad-dev armhf 2.8.8-3 
# [*] ogg                    -- libogg-dev armhf 1.3.2-1+b1
# [*] flac                   -- libflac-dev armhf 1.3.2-3
# [*] fluidsynth             -- libfluidsynth-dev armhf 1.1.11-1
# [*] freetype               -- libfreetype6 armhf 2.9.1-3+deb10u1
# [*] jpeg-turbo             -- libjpeg62-turbo-dev armhf 1:1.5.2-2+b1
# [*] mad                    -- libmad0-dev armhf 0.15.1b-10
# [*] mpeg2                  -- libmpeg2-4-dev armhf 0.5.1-8
# [*] png                    -- libpng16-16 armhf 1.6.36-6 
# [*] SDL2                   -- libsdl2-dev armhf 2.0.9+dfsg1-1 
# [*] SDL2-net               -- libsdl2-net-dev armhf 2.0.1+dfsg1-4
# [*] libtheora              -- libtheora-dev armhf 1.1.1+dfsg.1-15
# [*] libvorbis              -- libvorbis-dev armhf 1.3.6-2
# [*] speechd                -- libspeechd-dev armhf 0.9.0-5
# [*] zlib                   -- zlib1g-dev armhf 1:1.2.11.dfsg-1
# implied                    -- libreadline7 armhf 7.0-5 
# implied                    -- libpulse-dev armhf 12.2-4+deb10u1
# implied                    -- libegl1-mesa-dev armhf 18.3.6-2+deb10u1 
# implied                    -- libgles2-mesa-dev armhf 18.3.6-2+deb10u1
# implied                    -- pkg-config amd64 0.29-6
# implied                    -- libjack-jackd2-0 armhf 1.9.12~dfsg-2
# implied                    -- libssl1.1 armhf 1.1.1d-0+deb10u2
# implied                    -- libsndio-dev armhf 1.5.0-3


RUN dpkg --add-architecture armhf && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		g++-arm-linux-gnueabihf \
		liba52-dev:armhf \
		libcurl4-openssl-dev:armhf \
		libfaad-dev:armhf \
		libogg-dev:armhf \
		libflac-dev:armhf \
		libfluidsynth-dev:armhf \
		libfreetype6-dev:armhf \
		libjpeg62-turbo-dev:armhf \
		libmad0-dev:armhf \
		libmpeg2-4-dev:armhf \
		libpng-dev:armhf \
		libsdl2-dev:armhf \
		libsdl2-net-dev:armhf \
		libtheora-dev:armhf \
		libvorbis-dev:armhf \
		libspeechd-dev:armhf \
		zlib1g-dev:armhf \
		&& \
	rm -rf /var/lib/apt/lists/*

# Raspberry PI libraries are mixed with original Debian
ENV RPI_ROOT=/

ENV HOST=arm-linux-gnueabihf

ENV \
	AR=/usr/bin/${HOST}-ar \
	AS=/usr/bin/${HOST}-as \
	CXXFILT=/usr/bin/${HOST}-c++filt \
	LD=/usr/bin/${HOST}-ld \
	LINK=/usr/bin/${HOST}-link \
	NM=/usr/bin/${HOST}-nm \
	OBJCOPY=/usr/bin/${HOST}-objcopy \
	OBJDUMP=/usr/bin/${HOST}-objdump \
	RANLIB=/usr/bin/${HOST}-ranlib \
	READELF=/usr/bin/${HOST}-readelf \
	STRINGS=/usr/bin/${HOST}-strings \
	ADDR2LINE=/usr/bin/${HOST}-addr2line \
	STRIP=/usr/bin/${HOST}-strip \
	GCC=/usr/bin/${HOST}-gcc \
	CPP=/usr/bin/${HOST}-cpp \
	CXX=/usr/bin/${HOST}-c++\
	GXX=/usr/bin/${HOST}-g++ \
	CC=/usr/bin/${HOST}-gcc \
	ACLOCAL_PATH=/usr/share/aclocal \
	PKG_CONFIG_SYSROOT_DIR=${RPI_ROOT} \
	PKG_CONFIG_LIBDIR=/usr/lib/$HOST \
	PKG_CONFIG_PATH=/usr/lib/$HOST/pkgconfig

RUN useradd -ms /bin/bash -d /home/scummvm -u 2899 -U scummvm
#
# Create folders and chown to scummvm:scummvm
#   - /home/scummvm
#   - /data/ccache
#   - /data/sharedrepo
RUN mkdir -p /home/scummvm /data/ccache /data/sharedrepo && \
    chown scummvm:scummvm /home/scummvm /data/ccache /data/sharedrepo

USER scummvm
WORKDIR /home/scummvm

