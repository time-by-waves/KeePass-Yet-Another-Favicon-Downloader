Param()
Set-Location -Path $PSScriptRoot

$Source = Join-Path $PSScriptRoot 'YAFD'
$Target = Join-Path $PSScriptRoot 'publish'
$Name = 'YetAnotherFaviconDownloader'

# locate KeePass.exe
$progPaths = @(
  ${Env:ProgramFiles},
  ${Env:ProgramFiles(x86)},
  ${Env:ProgramW6432}
)
$KeePass = $progPaths.                                        # find first existing exe
Where({ Test-Path (Join-Path $_ 'KeePass Password Safe 2\KeePass.exe') }).
ForEach({ Join-Path $_ 'KeePass Password Safe 2\KeePass.exe' })[0]
if (-not $KeePass) { Throw 'KeePass.exe not found in ProgramFiles folders.' }

# clean old publish folder
if (Test-Path $Target) {
  Write-Output 'Cleaning...'
  Remove-Item -Path $Target -Recurse -Force
}
Write-Output ''

# copy sources, excluding bin/obj/.user
Write-Output 'Copying...'
Copy-Item -Path (Join-Path $Source '*') `
  -Destination $Target `
  -Recurse -Force `
  -Exclude 'bin', 'obj', '*.user'
Write-Output ''

# build .plgx
Write-Output 'Building...'
& $KeePass --plgx-create $Target --plgx-prereq-kp:2.34
Write-Output ''

# deploy plugin
Write-Output 'Deploying...'
Move-Item -Path 'publish.plgx' -Destination "$Name.plgx" -Force
Remove-Item -Path (Join-Path $Source "bin\Debug\$Name.*") `
  -ErrorAction SilentlyContinue
Copy-Item -Path (Join-Path $PSScriptRoot "$Name.plgx") `
  -Destination (Join-Path $Source "bin\Debug\$Name.plgx") `
  -Force
Write-Output ''
