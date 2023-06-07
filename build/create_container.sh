apt-get update && \
      apt-get -y install sudo
sudo sed -i "s/^deb/deb [arch=amd64,i386]/g" /etc/apt/sources.list
echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ bionic main universe multiverse restricted" | sudo tee -a /etc/apt/sources.list
echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ bionic-security main universe multiverse restricted" | sudo tee -a /etc/apt/sources.list
echo "deb [arch=arm64,armhf] http://ports.ubuntu.com/ bionic-updates main universe multiverse restricted" | sudo tee -a /etc/apt/sources.list
sudo dpkg --add-architecture armhf
sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    gcc-8-arm-linux-gnueabihf \
    g++-8-arm-linux-gnueabihf \
    binutils-arm-linux-gnueabihf \
    build-essential \
    git \
    pkg-config \
    fakeroot \
    rpm \
    sudo \
    apt-transport-https \
    ca-certificates \
    libx11-dev:armhf \
    libx11-xcb-dev:armhf \
    libxkbfile-dev:armhf \
    libsecret-1-dev:armhf \
    curl \
    gnupg \
    unzip