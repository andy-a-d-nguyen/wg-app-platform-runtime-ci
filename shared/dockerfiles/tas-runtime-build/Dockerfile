FROM ubuntu:jammy

ARG TARGETARCH

LABEL org.cloudfoundry.tas-runtime-build.dockerfile.url="https://github.com/cloudfoundry/wg-app-platform-runtime-ci/blob/main/shared/dockerfiles/tas-runtime-build/Dockerfile"
LABEL org.cloudfoundry.tas-runtime-build.notes.md="Main image used for testing all tests in this repo that doesn't require a DB"

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && apt-get install --assume-yes --no-install-recommends \
    apparmor \
    ansible \
    bsdextrautils \
    build-essential \
    ca-certificates \
    curl \
    dnsutils \
    dnsmasq \
    dos2unix \
    file \
    flex \
    fuse \
    gettext \
    git \
    gpg \
    graphviz \
    htop \
    iproute2 \
    iptables \
    iputils-ping \
    jq \
    kmod \
    libfontconfig1-dev \
    libfreetype6 \
    libjpeg-dev \
    libpng-dev \
    libpython3-dev \
    libreadline-dev\
    libseccomp-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    lsof \
    mkisofs \
    mercurial \
    mingw-w64 \
    netcat \
    netcat-openbsd \
    net-tools \
    nginx \
    openssh-client \
    openssl \
    pandoc \
    psmisc \
    python3-pip \
    python3-venv \
    rsync \
    rsyslog \
    ssh \
    strace \
    sudo \
    uidmap \
    unzip \
    vim \
    wget \
    xfsprogs \
    xorriso \
    zip \
    zlib1g-dev

RUN pip install ansible

# APT/DEB/GPG Config for extra APT repos + pkgs
#    Terraform CLI
RUN \
  curl -L "https://apt.releases.hashicorp.com/gpg" | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(cat /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f 2) main" | tee /etc/apt/sources.list.d/hashicorp.list; \
  apt-get update && apt-get install --assume-yes --no-install-recommends terraform packer

#    gCloud CLI / SDK
RUN \
  curl -L "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg; \
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list; \
  apt-get update && apt-get install --assume-yes --no-install-recommends google-cloud-cli

#    GitHub CLI
RUN \
  curl -L "https://cli.github.com/packages/githubcli-archive-keyring.gpg" -o /usr/share/keyrings/githubcli-archive-keyring.gpg; \
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list; \
  apt-get update && apt-get install --assume-yes --no-install-recommends gh


# Downloaded Utilities
#    cf cli
RUN \
  if [ "${TARGETARCH}" = "amd64" ]; then cf_arch="linux64"; else cf_arch="linuxarm64"; fi; \
  cf_cli_version="$(curl -s https://api.github.com/repos/cloudfoundry/cli/releases | jq -r '.[0].name' | sed 's/v//g')" && \
  url="https://packages.cloudfoundry.org/stable?release=${cf_arch}-binary&version=${cf_cli_version}&source=github-rel" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/cf8 /usr/local/bin/cf8 && ln -sf /usr/local/bin/cf8 /usr/local/bin/cf
#    bosh cli
RUN \
  url="$(curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains($target_arch))).browser_download_url')" && \
  curl -L "${url}" -o /tmp/bosh && \
  install /tmp/bosh /usr/local/bin/bosh

#    bosh bootloader (BBL)
RUN \
  url="$(curl -s https://api.github.com/repos/cloudfoundry/bosh-bootloader/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains($target_arch))).browser_download_url')" && \
  curl -L "${url}" -o /tmp/bbl && \
  install /tmp/bbl /usr/local/bin/bbl

#    Routing API CLI (rtr)
RUN \
  url="$(curl -s https://api.github.com/repos/cloudfoundry/routing-api-cli/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains($target_arch))).browser_download_url')" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/rtr-linux-${TARGETARCH} /usr/local/bin/rtr

#    OM Cli
RUN \
  url="$(curl -s https://api.github.com/repos/pivotal-cf/om/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains("tar"))and (.name | contains($target_arch))).browser_download_url')" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/om /usr/local/bin/om


#    aws cli
RUN \
  if [ "${TARGETARCH}" = "amd64" ]; then aws_arch="x86_64"; else aws_arch="aarch64"; fi; \
  curl -L "https://awscli.amazonaws.com/awscli-exe-linux-$aws_arch.zip" -o /tmp/awscliv2.zip; \
  cd /tmp; \
    unzip awscliv2.zip; \
    ./aws/install

#    YTT
RUN \
  url="$(curl -s https://api.github.com/repos/carvel-dev/ytt/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select(.name == "ytt-linux-" + $target_arch).browser_download_url')" && \
  curl -L "${url}" -o /tmp/ytt && \
  install /tmp/ytt /usr/local/bin/ytt

#    grype
RUN \
  url="$(curl -s https://api.github.com/repos/anchore/grype/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains("tar")) and (.name | contains($target_arch))).browser_download_url')" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/grype /usr/local/bin/grype

#    syft
RUN \
  url="$(curl -s https://api.github.com/repos/anchore/syft/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains("tar")) and (.name | contains($target_arch))).browser_download_url')" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/syft /usr/local/bin/syft

#    yq
RUN \
  url="$(curl -s https://api.github.com/repos/mikefarah/yq/releases | jq -r --arg target_arch "${TARGETARCH}" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains("tar")) and (.name | contains($target_arch)) ).browser_download_url')" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/yq_linux_${TARGETARCH} /usr/local/bin/yq


#    lychee
RUN \
  if [ "${TARGETARCH}" = "amd64" ]; then lychee_arch="x86_64"; else lychee_arch="aarch64"; fi; \
  url="$(curl -s https://api.github.com/repos/lycheeverse/lychee/releases | jq -r --arg lychee_arch "$lychee_arch" '.[0].assets[] | select((.name | contains("linux")) and (.name | contains($lychee_arch)) and (.name | contains("gnu")) ).browser_download_url')" && \
  echo "${url}" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/lychee /usr/local/bin/lychee

# install govc
RUN \
  if [ "${TARGETARCH}" = "amd64" ]; then arch="x86_64"; else arch="arm64"; fi; \
  url="$(curl -s https://api.github.com/repos/vmware/govmomi/releases | jq -r --arg arch "$arch" '.[0].assets[] | select((.name | contains("Linux")) and (.name | contains($arch)) and (.name | contains("govc")) ).browser_download_url')" && \
  echo "${url}" && \
  curl -L "${url}" | tar -xz -C /tmp/ && \
  install /tmp/govc /usr/local/bin/govc

#   cleanup afterwards
RUN \
  rm -rf /tmp/*; \
  chmod 1777 /tmp

# Install Programming Languages
#    golang
ARG GO_VERSION
RUN rm -rf /usr/local/go
RUN wget -qO- "https://dl.google.com/go/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" | tar -C /usr/local -xzf -
ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin
RUN go install github.com/square/certstrap@latest
RUN go install github.com/onsi/ginkgo/v2/ginkgo@latest
RUN go install github.com/stephendotcarter/unpack@latest
RUN go install github.com/vito/gosub@master
RUN go install github.com/cloudfoundry/uptimer@latest

#    staticcheck
RUN \
  staticcheck_version="$(curl -s https://api.github.com/repos/dominikh/go-tools/releases | jq -r '.[0].tag_name')" && \
  go install "honnef.co/go/tools/cmd/staticcheck@$staticcheck_version"

#    credhub cli
RUN \
  credhub_version="$(curl -s https://api.github.com/repos/cloudfoundry/credhub-cli/releases | jq -r '.[0].tag_name')" && \
  go install "code.cloudfoundry.org/credhub-cli@$credhub_version" && \
  mv "$(which credhub-cli)" "$(dirname "$(which credhub-cli)")/credhub"

# nats-server cli
#
RUN \
  nats_url="$(curl -s https://api.github.com/repos/nats-io/nats-server/releases | jq -r --arg arch "$TARGETARCH" '.[0].assets[] | select((.name | contains("-linux-")) and (.name | contains($arch)) and (.name | contains(".tar.gz"))).browser_download_url')" && \
  curl -L "${nats_url}" | tar -zx --strip-components=1 --wildcards -C /usr/local/bin '*/nats-server'

#    ruby
ARG RUBY_INSTALLER_VERSION
RUN curl -L "https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALLER_VERSION}.tar.gz" | tar -zx -C /tmp/ && \
  cd "/tmp/ruby-install-${RUBY_INSTALLER_VERSION}" && \
  make install

ARG RUBY_VERSION
RUN ruby-install ruby "${RUBY_VERSION}" -- --disable-install-rdoc
ENV PATH ${PATH}:/root/.gem/ruby/${RUBY_VERSION}/bin:/opt/rubies/ruby-${RUBY_VERSION}/lib/ruby/gems/${RUBY_VERSION}/bin:/opt/rubies/ruby-${RUBY_VERSION}/bin
RUN \
  gem install \
    bundler \
    cf-uaac \
    debugger-ruby_core_source

# Delete apt caches after intalling everything (especially ruby which does its own apt stuff apparently)
RUN rm -rf /var/lib/apt/lists/*

RUN groupadd -g 5000 nonroot && useradd -ms /bin/bash -u 5000 -g 5000 nonroot

CMD /bin/bash
