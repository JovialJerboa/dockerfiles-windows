# escape=`
FROM microsoft/dotnet:1.1.10-sdk-1.1.11 AS dotnet

FROM microsoft/dotnet-framework:4.7.2-sdk-20181009-windowsservercore-ltsc2016
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# see https://github.com/Microsoft/msbuild/issues/1697
ENV DOTNET_PATH="C:\Program Files\dotnet" `
    MSBuildSDKsPath="C:\Program Files\dotnet\sdk\1.0.4\Sdks"

RUN $env:PATH = $env:DOTNET_PATH + ';' + $env:PATH; `
	[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); `
    [Environment]::SetEnvironmentVariable('MSBuildSDKsPath', $env:MSBuildSDKsPath, [EnvironmentVariableTarget]::Machine)

COPY --from=dotnet ${DOTNET_PATH} ${DOTNET_PATH}