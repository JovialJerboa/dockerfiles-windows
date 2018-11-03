function buildContainer {
    param (
        [string]$ScriptPath
        ,[string]$Variant
        ,[bool]$PushToRepository = $false
    )
    Write-Information "Building $Variant"
    $variantPath = "$ScriptPath/$Variant"

    # Build docker image
    docker build -t "lflanagan/msbuild:$Variant" -f "$variantPath/Dockerfile" "$variantPath"

    # Push image(s) to docker hub
    if ($true -eq $PushToRepository){
        docker push "lflanagan/msbuild:$Variant"
    }
}

workflow buildContainers {
    param (
        [string]$ScriptPath
        ,[string[]]$Variants
    )
    foreach -parallel ($variant in $Variants) {
        buildContainer -ScriptPath $ScriptPath -Variant $variant -ErrorVariable buildContainerError
        if ($null -ne $buildContainerError) {
            Write-Error $buildContainerError
        }
    }
}

# Get list of variants
$variants = Get-ChildItem | Where-Object {$_.PSIsContainer} | Foreach-Object {$_.Name}

# Get script path
$scriptPath = $PSScriptRoot

# Test some things in AppVeyor
Write-Host "Test ----------------------------------"
if ($env:APPVEYOR -eq $true) {
    Write-Host "$env:APPVEYOR is true!"
}
else {
    Write-Host "$env:APPVEYOR is not true!"
}
Get-ChildItem C:\ProgramData\Docker
Write-Host "Test ----------------------------------"

# Run!
buildContainers -ScriptPath $scriptPath -Variants $variants -ErrorVariable errors
if (($env:APPVEYOR -eq $true) -and ($errors.Count -ne 0)) {
    $host.SetShouldExit($LastExitCode)
}