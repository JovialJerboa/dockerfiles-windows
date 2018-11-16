param (
    [Parameter(Mandatory=$true)][string]$ContainerTag
    ,[string]$BuildDefinitionsJsonFile = ".\build-definitions.json"
)

# Pull .NET tags from the container tag and the build-definitions.json file
$buildDefinitions = Get-Content $BuildDefinitionsJsonFile | ConvertFrom-Json
if ($true -eq ($ContainerTag -match '(netfx-(?<NetFxTag>[\d.]*))')) {
    $netFxTag = $Matches['NetFxTag']
    $netFxBuildDefinition = $buildDefinitions.netFxVersions | Where-Object { $_.name -eq $netFxTag } 
}
if ($true -eq ($ContainerTag -match '(dotnet-(?<DotNetTag>[\d.]*))')) {
    $dotNetTag = $Matches['DotNetTag']
    $dotNetBuildDefinition = $buildDefinitions.dotNetVersions | Where-Object { $_.name -eq $dotNetTag } 
}

# Dockerfile
switch -regex ($ContainerTag)
{
    'netfx-[\d.]*-dotnet-[\d.]*-webtools' {
        $dockerFile = 'netfx-dotnet-webtools'
    }
    'netfx-[\d.]*-dotnet-[\d.]*' {
        $dockerFile = 'netfx-dotnet'
    }
    'netfx-[\d.]*-webtools' {
        $dockerFile = 'netfx-webtools'
    }
    'netfx-[\d.]*' {
        $dockerFile = 'netfx'
    }
}

$retn = @{
    # Container
    ContainerTag = $ContainerTag;

    # Docker
    DockerFile = $dockerFile;

    # .NET Fx
    NetFxName = $netFxBuildDefinition.'name';
    NetFxTag = $netFxBuildDefinition.'tag';

    # .NET Core
    DotNetName = $dotNetBuildDefinition.'name';
    DotNetTag = $dotNetBuildDefinition.'tag';
    MSBuildSDKsPath = $dotNetBuildDefinition.'MSBuildSDKsPath';
}

return $retn