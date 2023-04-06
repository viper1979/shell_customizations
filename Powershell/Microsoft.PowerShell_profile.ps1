using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Install Terminal Icons
if (!(Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery
}
# Add icons to `ls` and `dir` file lists
Import-Module -Name Terminal-Icons

# Install PsReadLine AutoComplete
if (!(Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module PSReadLine -Force # -AllowPrerelease
}

# Add auto complete (requires PSReadline 2.2.0-beta1+ prerelease)
# Don't have it? Install using this command:
# Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck # -AllowPrerelease
Set-PSReadLineOption -PredictionSource History
# Use 'F2' to switch between InlineView and ListView
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -EditMode Windows

Set-PSReadLineKeyHandler -Chord "Shift+RightArrow" -Function ForwardWord

# F1 for help on the command line - naturally
# Stolen from: https://gist.github.com/shanselman/19dd54a09418df682d9ca945dec3b2e6#file-microsoft-powershell_profile-ps1-L536
Set-PSReadLineKeyHandler -Key F1 `
                         -BriefDescription CommandHelp `
                         -LongDescription "Open the help window for the current command" `
                         -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $commandAst = $ast.FindAll( {
        $node = $args[0]
        $node -is [CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
        }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null)
    {
        $commandName = $commandAst.GetCommandName()
        if ($commandName -ne $null)
        {
            $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
            if ($command -is [AliasInfo])
            {
                $commandName = $command.ResolvedCommandName
            }

            if ($commandName -ne $null)
            {
                Get-Help $commandName -ShowWindow
            }
        }
    }
}

### COMMAND COMPLETIONS

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

## Install DockerCommands AutoComplete
if (!(Get-Module -ListAvailable -Name DockerCompletion)) {
    Install-Module DockerCompletion -Scope AllUsers
}
Import-Module DockerCompletion

# Azure CmdLets
# if (!(Get-Module -ListAvailable -Name Az)) {
#     Install-Module Az -Scope AllUsers
# }
# Import-Module Az

# 'choco install kubernetes-cli' or 'choco upgrade kubernetes-cli'
### kubectl completion powershell | Out-String | Invoke-Expression
# 'choco install kubernetes-helm' or 'choco upgrade kubernetes-helm'
### helm completion powershell | Out-String | Invoke-Expression

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin
{
    # https://stackoverflow.com/a/63163528/97017
    Start-Process -Verb runAs cmd.exe '/c start wt.exe'

    # if ($args.Count -gt 0)
    # {   
    #    $argList = "& '" + $args + "'"
    #    Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argList
    # }
    # else
    # {
    #    Start-Process "$psHome\pwsh.exe" -Verb runAs
    # }
}
Set-Alias -Name sudo -Value admin

function getPublicIp {
    (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
}
Set-Alias -Name publicip -Value getPublicIp

# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/amro.omp.json" | Invoke-Expression
oh-my-posh init pwsh --config "C:\Users\Viper\Documents\PowerShell\viper_custom_shell.omp.json" | Invoke-Expression

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}