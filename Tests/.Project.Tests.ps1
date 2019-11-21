
$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Write-Host "Testing Project $moduleName "
Describe "PSScriptAnalyzer rule-sets" -Tag Build {
    $IgnoreRules = @(
        'PSAvoidUsingWriteHost'
        'PSAvoidUsingPositionalParameters'
        'PSAvoidUsingConvertToSecureStringWithPlainText'
        'PSAvoidTrailingWhitespace'
        'PSUseShouldProcessForStateChangingFunctions'
    )
    $Rules = Get-ScriptAnalyzerRule | Where-Object { $_.RuleName -notin $IgnoreRules }
    $scriptfiles = Get-ChildItem -Path $projectRoot -File -recurse -Include '*.ps1' | Where-Object { ($_.Directory).Name -ne 'TestSets' }
    foreach ( $Script in $scriptfiles ) {
        Context "Script '$($script.FullName)'" {
            $results = Invoke-ScriptAnalyzer -Path $script.FullName -includeRule $Rules
            if ($results) {
                foreach ($rule in $results) {
                    It $rule.RuleName {
                        $message = "{0} Line {1}: {2}" -f $rule.Severity, $rule.Line, $rule.message
                        $message | Should -Be ""
                    }
                }
            } else {
                It "Should not fail any rules" {
                    $results | Should BeNullOrEmpty
                }
            }
        }
    }
}


