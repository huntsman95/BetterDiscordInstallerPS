function Install-BetterDiscord {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Force
    )

    #Define constants
    $BDBASEDIR = "$($env:APPDATA)\BetterDiscord"
    $BDASARPATH = "$BDBASEDIR\data\betterdiscord.asar"
    $APPDIR = Get-ChildItem $env:LOCALAPPDATA\Discord\ -Filter 'app-*' -Directory | Sort-Object -Property Name -Descending | Select-Object -First 1

    #Exit if application directory not found
    if (-not $APPDIR) {
        Throw "Discord application directory not found. Please make sure Discord is installed."
    }

    #Check if BetterDiscord is installed
    if (-not $Force.IsPresent) {
        if (Select-String -Path "$($APPDIR.FullName)\modules\discord_desktop_core-1\discord_desktop_core\index.js" -Pattern 'betterdiscord.asar' -Quiet) {
            throw "BetterDiscord is already installed. Exiting."
        }
    }

    #Create BetterDiscord Folders if they don't exist
    if (-not (Test-Path $BDBASEDIR)) {
        Push-Location $env:APPDATA
        New-Item -ItemType Directory -Path .\BetterDiscord
        New-Item -ItemType Directory -Path .\BetterDiscord\data
        New-Item -ItemType Directory -Path .\BetterDiscord\plugins
        New-Item -ItemType Directory -Path .\BetterDiscord\themes
        New-Item -ItemType Directory -Path .\BetterDiscord\Dictionaries
        Pop-Location
    }

    #Stop Discord
    if (Get-Process -Name Discord -ErrorAction SilentlyContinue) {
        Stop-Process -Name Discord
    }

    #Download BetterDiscord ASAR Archive
    $GITHUBLATEST = Invoke-RestMethod 'https://api.github.com/repos/BetterDiscord/BetterDiscord/releases/latest'
    $DLURL = $GITHUBLATEST.assets[0].browser_download_url
    Invoke-WebRequest -Uri $DLURL -OutFile $BDASARPATH

    #Inject ASAR into Discord index.js
    $INDEXJSCONTENT = @"
require("$($BDASARPATH.Replace('\', '\\'))");
module.exports = require("./core.asar");
"@
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllText("$($APPDIR.FullName)\modules\discord_desktop_core-1\discord_desktop_core\index.js", $INDEXJSCONTENT, $Utf8NoBomEncoding)

    #Restart Discord
    Start-Process -FilePath "$env:LOCALAPPDATA\Discord\Update.exe" -ArgumentList '--processStart Discord.exe --updatechannel stable --updatetype install'
}