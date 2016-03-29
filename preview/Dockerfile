FROM buildpack-deps:trusty-scm

# Work around https://github.com/dotnet/cli/issues/1582 until Docker releases a
# fix (https://github.com/docker/docker/issues/20818). This workaround allows
# the container to be run with the default seccomp Docker settings by avoiding
# the restart_syscall made by LTTng which causes a failed assertion.
ENV LTTNG_UST_REGISTER_TIMEOUT 0

# Install the LKG preview build of the .NET CLI. This is done by downloading
# and installing the .deb file directly because there is a significant latency
# between the publishing of a .NET CLI Debian package and its availability on
# the package repository, so the simple "apt-get install dotnet" might not
# pick up the latest build.
#
# Because the dpkg command cannot install dependencies, treat errors as
# warnings and then use apt-get to install the dependencies.
RUN apt-get update \
    && wget https://dotnetcli.blob.core.windows.net/dotnet/beta/Installers/Latest/dotnet-host-ubuntu-x64.latest.deb \
    && wget https://dotnetcli.blob.core.windows.net/dotnet/beta/Installers/Latest/dotnet-sharedframework-ubuntu-x64.latest.deb \
    && wget https://dotnetcli.blob.core.windows.net/dotnet/beta/Installers/Latest/dotnet-sdk-ubuntu-x64.latest.deb \
    && dpkg --force-depends -i dotnet-host-ubuntu-x64.latest.deb \
    && dpkg --force-depends -i dotnet-sharedframework-ubuntu-x64.latest.deb \
    && dpkg --force-depends -i dotnet-sdk-ubuntu-x64.latest.deb \
    && apt-get -f -y --no-remove install \
    && rm dotnet-host-ubuntu-x64.latest.deb \
    && rm dotnet-sharedframework-ubuntu-x64.latest.deb \
    && rm dotnet-sdk-ubuntu-x64.latest.deb \
    && rm -rf /var/lib/apt/lists/*
