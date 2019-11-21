@{
    # Baseuri to view your commit details
    CommitBaseUri = "https://github.com/mieel/PSGitChangeLog/commit"
    # Baseuri to view the Issue details linked to a commit
    IssueLinkUri = "https://github.com/mieel/PSGitChangeLog/issues"
    # Baseuri to view the download page of the package
    PackageUri = "https://www.powershellgallery.com/packages/PSGitChangeLog"

    #Define Commit Intent Codes here
    #if a Intent Code is used anywhere in the Commit message, that commit is classed under the intent you describe in the Desciption
    #you can specify the order of Intents in the changelog
    Intents = @(
        @{
            Code            = '🐛', '🚑', 'bf:', 'bug:', 'prob:'
            Description     = 'Bugs, Problems'
            DefaultAudience = 'Public'
            Order           = 2
        }, @{
            Code            = '👌', '📦', '✨', 'new:', 'impr:'
            Description     = 'New features, Improvements'
            DefaultAudience = 'Public'
            Order           = 1
        }, @{
            Code            = '👷‍♂️', '⚙', '✅', 'ci:', 'cfg:', 'adm:', '💚'
            Description     = 'Configuration, Testing'
            DefaultAudience = 'internal'
            Order           = 4
        }, @{
            Code            = '📝'
            Description     = 'Documentation'
            DefaultAudience = 'internal'
            Order           = 3
        }, @{
            Code            = '✏', '♻', '🎨', 'rf:', 'opt:'
            Description     = 'Code Optimization, Refactoring'
            DefaultAudience = 'Public'
            Order           = 5
        }, @{
            Code            = 'Other'
            Description     = 'Other'
            DefaultAudience = 'Public'
            Order           = 6
        }
    )
    Omit = @(
        'RE:'
        'Update azure-pipelines.yml for Azure Pipelines'
    )
}

