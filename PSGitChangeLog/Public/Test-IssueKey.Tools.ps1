Function Test-IssueKey {
    <#
        .SYNOPSIS
            Parses a string to detect (JIRA) issue keys and returns the key
        .EXAMPLE
            Test-IssueLinkKey('safdsf BISS-123 asdfasdf')
            Test-IssueLinkKey('safdsf BISS123 asdfasdf')
    #>
    Param (
        $String
    )
    $regex = '((?<!([A-Za-z]{1,10})-?)[A-Z]+-\d+)'
    If ($string -match $regex) {
        Return $matches.GetEnumerator() | Select-Object -ExpandProperty Value -Unique
    }
}