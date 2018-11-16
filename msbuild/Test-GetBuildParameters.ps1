$buildDefinitions = Get-Content .\build-definitions.json | ConvertFrom-Json

foreach($containerTag in $buildDefinitions.containerTags) {
    Write-Host "Testing $containerTag..."
    .\Get-BuildParameters.ps1 -ContainerTag $containerTag
    Write-Host ""
}