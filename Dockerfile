# docker-ffmpeg-centos
# ffmpeg with lots of codecs on centos base

FROM centos
MAINTAINER Dave Snigier <dave@davesnigier.com>

RUN yum install -y \
  autoconf \
  automake \
  gcc \
  gcc-c++ \
  git \
  libtool \
  make \
  nasm \
  pkgconfig \
  zlib-devel


RUN mkdir /root/ffmpeg_sources
WORKDIR /root/ffmpeg_sources


# Yasm
# Yasm is an assembler used by x264 and FFmpeg.

RUN git clone --depth 1 git://github.com/yasm/yasm.git

RUN cd yasm && \
  autoreconf -fiv && \
  ./configure && \
  make && \
  make install


# libx264
# H.264 video encoder.

RUN git clone --depth 1 git://git.videolan.org/x264
RUN cd x264 && \
  ./configure --enable-static && \
  make && \
  make install


# libfdk_aac
# AAC audio encoder.

RUN git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
RUN cd fdk-aac && \
  autoreconf -fiv && \
  ./configure --disable-shared && \
  make && \
  make install


# libmp3lame
# MP3 audio encoder.

RUN curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
RUN tar xzvf lame-3.99.5.tar.gz
RUN cd lame-3.99.5 && \
  ./configure --disable-shared --enable-nasm && \
  make && \
  make install


# libopus
# Opus audio decoder and encoder.

RUN git clone git://git.opus-codec.org/opus.git
RUN cd opus && \
  autoreconf -fiv && \
  ./configure --disable-shared && \
  make && \
  make install


# libogg
# Ogg bitstream library. Required by libtheora and libvorbis.

RUN curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
RUN tar xzvf libogg-1.3.2.tar.gz
RUN cd libogg-1.3.2 && \
  ./configure --disable-shared && \
  make && \
  make install


# libvorbis
# Vorbis audio encoder. Requires libogg.

RUN curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
RUN tar xzvf libvorbis-1.3.4.tar.gz
RUN cd libvorbis-1.3.4 && \
  ./configure --with-ogg --disable-shared && \
  make && \
  make install


# libvpx
# VP8/VP9 video encoder.

RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
RUN cd libvpx && \
  ./configure --disable-examples --as=yasm && \
  make && \
  make install


# ffmpeg (finally!!!)

RUN git clone --depth 1 git://source.ffmpeg.org/ffmpeg
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig
RUN cd ffmpeg &&\
  ./configure --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 &&\
  make &&\
  make install &&\
  hash -r


# cleanup 
WORKDIR /root
RUN rm -rf /root/ffmpeg_sources

RUN yum erase -y \
  autoconf \
  automake \
  gcc \
  gcc-c++ \
  git \
  libtool \
  nasm \
  zlib-devel

RUN yum clean all
