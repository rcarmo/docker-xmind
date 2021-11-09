FROM ghcr.io/linuxserver/baseimage-rdesktop-web:bionic

ENV \
  CUSTOM_PORT="8080" \
  GUIAUTOSTART="true" \
  HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dbus \
    fcitx-rime \
    fonts-wqy-microhei \
    ttf-mscorefonts-installer \
    openjdk-8-jre \
    libgtk2.0-0 \
    libwebkitgtk-1.0-0 \
    lame \
    libc6 \
    libglib2.0-0 \
    libnss3 \
    libqpdf21 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    ttf-wqy-zenhei \
    wget \
    unzip && \
  echo "**** install XMind 8 ****" && \
  mkdir -p /opt/xmind && \
  cd /opt/xmind && \
  curl -Lo /tmp/xmind8.zip https://www.xmind.net/xmind/downloads/xmind-8-update9-linux.zip && \
  unzip -q /tmp/xmind8.zip -d /opt/xmind && \
  echo "**** install fonts ****" && \
  mkdir -p /usr/share/fonts/xmind/ && \
  cp -R /opt/xmind/fonts/* /usr/share/fonts/xmind/ && \
  fc-cache -f && \
  echo "**** setting up user config ****" && \
  sed -i "s/\.\.\/workspace/@user\.home\/.workspace/g" "/opt/xmind/XMind_amd64/XMind.ini" && \
  sed -i "s/\.\/configuration/@user\.home\/\.configuration/g" "/opt/xmind/XMind_amd64/XMind.ini" && \
  sed -i "s/^\.\./\/opt\/xmind/g" "/opt/xmind/XMind_amd64/XMind.ini" && \
  dbus-uuidgen > /etc/machine-id && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.build-date=${BUILD_DATE}