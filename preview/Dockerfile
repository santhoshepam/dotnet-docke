FROM buildpack-deps:jessie-scm

# Work around https://github.com/dotnet/cli/issues/1582 until Docker releases a
# fix (https://github.com/docker/docker/issues/20818). This workaround allows
# the container to be run with the default seccomp Docker settings by avoiding
# the restart_syscall made by LTTng which causes a failed assertion.
ENV LTTNG_UST_REGISTER_TIMEOUT 0

# Install .NET CLI dependencies
RUN echo "deb [arch=amd64] http://llvm.org/apt/jessie/ llvm-toolchain-jessie-3.6 main" > /etc/apt/sources.list.d/llvm.list \
    && wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        clang-3.5 \
        libc6 \
        libcurl3 \
        libgcc1 \
        libicu52 \
        liblldb-3.6 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libtinfo5 \
        libunwind8 \
        libuuid1 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET CLI
RUN wget https://dotnetcli.blob.core.windows.net/dotnet/beta/Binaries/Latest/dotnet-dev-debian-x64.latest.tar.gz \
    && mkdir /usr/share/dotnet \
    && tar -zxvf dotnet-dev-debian-x64.latest.tar.gz -C /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet-dev-debian-x64.latest.tar.gz
