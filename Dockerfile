FROM mcr.microsoft.com/dotnet/sdk:5.0.100-alpine3.12-amd64 AS build
WORKDIR /app

# Download exercism tooling webserver
RUN wget -P /usr/local/bin https://github.com/exercism/tooling-webserver/releases/download/0.10.0/tooling_webserver && \
    chmod +x /usr/local/bin/tooling_webserver

# Copy fsproj and restore as distinct layers
COPY src/Exercism.TestRunner.FSharp/Exercism.TestRunner.FSharp.fsproj ./
RUN dotnet restore -r linux-musl-x64

# Copy everything else and build
COPY src/Exercism.TestRunner.FSharp/ ./
RUN dotnet publish -r linux-musl-x64 -c Release -o /opt/test-runner --no-restore -p:PublishReadyToRun=true

# Pre-install packages for offline usage
RUN dotnet add package Microsoft.NET.Test.Sdk -v 16.8.0 && \
    dotnet add package xunit -v 2.4.1 && \
    dotnet add package xunit.runner.visualstudio -v 2.4.3 && \
    dotnet add package FsUnit.xUnit -v 4.0.2

# Build runtime image
FROM mcr.microsoft.com/dotnet/sdk:5.0.100-alpine3.12-amd64 AS runtime
WORKDIR /opt/test-runner

COPY --from=build /opt/test-runner/ . 
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /root/.nuget/packages/ /root/.nuget/packages/

COPY run.sh /opt/test-runner/bin/

ENTRYPOINT ["sh", "/opt/test-runner/bin/run.sh"]
