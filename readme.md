# BetterDiscordInstallerPS
## Summary
Provides a cmdlet for installing the latest release of BetterDiscord from github utilizing only Windows Powershell.

## How to use
1. Install the module
2. Run `Install-BetterDiscord` to install BetterDiscord
3. Optionally run `Install-BetterDiscord` with the `-Force` switch to overwrite BD if already installed (could be used to update BD).

Default behavior is to not overwrite an existing install so you can run this script from Task Scheduler at regular intervals to re-install BD after Discord client updates.

## Future roadmap
- Provide a native cmdlet to automate the installation of a scheduled-task that keeps BD installed after Discord updates.