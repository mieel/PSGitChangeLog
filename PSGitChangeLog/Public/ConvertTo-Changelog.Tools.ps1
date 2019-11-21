Function ConvertTo-ChangeLog {
    <#
        .SYNOPSIS
            Converts a GitHistory's output to a readable Changelog
            Supported formats: .MD (default), .html
        .EXAMPLE
            $json =  Get-GitHistory -asJson -Latest Major -tagprefix WebApp
            Convert-ChangeLog ($json) -FormatAs md
            Convert-ChangeLog ($json) -FormatAs html | Set-Clipboard

    #>
    Param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject = $json
        ,
        #
        [ValidateSet("md", "html")]
        [String]
        $FormatAs = 'md'
        ,
        [string]
        $TargetAudience
        ,
        [string] $PackageUrl
        ,
        [string] $ProjectName

    )
    Begin {
       
        $config = Import-PowerShellDataFile -Path  $PSScriptRoot/../PSGitChangeLog.Config.psd1
        $PackageUri = $config.PackageUri
        $CommitBaseUri = $config.CommitBaseUri
        $IssueLinkUri = $config.IssueLinkUri

        $Data = $InputObject | ConvertFrom-Json
        $Releases = $Data.Releases        
        
        $Components = $Releases.Component | Select-Object -Unique
        Write-Host "Documenting $($Releases.Release -join ', ')"
    }
    Process {

        $Content = Switch ($formatAs) {
            'md' {
                "# Changelog (Updated on $((Get-Date).ToString("yyyy-MM-dd")))"
            } 'html' {
                "<h1>Changelog (Updated on $((Get-Date).ToString("yyyy-MM-dd"))) </h1>"
            }
        }
        ForEach ($Component in $Components) {
            If ($Component -notin $null,'') {
                $content += Switch ($formatAs) {
                    'md' { Write-Output  "`n# Component: $Component" }
                    'html' { Write-Output "`n<h1>Component: $Component</h1>" }
                }
            }
            $Content += ForEach ($Release in $Releases | Where-Object { $_.Component -eq $Component }) {
                $ReleaseName = $Release.Release
                $ReleaseDate = $Release.ReleaseDate
                If ($ReleaseName -ne 'Unreleased') {
                    $VersionId = [version]$Release.Version
                    If ($Minor -ne "$($VersionId.Major).$($VersionId.Minor)") {
                        $Minor = "$($VersionId.Major).$($VersionId.Minor)"
                        Switch ($formatAs) {
                            'md' { Write-Output  "`n## Version $minor" }
                            'html' { Write-Output "`n<hr /><h2>Version $minor</h2>" }
                        }

                    }
                }
                If ($PackageUri) {
                    $DownloadUri = "$PackageUri" + "$VersionId"
                }
                $ReleaseCommits = ($Data.Releases | Where-Object { $_.Release -eq $Release.Release }).Commits
                Switch ($formatAs) {
                    'md' {
                        If ($null -eq $DownloadUri) { $DownloadLink = "[📥]($DownloadLink)" }
                        $ReleaseTitle = "`n### $ReleaseName [👨‍💻]($CommitBaseUri/$($Release.ReleaseCommit)) $DownloadLink $ReleaseDate"

                    }'html' {
                        If ($PackageUrl) { $DownloadLink += " <a href=`"$DownloadLink`">📥</a><" }
                        $ReleaseTitle = "`n <h3>$ReleaseName</h3><p><a href=`"$CommitBaseUri/$($Release.ReleaseCommit)`">👩‍💻</a>$DownloadLink -<i>$ReleaseDate</i></p>"

                    }
                }
                Write-Output $ReleaseTitle
                If ($ReleaseCommits -in $null, '') {
                    Switch ($formatAs) {
                        'md' { Write-Output  "`n#### Re-build " }
                        'html' { Write-Output "`n<h4 style=`"margin-left: 30.0px;`">Re-build 💫</h4>" }
                    }
                    Continue
                }

                $Intents = $ReleaseCommits | Select-Object -ExpandProperty Intent -unique
                ForEach ($Intent in $Intents) {

                    $messages = $ReleaseCommits | Where-Object { $_.Intent -eq $Intent -and $_.message -ne '' } |
                    Foreach-object {
                        If ($_.message -eq $currentmessage) { return }
                        $currentmessage = $_.message
                        $Log = $_
                        $CommitSHA = $_.CommitId.Substring(0, 8)
                        $CommitLink = "$CommitBaseUri/$CommitSHA"
                        $Output = Switch ($formatAs) {

                            'md' { Write-Output  "- $($Log.Message) - @[$CommitSHA]($CommitLink)" }
                            'html' { "$($Log.Message) - @<a href=`"$CommitLink`">$CommitSHA</a>" }
                        }
                        If ($Log.IssueKey -notin $null, '') {
                            $IssueKey = $Log.IssueKey
                            #Place the issue key at the end
                            $Output = $Output.Replace($IssueKey, "")
                            $Output = Switch ($formatAs) {
                                'md' { "$Output #[$IssueKey]($IssueLinkUri/$IssueKey)" }
                                'html' { "$Output #<a href=`"$IssueLinkUri/$IssueKey`">$IssueKey</a>" }
                            }
                        }
                        Write-Output "$Output`n"
                    }
                    If ($messages) {
                        Write-debug ($messages | Out-String)
                        Switch ($formatAs) {
                            'md' {
                                Write-Output  "`n#### $Intent`n"
                                Write-Output $messages
                            } 'html' {
                                Write-Output "<h4 style=`"margin-left: 30.0px;`">$Intent</h4>`n"
                                Write-Output $messages | ForEach-Object { "<p style=`"margin-left: 60.0px;`">$_</p>" }
                            }
                        }
                    }
                } # ForEach Intent
            } #ForEach Release
        } #ForEach Component
        Write-Output $Content
    } #Process
}