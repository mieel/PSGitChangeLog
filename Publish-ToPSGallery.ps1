Param (
    $nuGetApiKey = $env:PSGallery_PAT
)
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$releaseNotes = $env:RELEASE_NOTES
$moduleVersion = $env:Gitversion_SemVerId
Write-Host "ModuleVersion: $moduleVersion"

$manifestPath = Resolve-Path -Path "*\*.psd1"
Write-Host "Manifest Path: $manifestPath"


Update-ModuleManifest -ReleaseNotes $releaseNotes -Path $manifestPath.Path -ModuleVersion $moduleVersion #-Verbose

$moduleFilePath = Resolve-Path -Path "*\*.psm1"
Write-Host "Module File Path: $moduleFilePath"

$modulePath = Split-Path -Parent $moduleFilePath
Write-Host "Module Path: $modulePath"

$module = $modulePath | Split-Path -leaf

try {
    Publish-Module -Path $modulePath -NuGetApiKey $nuGetApiKey -ErrorAction Stop -Force
    Write-Host "Module: $module Version: $moduleVersion has been Published to the PowerShell Gallery!"
} catch {
    throw $_
}