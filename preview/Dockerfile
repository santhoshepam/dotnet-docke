FROM buildpack-deps:jessie-scm

# Work around https://github.com/dotnet/cli/issues/1582 until Docker releases a
# fix (https://github.com/docker/docker/issues/20818). This workaround allows
# the container to be run with the default seccomp Docker settings by avoiding
# the restart_syscall made by LTTng which causes a failed assertion.
ENV LTTNG_UST_REGISTER_TIMEOUT 0

# Install .NET CLI dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libtinfo5 \
        libunwind8 \
        libuuid1 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install the LKG preview build of the .NET CLI
RUN wget -q https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/Latest/dotnet-dev-debian-x64.latest.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet-dev-debian-x64.latest.tar.gz -C /usr/share/dotnet \
    && rm dotnet-dev-debian-x64.latest.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
