Param()

# self-elevate if not admin
$principal = New-Object Security.Principal.WindowsPrincipal(
  [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process -FilePath pwsh -ArgumentList (
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath
  ) -Verb RunAs
  exit
}

Set-Location -Path $PSScriptRoot
$Name = 'YetAnotherFaviconDownloader'

while ($true) {
  # build plugin
  & "$PSScriptRoot\plgx-build.ps1"

  # find KeePass.exe again
  $envs = @($Env:ProgramFiles, $Env:'ProgramFiles(x86)', $Env:ProgramW6432)
  $KeePass = $envs.Where({
      Test-Path (Join-Path $_ 'KeePass Password Safe 2\KeePass.exe')
    }).ForEach({
      Join-Path $_ 'KeePass Password Safe 2\KeePass.exe'
    })[0]

  # install plugin
  $pluginDest = Join-Path (Split-Path $KeePass) 'Plugins'
  Copy-Item -Path "$PSScriptRoot\$Name.plgx" `
    -Destination (Join-Path $pluginDest "$Name.plgx") `
    -Force

  # run KeePass and loop on exit
  & $KeePass
}
