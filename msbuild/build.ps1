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
    foreach -parallel -throttle $ThrottleLimit ($netFxVersion in $BuildDefinitions.netFxVersions) {
        parallel {
            # netfx
            sequence {
                # # Variables
                # $dockerFilePath = "$ScriptPath\netfx"
                # $tag = "netfx-$($netFxVersion.'name')"
                # $netfxTag = $netFxVersion.'tag'

                # Write-Output "Building $tag"

                # # Build docker image
                # docker build --build-arg NETFX_TAG=$netfxTag -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath

                # # Push image(s) to docker hub
                # if ($true -eq $PushToRegistry) { docker push "lflanagan/msbuild:$tag" }

                # # Clean-up
                # if ($env:APPVEYOR -eq $true) { docker rmi $(docker images -f dangling=true -q) }
            }

            # netfx-webtools
            sequence {
                # # Variables
                # $dockerFilePath = "$ScriptPath\netfx-webtools"
                # $tag = "netfx-$($netFxVersion.'name')-webtools"
                # $netfxTag = $netFxVersion.'tag'

                # Write-Output "Building $tag"

                # # Build docker image
                # docker build --build-arg NETFX_TAG=$netfxTag -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath 

                # # Push image(s) to docker hub
                # if ($true -eq $PushToRegistry) { docker push "lflanagan/msbuild:$tag" }

                # # Clean-up
                # if ($env:APPVEYOR -eq $true) { docker rmi $(docker images -f dangling=true -q) }
            }

            foreach -parallel -throttle $ThrottleLimit ($dotnetVersion in $BuildDefinitions.dotnetVersions) {
                parallel {
                    # netfx-dotnet
                    sequence {
                        # # Variables
                        # $dockerFilePath = "$ScriptPath\netfx-dotnet"
                        # $tag = "netfx-$($netFxVersion.'name')-dotnet-$($dotnetVersion.'name')"
                        # $netfxTag = $netFxVersion.'tag'
                        # $dotnetTag = $dotnetVersion.'tag'
                        # $MSBuildSDKsPath = $dotnetVersion.'MSBuildSDKsPath'

                        # Write-Output "Building $tag"

                        # # Build docker image
                        # docker build --build-arg NETFX_TAG=$netfxTag --build-arg DOTNET_TAG=$dotnetTag --build-arg MSBUILD_SDKS_PATH=$MSBuildSDKsPath -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath

                        # # Push image(s) to docker hub
                        # if ($true -eq $PushToRegistry) { docker push "lflanagan/msbuild:$tag" }

                        # # Clean-up
                        # if ($env:APPVEYOR -eq $true) { docker rmi $(docker images -f dangling=true -q) }
                    }

                    # netfx-dotnet-webtools
                    InlineScript {
                        # C:\devt\github\dockerfiles-windows\msbuild\buildContainer.ps1 -BuildRootPath "C:\devt\github\dockerfiles-windows\msbuild" -DockerFile "netfx-dotnet-webtools" -NetFxName "4.7.2" -NetFxTag "4.7.2-sdk-20181009-windowsservercore-ltsc2016" -DotNetName "2.1" -DotNetTag "2.1-sdk-nanoserver-1709" -MSBuildSDKsPath "C:\Program Files\dotnet\sdk\2.1.403\Sdks" -IncludeWebTools $true
                        & "$using:ScriptPath\buildContainer.ps1" -BuildRootPath "C:\devt\github\dockerfiles-windows\msbuild" -DockerFile "netfx-dotnet-webtools" -NetFxName "4.7.2" -NetFxTag "4.7.2-sdk-20181009-windowsservercore-ltsc2016" -DotNetName "2.1" -DotNetTag "2.1-sdk-nanoserver-1709" -MSBuildSDKsPath "C:\Program Files\dotnet\sdk\2.1.403\Sdks" -IncludeWebTools $true
                    }
                    sequence {
                        
                        # # Variables
                        # $dockerFilePath = "$ScriptPath\netfx-dotnet-webtools"
                        # $tag = "netfx-$($netFxVersion.'name')-dotnet-$($dotnetVersion.'name')-webtools"
                        # $netfxTag = $netFxVersion.'tag'
                        # $dotnetTag = $dotnetVersion.'tag'
                        # $MSBuildSDKsPath = $dotnetVersion.'MSBuildSDKsPath'

                        # Write-Output "Building $tag"

                        # # Build docker image
                        # docker build --build-arg NETFX_TAG=$netfxTag --build-arg DOTNET_TAG=$dotnetTag --build-arg MSBUILD_SDKS_PATH=$MSBuildSDKsPath -t "lflanagan/msbuild:$tag" -f $dockerFilePath $ScriptPath 

                        # # Push image(s) to docker hub
                        # if ($true -eq $PushToRegistry) { docker push "lflanagan/msbuild:$tag" }

                        # # Clean-up
                        # if ($env:APPVEYOR -eq $true) { docker rmi $(docker images -f dangling=true -q) }
                    }
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