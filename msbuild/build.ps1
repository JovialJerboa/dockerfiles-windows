param (
    [int]$ThrottleLimit = 0
)

# Define buildContainers workflow
workflow buildContainers {
    param (
        [string]$ScriptPath
        ,[object[]]$BuildDefinitions
        ,[int]$ThrottleLimit
    )
    foreach -parallel -throttle $ThrottleLimit ($buildDefinition in $BuildDefinitions) {
        parallel {
            $configurations = $buildDefinition.configurations

            # netfx
            if ($true -eq $configurations.Contains("netfx")) {
                sequence {
                    # Variables
                    $dockerFilePath = "$ScriptPath\netfx"
                    $tag = "netfx-$($buildDefinition.'netfx-name')"
                    $netfxTag = $buildDefinition.'netfx-tag'

                    Write-Output "Building $tag"

                    # Build docker image
                    docker build --build-arg NETFX_TAG=$netfxTag -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath 

                    # Push image(s) to docker hub
                    if ($true -eq $PushToRepository) { docker push "lflanagan/msbuild:$tag" }
                }
            }

            # netfx-webtools
            if ($true -eq $configurations.Contains("netfx-webtools")) {
                sequence {
                    # Variables
                    $dockerFilePath = "$ScriptPath\netfx-webtools"
                    $tag = "netfx-$($buildDefinition.'netfx-name')-webtools"
                    $netfxTag = $buildDefinition.'netfx-tag'

                    Write-Output "Building $tag"

                    # Build docker image
                    docker build --build-arg NETFX_TAG=$netfxTag -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath 

                    # Push image(s) to docker hub
                    if ($true -eq $PushToRepository) { docker push "lflanagan/msbuild:$tag" }
                }
            }

            # netfx-dotnet
            if ($true -eq $configurations.Contains("netfx-dotnet")) {
                sequence {
                    # Variables
                    $dockerFilePath = "$ScriptPath\netfx-dotnet"
                    $tag = "netfx-$($buildDefinition.'netfx-name')-dotnet-$($buildDefinition.'dotnet-name')"
                    $netfxTag = $buildDefinition.'netfx-tag'
                    $dotnetTag = $buildDefinition.'dotnet-tag'
                    $MSBuildSDKsPath = $buildDefinition.'MSBuildSDKsPath'

                    Write-Output "Building $tag"

                    # Build docker image
                    docker build --build-arg NETFX_TAG=$netfxTag --build-arg DOTNET_TAG=$dotnetTag --build-arg MSBUILD_SDKS_PATH=$MSBuildSDKsPath -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath

                    # Push image(s) to docker hub
                    if ($true -eq $PushToRepository) { docker push "lflanagan/msbuild:$tag" }
                }
            }

            # netfx-dotnet-webtools
            if ($true -eq $configurations.Contains("netfx-dotnet-webtools")) {
                sequence {
                    # Variables
                    $dockerFilePath = "$ScriptPath\netfx-dotnet-webtools"
                    $tag = "netfx-$($buildDefinition.'netfx-name')-dotnet-$($buildDefinition.'dotnet-name')-webtools"
                    $netfxTag = $buildDefinition.'netfx-tag'
                    $dotnetTag = $buildDefinition.'dotnet-tag'
                    $MSBuildSDKsPath = $buildDefinition.'MSBuildSDKsPath'

                    Write-Output "Building $tag"

                    # Build docker image
                    docker build --build-arg NETFX_TAG=$netfxTag --build-arg DOTNET_TAG=$dotnetTag --build-arg MSBUILD_SDKS_PATH=$MSBuildSDKsPath -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath 

                    # Push image(s) to docker hub
                    if ($true -eq $PushToRepository) { docker push "lflanagan/msbuild:$tag" }
                }
            }
        }
    }
}

# Get the build definitions
$buildDefinitions = Get-Content .\build-definitions.json | ConvertFrom-Json

# Get script path
$scriptPath = $PSScriptRoot

# Run
buildContainers -ScriptPath $scriptPath -BuildDefinitions $buildDefinitions -ThrottleLimit $ThrottleLimit -ErrorVariable +errors

# Error handling
if ($errors.Count -ne 0) {
    Write-Output "Errors found."
    Write-Output $errors

    # Set the exit code to be greater than 0 so the build is marked as failed in AppVeyor
    if ($env:APPVEYOR -eq $true) { $host.SetShouldExit(1) }
}