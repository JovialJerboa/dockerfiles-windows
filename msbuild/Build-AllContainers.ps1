param (
    [int]$ThrottleLimit = 0,
    [boolean]$PushToRegistry = $false
)

# Define buildContainers workflow
workflow buildContainers {
    param (
        [string]$ScriptPath
        ,[object]$BuildDefinitions
        ,[int]$ThrottleLimit
        ,[boolean]$PushToRegistry
    )
    foreach -parallel -throttle $ThrottleLimit ($containerTag in $BuildDefinitions.containerTags) {
        InlineScript {
            $scriptPath = $using:ScriptPath
            $buildParameters = . "$scriptPath\Get-BuildParameters.ps1" -ContainerTag $using:containerTag -BuildDefinitionsJsonFile "$scriptPath\build-definitions.json"
            $arguments = @{
                BuildRootPath = $scriptPath
                ContainerTag = $buildParameters.ContainerTag
                DockerFile = $buildParameters.DockerFile
                NetFxName = $buildParameters.NetFxName
                NetFxTag = $buildParameters.NetFxTag
                DotNetName = $buildParameters.DotNetName
                DotNetTag = $buildParameters.DotNetTag
                MSBuildSDKsPath = $buildParameters.MSBuildSDKsPath
                PushToRegistry = $using:PushToRegistry
            }
            $arguments
            . "$using:ScriptPath\Build-Container.ps1" @arguments
        }
    }
}

# Get the build definitions
$buildDefinitions = Get-Content .\build-definitions.json | ConvertFrom-Json

# Get script path
$scriptPath = $PSScriptRoot

# Run
buildContainers -ScriptPath $scriptPath -BuildDefinitions $buildDefinitions -ThrottleLimit $ThrottleLimit -PushToRegistry $PushToRegistry -ErrorVariable +errors

# Build output
docker images lflanagan/msbuild | Select-Object -skip 1 | Sort-Object

# Error handling
if ($errors.Count -ne 0) {
    Write-Output "Errors found."
    Write-Output $errors

    # Set the exit code to be greater than 0 so the build is marked as failed in AppVeyor
    if ($env:APPVEYOR -eq $true) { $host.SetShouldExit(1) }
}