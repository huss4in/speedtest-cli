FROM ubuntu:rolling

RUN set -eux;\
	apt-get update;\
	apt-get full-upgrade -y;\
	apt-get install -y\
	ca-certificates\
	dirmngr\
	gnupg\
	wget\
	curl\
	\
	gcc\
	libc6-dev\
	make\
	upx\
	\
	libc6-dev-arm64-cross\
	libc6-dev-armel-cross\
	libc6-dev-armhf-cross\
	libc6-dev-i386-cross\
	libc6-dev-mips64el-cross\
	libc6-dev-ppc64el-cross\
	libc6-dev-riscv64-cross\
	libc6-dev-s390x-cross\
	\
	gcc-aarch64-linux-gnu\
	gcc-arm-linux-gnueabi\
	gcc-arm-linux-gnueabihf\
	gcc-i686-linux-gnu\
	gcc-mips64el-linux-gnuabi64\
	gcc-powerpc64le-linux-gnu\
	gcc-riscv64-linux-gnu\
	gcc-s390x-linux-gnu\
	\
	arch-test\
	file\
	;\
	rm -rf /var/lib/apt/lists/*

RUN apt update -y && apt install -y git zsh bat fzf ruby-full; rm -rf /var/lib/apt/lists/*;
RUN git clone https://github.com/huss4in7/dotfiles /dotfiles;
RUN	set -eux;\
	gem install colorls;\
	yes exit | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";\
	chsh -s $(command -v zsh);\
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions;\
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting;\
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k;\
	cp /dotfiles/config/.p10k.zsh /root; touch /root/.zshrc;\
	cat /dotfiles/config/.zshrc/start.zshrc > /root/.zshrc;\
	echo "export ZSH=\"/root/.oh-my-zsh\"" >> /root/.zshrc;\
	cat /dotfiles/config/.zshrc/end.zshrc >> /root/.zshrc;
RUN set -eux;\
	sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" rustup.sh -y;\
	/root/.cargo/bin/cargo install ripgrep exa;

ENV INSTALL="/usr/src"
WORKDIR $INSTALL/speedtest


# https://musl.libc.org/releases musl-1.2.2.tar.gz
ARG MUSL_VERSION=1.2.2
ENV MUSL_NAME="musl.tgz"

# Download musl build tools
RUN set -eux;\
	curl -o /tmp/$MUSL_NAME     "https://musl.libc.org/releases/musl-$MUSL_VERSION.tar.gz";\
	curl -o /tmp/$MUSL_NAME.asc "https://musl.libc.org/releases/musl-$MUSL_VERSION.tar.gz.asc";
# Verify signature.
RUN set -eux;\
	export GNUPGHOME="$(mktemp -d)";\
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 836489290BB6B70F99FFDA0556BCDB593020450F;\
	gpg --batch --verify /tmp/$MUSL_NAME.asc /tmp/$MUSL_NAME;gpgconf --kill all;\
	rm  -rf "$GNUPGHOME" /tmp/$MUSL_NAME.asc;
# Extract.
RUN set -eux;\
	mkdir $INSTALL/musl;\
	tar --extract --file /tmp/$MUSL_NAME --directory $INSTALL/musl --strip-components 1;\
	rm /tmp/$MUSL_NAME;


# https://ftp.gnu.org/gnu/tar tar-1.34.tar.gz
ARG TAR_VERSION=1.34
ENV TAR_NAME="tar.tgz"

# Download musl build tools
RUN set -eux;\
	curl -o /tmp/$TAR_NAME     "https://ftp.gnu.org/gnu/tar/tar-$TAR_VERSION.tar.gz";\
	curl -o /tmp/$TAR_NAME.sig "https://ftp.gnu.org/gnu/tar/tar-$TAR_VERSION.tar.gz.sig";
# Verify signature.
RUN set -eux;\
	export GNUPGHOME="$(mktemp -d)";\
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 325F650C4C2B6AD58807327A3602B07F55D0C732;\
	gpg --batch --verify /tmp/$TAR_NAME.sig /tmp/$TAR_NAME;gpgconf --kill all;\
	rm  -rf "$GNUPGHOME" /tmp/$TAR_NAME.sig;
# Extract.
RUN set -eux;\
	mkdir $INSTALL/tar;\
	tar --extract --file /tmp/$TAR_NAME --directory $INSTALL/tar --strip-components 1;\
	rm /tmp/$TAR_NAME;


# https://ftp.gnu.org/gnu/gzip gzip-1.11.tar.gz
ARG GZIP_VERSION=1.11
ENV GZIP_NAME="gzip.tgz"

# Download musl build tools
RUN set -eux;\
	curl -o /tmp/$GZIP_NAME     "https://ftp.gnu.org/gnu/gzip/gzip-$GZIP_VERSION.tar.gz";\
	curl -o /tmp/$GZIP_NAME.sig "https://ftp.gnu.org/gnu/gzip/gzip-$GZIP_VERSION.tar.gz.sig";
# Verify signature.
RUN set -eux;\
	export GNUPGHOME="$(mktemp -d)";\
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 155D3FC500C834486D1EEA677FD9FCCB000BEEEE;\
	gpg --batch --verify /tmp/$GZIP_NAME.sig /tmp/$GZIP_NAME;gpgconf --kill all;\
	rm  -rf "$GNUPGHOME" /tmp/$GZIP_NAME.sig;
# Extract.
RUN set -eux;\
	mkdir $INSTALL/gzip;\
	tar --extract --file /tmp/$GZIP_NAME --directory $INSTALL/gzip --strip-components 1;\
	rm /tmp/$GZIP_NAME;


ARG ARTIFACTS="artifacts"
ENV ARTIFACTS=$ARTIFACTS

ARG TARGET_SPT_NAME="speedtest-c"
ENV TARGET_SPT_NAME=$TARGET_SPT_NAME

ARG TARGET_TAR_NAME="tar"
ENV TARGET_TAR_NAME=$TARGET_TAR_NAME

ARG TARGET_GZP_NAME="gzip"
ENV TARGET_GZP_NAME=$TARGET_GZP_NAME

ARG TARGET_CAC_NAME="ca-certificates"
ENV TARGET_CAC_NAME=$TARGET_CAC_NAME

COPY . .

# CMD ["zsh"]

RUN make clean build TARGET_ARCH='amd64'    TARGET_HOST='x86_64'   SPTCLI_ARCH='x86_64'  CROSS_COMPILE='x86_64-linux-gnu-';
RUN make clean build TARGET_ARCH='i386'     TARGET_HOST='i386'     SPTCLI_ARCH='i386'    CROSS_COMPILE='i686-linux-gnu-';
RUN make clean build TARGET_ARCH='armv5'    TARGET_HOST='arm'      SPTCLI_ARCH='arm'     CROSS_COMPILE='arm-linux-gnueabi-';
RUN make clean build TARGET_ARCH='armv6'    TARGET_HOST='arm'      SPTCLI_ARCH='armhf'   CROSS_COMPILE='arm-linux-gnueabihf-';
RUN make clean build TARGET_ARCH='armv7'    TARGET_HOST='arm'      SPTCLI_ARCH='armhf'   CROSS_COMPILE='arm-linux-gnueabihf-';
RUN make clean build TARGET_ARCH='arm64v8'  TARGET_HOST='aarch64'  SPTCLI_ARCH='aarch64' CROSS_COMPILE='aarch64-linux-gnu-';
RUN make clean build TARGET_ARCH='riscv64'  TARGET_HOST='riscv64'  SPTCLI_ARCH='i386'    CROSS_COMPILE='riscv64-linux-gnu-';
RUN make clean build TARGET_ARCH='ppc64le'  TARGET_HOST='ppc64le'  SPTCLI_ARCH='i386'    CROSS_COMPILE='powerpc64le-linux-gnu-' CFLAGS+='-mlong-double-64';
RUN make clean build TARGET_ARCH='mips64le' TARGET_HOST='mips64el' SPTCLI_ARCH='i386'    CROSS_COMPILE='mips64el-linux-gnuabi64-';
RUN make clean build TARGET_ARCH='s390x'    TARGET_HOST='s390x'    SPTCLI_ARCH='i386'    CROSS_COMPILE='s390x-linux-gnu-';

# Compress executables
RUN find $ARTIFACTS -type f -exec upx {} \;


# Copy the CA Certificate
RUN set -eux;\
	env GZIP=-9 tar --create --gzip --verbose --directory /etc/ssl/certs/ ca-certificates.crt --file $INSTALL/ca-certificates.tgz;\
	find $ARTIFACTS -name speedtest-c -type f -exec dirname {} \; | xargs --replace={} cp $INSTALL/ca-certificates.tgz {}/$TARGET_CAC_NAME.tgz


CMD ["zsh"]
