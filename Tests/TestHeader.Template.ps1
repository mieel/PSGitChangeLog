#region Formalities

#Get Module Paths

# Do this if running in an IDE
# $here = 'F:\rdcinmotiv\<ModuleName>\Tests'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$projectRoot = Resolve-Path $here\..
$ModuleManifest = Resolve-Path "$projectRoot\*\*.psd1"
$ModuleRoot = Split-Path $ModuleManifest -Parent
$moduleName = Split-Path $ModuleRoot -Leaf

# Import Module
# Module Root [ProjectRoot]\ModuleName\ should contain file ModuleName.psm1
Write-host "Loading Module $moduleName"
Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
Import-Module $ModuleRoot -force

$MockSplat = @{ModuleName = $moduleName }

Write-Verbose $MockSplat


#endregion