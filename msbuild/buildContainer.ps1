param (
    [Parameter(Mandatory=$true)][string]$BuildRootPath
    ,[Parameter(Mandatory=$true)][string]$DockerFile
    ,[Parameter(Mandatory=$true)][string]$NetFxName
    ,[Parameter(Mandatory=$true)][string]$NetFxTag
    ,[string]$DotNetName = $null
    ,[string]$DotNetTag = $null
    ,[string]$MSBuildSDKsPath = $null
    ,[boolean]$IncludeWebTools = $false
    ,[boolean]$PushToRegistry = $false
)

# Variables
$DockerFilePath = "$BuildRootPath\$DockerFile"
# $tag = "netfx-$($netFxVersion.'name')"
$tag = "netfx-$NetFxName"
$args = @("build","--build-arg","NETFX_TAG=$NetFxTag")

# Add dotnet components
if ($null -ne $DotNetTag) {
    # Sanity Check
    if ($null -eq $MSBuildSDKsPath) {
        Write-Error "Parameter 'MSBuildSDKsPath' is required when providing parameter 'DotNetTag'"
        return
    }
    $tag += "-dotnet-$DotNetName"
    $args += "--build-arg","DOTNET_TAG=$DotNetTag"
    $args += "--build-arg","MSBUILD_SDKS_PATH=$MSBuildSDKsPath"
}

# Add webtools components
if ($true -eq $IncludeWebTools) {
    $tag += "-webtools"
}

# Finalise command
$args += "--tag","lflanagan/msbuild:$tag","-f","$DockerFilePath","$BuildRootPath"

Write-Output "Building $tag"

# Build docker image
# docker build --build-arg NETFX_TAG=$netfxTag --build-arg DOTNET_TAG=$dotnetTag --build-arg MSBUILD_SDKS_PATH=$MSBuildSDKsPath -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath 
docker $args

# Push image(s) to docker hub
if ($true -eq $PushToRegistry) { docker push "lflanagan/msbuild:$tag" }