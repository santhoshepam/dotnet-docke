FROM buildpack-deps:trusty-scm

# Install the LKG preview build of the .NET CLI. This is done by downloading
# and installing the .deb file directly because there is a significant latency
# between the publishing of a .NET CLI Debian package and its availability on
# the package repository, so the simple "apt-get install dotnet" might not
# pick up the latest build.
#
# Because the dpkg command cannot install dependencies, treat errors as
# warnings and then use apt-get to install the dependencies.
RUN apt-get update \
    && wget https://dotnetcli.blob.core.windows.net/dotnet/beta/Installers/Latest/dotnet-ubuntu-x64.latest.deb \
    && dpkg --force-depends -i dotnet-ubuntu-x64.latest.deb \
    && apt-get -f -y --no-remove install \
    && rm dotnet-ubuntu-x64.latest.deb
