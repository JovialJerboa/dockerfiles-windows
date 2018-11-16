param (
    [Parameter(Mandatory=$true)][string]$BuildRootPath
    ,[Parameter(Mandatory=$true)][string]$ContainerTag
    ,[Parameter(Mandatory=$true)][string]$DockerFile
    ,[Parameter(Mandatory=$true)][string]$NetFxName
    ,[Parameter(Mandatory=$true)][string]$NetFxTag
    ,[string]$DotNetName = $null
    ,[string]$DotNetTag = $null
    ,[string]$MSBuildSDKsPath = $null
    ,[switch]$NoCache
    ,[switch]$PushToRegistry
)

# Variables
$DockerFilePath = "$BuildRootPath\$DockerFile"
$dockerBuildArgs = @("build")
if ($NoCache) { $dockerBuildArgs += "--no-cache" }
$dockerBuildArgs += "--build-arg","NETFX_TAG=$NetFxTag"

# Add dotnet components
if ($null -ne $DotNetTag) {
        # Sanity Check
    if ($null -eq $MSBuildSDKsPath) {
        Write-Error "Parameter 'MSBuildSDKsPath' is required when providing parameter 'DotNetTag'"
        return
    }
    $dockerBuildArgs += "--build-arg","DOTNET_TAG=$DotNetTag"
    $dockerBuildArgs += "--build-arg","MSBUILD_SDKS_PATH=$MSBuildSDKsPath"
}

# Finalise command
$dockerBuildArgs += "--tag","lflanagan/msbuild:$ContainerTag"
$dockerBuildArgs += "-f","$DockerFilePath","$BuildRootPath"

Write-Output "Building $ContainerTag"

# Build docker image
docker $dockerBuildArgs

# Push image(s) to docker hub
if ($true -eq $PushToRegistry) { docker push "lflanagan/msbuild:$ContainerTag" }