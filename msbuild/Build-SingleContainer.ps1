param (
    [Parameter(Mandatory=$true)][string]$ContainerTag
    ,[boolean]$PushToRegistry = $false
)

# Get build arguments
$scriptPath = $PSScriptRoot
$buildParameters = . .\Get-BuildParameters.ps1 -ContainerTag $ContainerTag
$arguments = @{
    BuildRootPath = $scriptPath
    ContainerTag = $buildParameters.ContainerTag
    DockerFile = $buildParameters.DockerFile
    NetFxName = $buildParameters.NetFxName
    NetFxTag = $buildParameters.NetFxTag
    DotNetName = $buildParameters.DotNetName
    DotNetTag = $buildParameters.DotNetTag
    MSBuildSDKsPath = $buildParameters.MSBuildSDKsPath
    PushToRegistry = $PushToRegistry
}

# Build
. "$scriptPath\Build-Container.ps1" @arguments

# Error handling
if ($LASTEXITCODE -ne 0) {
    # Set the exit code to be greater than 0 so the build is marked as failed in AppVeyor
    if ($env:APPVEYOR -eq $true) { $host.SetShouldExit(1) }
}