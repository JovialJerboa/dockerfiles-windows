param (
    [int]$ThrottleLimit = 0
)

# Define buildContainers workflow
workflow buildContainers {
    param (
        [string]$ScriptPath
        ,[string[]]$Variants
        ,[int]$ThrottleLimit
    )
    foreach -parallel -throttle $ThrottleLimit ($variant in $Variants) {
        InlineScript {
            Write-Output "Building $Using:variant"
            $variantPath = "$Using:ScriptPath/$Using:variant"
        
            # Build docker image
            docker build -t "lflanagan/msbuild:$Using:variant" -f "$variantPath/Dockerfile" "$variantPath"
        
            # Push image(s) to docker hub
            if ($true -eq $PushToRepository) { docker push "lflanagan/msbuild:$Using:variant" }
        }
    }
}

# Get list of variants
$variants = Get-ChildItem | Where-Object {$_.PSIsContainer} | Foreach-Object {$_.Name}

# Get script path
$scriptPath = $PSScriptRoot

# Run
buildContainers -ScriptPath $scriptPath -Variants $variants -ThrottleLimit $ThrottleLimit -ErrorVariable +errors

# Error handling
if ($errors.Count -ne 0) {
    Write-Output "Errors found."
    Write-Output $errors

    # Set the exit code to be greater than 0 so the build is marked as failed in AppVeyor
    if ($env:APPVEYOR -eq $true) { $host.SetShouldExit(1) }
}