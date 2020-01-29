Function Get-ConventialCommit {
    <#
        .SYNOPSIS

        .EXAMPLE
            Get-ConventialCommit -CommitMessage 'feat(webapi): Add new feature'
            Get-ConventialCommit -CommitMessage 'feat: Add new feature no mention of scope'
            Get-ConventialCommit -CommitMessage '👷‍♂️ CI Change'
            Get-ConventialCommit -CommitMessage '👷‍♂️(Deployment) CI Change in Azure Devops'
            Get-ConventialCommit -CommitMessage 'plain text commit message'
    #>
    Param (
        [string]
        $CommitMessage = 'feat(webapi): Add new feature'
        ,
        [string]
        $ConfigFile
    )
    If (!$ConfigFile) { $ConfigFile = "$PSScriptRoot\..\PSGitChangeLog.Config.psd1" }
    $config = Import-PowerShellDataFile -Path $ConfigFile
    $Intents = $config.Intents

    $MatchedIntents = $Intents.Code |
    ForEach-Object {
        $CurrentCode = $_
        If ( $CommitMessage -match ("{0}" -f $CurrentCode )) {
            $Match = $matches[0]
            $Matchedcode = $CurrentCode
            Write-Information $Matchedcode
            # Scope is mentioned after the code with no semicolon ':'
            If ( $CommitMessage -match ("{0}\(\w*\)" -f $Matchedcode )) {
                $Match = $matches[0]
                $Matchedcode = $CurrentCode

                If ($Match -match "\(\w*\)") {
                    $MatchedScope = Get-ConventialCommitScope $matches[0]
                }
                Write-Information "$Matchedcode mentions Scope $MatchedScope"
            }
        } Else {
            # Scope is mentioned between brackets () before a semecolon ':'
            $CodeBase = $CurrentCode -replace ':', ''
            If ( $CommitMessage -match ("{0}\(\w*\):" -f $CodeBase )) {
                $Match = $matches[0]
                $Matchedcode = $CurrentCode

                If ($Match -match "\(\w*\):") {
                    $MatchedScope = Get-ConventialCommitScope $matches[0]
                }
                Write-Information "$Matchedcode with codebase $codebase mentions Scope $MatchedScope"
            }
        }
        If ($Matchedcode) {

            Write-Output @{
                Match = $Match
                Code  = $Matchedcode
                Scope = $MatchedScope
            }
        }
    }
    If ($MatchedIntents) {
        $Intent = ($MatchedIntents | Select-Object -first 1)

        # Filter out the Intentcode and scope out of the message
        IF ($Intent.Code -like '*:') {
            $CommitMessage = $CommitMessage.Replace("$($Intent.Match) ", '')

        } Else {
            # Keep intent code with no semicolon (emoji's), filter out the (Scope)
            $CommitMessage = $CommitMessage.Replace("`($($Intent.Scope)`)", '')
        }
    } Else {
        $Intent = @{Code = 'Other' }
    }
    $IntentConfiguration = $Intents | Where-Object { $_.Code -contains $Intent.Code }
    $output = [PSCustomObject]@{
        Message           = $CommitMessage
        IntentCode        = $Intent.Code
        IntentDescription = $IntentConfiguration.Description
        IntentAudience    = $IntentConfiguration.Audience
        Order             = $IntentConfiguration.Order
        Scope             = $Intent.Scope
        Match             = $Intent.Match
    }
    Write-Output $output
}
Function Get-ConventialCommitScope {
    Param (
        $Match
    )
    $Scope = $Match -replace '\(', ''
    $Scope = $Scope -replace '\)', ''
    $Scope = $Scope -replace ':', ''
    Write-Output $Scope
}

Function Get-ConventialCommitScope2 {
    <#
        .EXAMPLE
            Get-ConventialCommitScope2 -$CommitMessage 'feat: new feature' -ScopeIsSuffixedWithSemicolon -Code 'feat:'
            Get-ConventialCommitScope2 -$CommitMessage 'feat(scope): new feature' -ScopeIsSuffixedWithSemicolon -Code 'feat:'
    #>
    Param (
        $CommitMessage = 'feat: new feature'
        ,
        [switch]
        $ScopeIsSuffixedWithSemicolon
        ,
        $Code
    )
    If ($ScopeIsSuffixedWithSemicolon) {
        $SC = ':'
        $CodeBase = $Code -replace ':', ''
    } Else {
        $CodeBase = $Code
    }

    If ( $CommitMessage -match ("{0}\(\w*\)$SC" -f $CodeBase )) {
        $Match = $matches[0]
        $Matchedcode = $Code

        If ($Match -match "\(\w*\)$SC") {
            $MatchedScope = Get-ConventialCommitScope $matches[0]
        }
        Write-Information "$Matchedcode with codebase $codebase mentions Scope $MatchedScope"
    }
    $Code
    $CodeBase
    $MatchedScope
}