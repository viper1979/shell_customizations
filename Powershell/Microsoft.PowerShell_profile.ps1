# Install Terminal Icons
if (!(Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery
}
# Add icons to `ls` and `dir` file lists
Import-Module -Name Terminal-Icons

# Install PsReadLine AutoComplete
if (!(Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module PSReadLine -AllowPrerelease -Force
}

# Add auto complete (requires PSReadline 2.2.0-beta1+ prerelease)
# Don't have it? Install using this command:
# Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Set-PSReadLineOption -PredictionSource History
# Use 'F2' to switch between InlineView and ListView
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -EditMode Windows

Set-PSReadLineKeyHandler -Chord "Shift+RightArrow" -Function ForwardWord

### COMMAND COMPLETIONS

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# Install DockerCommands AutoComplete
if (!(Get-Module -ListAvailable -Name DockerCompletion)) {
    Install-Module DockerCompletion -Scope AllUsers
}
Import-Module DockerCompletion

# 'choco install kubernetes-cli' or 'choco upgrade kubernetes-cli'
kubectl completion powershell | Out-String | Invoke-Expression
# 'choco install kubernetes-helm' or 'choco upgrade kubernetes-helm'
helm completion powershell | Out-String | Invoke-Expression

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin
{
    if ($args.Count -gt 0)
    {   
       $argList = "& '" + $args + "'"
       Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argList
    }
    else
    {
       Start-Process "$psHome\pwsh.exe" -Verb runAs
    }
}

Set-Alias -Name sudo -Value admin

# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/amro.omp.json" | Invoke-Expression
oh-my-posh init pwsh --config "C:\Users\Viper\Documents\PowerShell\viper_custom_shell.omp.json" | Invoke-Expression