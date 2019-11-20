# Settings
$ModuleName = 'PSSMit'
$ModulePath = '\\localhost\Nissan.Components\'
$ModuleVersion = ''

$global:ServerParams = @{
    ServerInstance = '#SqlServerInstance#'
    Database       = '#DatabaseName#'
}

$InputFolder = "\\localhost\Nissan.FileRepository\Leads\in\FTP"
$TargetFolder = "\\localhost\Nissan.FileRepository\Leads\in"
$errorFolder = "\\localhost\Nissan.FileRepository\Leads\in\error"


$log = "\\localhost\Nissan.FileRepository\Leads\Logs\$(($MyInvocation.MyCommand).Name)_$(Get-Date -format FileDateTime).log"

# Start Log and Commands
Start-Transcript -Path $log

Import-Module "$ModulePath$ModuleName" -force

Write-Host "$ModuleName $((Get-Module $ModuleName).Version) Loaded..."

Get-SmitDataSourceFiles -SourcePath $InputFolder -DataFileType 7 | New-SmitDataFile -TargetFolder $TargetFolder

Stop-Transcript

