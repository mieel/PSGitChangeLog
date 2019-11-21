PSGitChangeLog
Powershell Module to convert a Git log to a readable format (md or html)

How to use
If you want a Markdown document
Get-GitHistory -OutputAs md

If you want a html document
Get-GitHistory -OutputAs html

If you want a json/psobject object, so that you can apply your own formatting
Get-GitHistory -OutputAs json
Get-GitHistory -OutputAs psobject

Only output latest x version
Get-GitHistory -OutputAs md -Latest Major (Outputs all minor/builds of the current Major release)
Get-GitHistory -OutputAs md -Latest Minor (Outputs all builds of the currenct Minor release)
Get-GitHistory -OutputAs md -Latest Build (Outputs the latest build release)
