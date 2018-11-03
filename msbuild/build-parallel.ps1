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
        buildContainer -ScriptPath $ScriptPath -Variant $variant
    }
}

# Get list of variants
$variants = Get-ChildItem | Where-Object {$_.PSIsContainer} | Foreach-Object {$_.Name}

# Get script path
$scriptPath = $PSScriptRoot

# Run!
buildContainers -ScriptPath $scriptPath -Variants $variants -ErrorVariable errors
if (($env:APPVEYOR -eq $true) -and ($errors.Count -ne 0)) {
    $host.SetShouldExit($LastExitCode)
}