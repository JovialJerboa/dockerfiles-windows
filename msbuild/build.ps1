param (
    [bool]$PushToRepository = $false
)

# Get list of variants
$variants = Get-ChildItem | Where-Object {$_.PSIsContainer} | Foreach-Object {$_.Name}

foreach ($variant in $variants) {
    Write-Information "Building $variant"

    # Build docker image
    docker build -t "lflanagan/msbuild:$variant" -f "$variant/Dockerfile" "./$variant"

    # Push image(s) to docker hub
    if ($true -eq $PushToRepository){
        docker push "lflanagan/msbuild:$variant"
    }
}