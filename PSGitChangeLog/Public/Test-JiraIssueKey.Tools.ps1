Function Test-JiraIssueKey {
    <#
        .SYNOPSIS
            Parses a string to detect JIRA issue keys and returns the key
        .EXAMPLE
            Test-JiraIssueKey('safdsf BISS-123 asdfasdf')
            Test-JiraIssueKey('safdsf BISS123 asdfasdf')
    #>
    Param (
        $String
    )

    If ($string -match '((?<!([A-Za-z]{1,10})-?)[A-Z]+-\d+)') {
        Return $matches.GetEnumerator() | Select-Object -ExpandProperty Value -Unique
    }
}