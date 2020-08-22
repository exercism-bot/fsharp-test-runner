FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS build

# Create a new (temporary) project to install the packages used by
# solution projects that we can then copy for offline use in the runtime image
WORKDIR /tmp
RUN dotnet new xunit && \
    dotnet add package Microsoft.NET.Test.Sdk && \
    dotnet add package xunit && \
    dotnet add package xunit.runner.visualstudio && \
    dotnet add package FsUnit.xUnit

WORKDIR /app

COPY run.sh /opt/test-runner/bin/

# Download exercism tooling webserver
RUN wget -P /usr/local/bin https://github.com/exercism/local-tooling-webserver/releases/latest/download/exercism_local_tooling_webserver && \
    chmod +x /usr/local/bin/exercism_local_tooling_webserver

# Copy fsproj and restore as distinct layers
COPY src/Exercism.TestRunner.FSharp/Exercism.TestRunner.FSharp.fsproj ./
RUN dotnet restore -r linux-musl-x64

# Copy everything else and build
COPY src/Exercism.TestRunner.FSharp/ ./
RUN dotnet publish -r linux-musl-x64 -c Release -o /opt/test-runner --no-restore

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS runtime
WORKDIR /opt/test-runner

COPY --from=build /opt/test-runner/ . 
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /root/.nuget/packages/ /root/.nuget

ENTRYPOINT ["sh", "/opt/test-runner/bin/run.sh"]
