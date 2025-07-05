Param()
Set-Location -Path $PSScriptRoot

$Source = Join-Path $PSScriptRoot 'YAFD'
$Target = Join-Path $PSScriptRoot 'publish'
$Name = 'YetAnotherFaviconDownloader'
$BuildDir = Join-Path $PSScriptRoot 'build'

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

# Prepare clean build directory
if (Test-Path $BuildDir) {
  Remove-Item -Path $BuildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildDir | Out-Null

# Copy all source files into build dir (no backticks, use splatting)
$copyParams = @{
  Path        = Join-Path $Source '*'
  Destination = $BuildDir
  Recurse     = $true
  Force       = $true
}
Copy-Item @copyParams

# Ensure publish folder exists
if (-not (Test-Path $Target)) {
  New-Item -ItemType Directory -Path $Target | Out-Null
}

# Build plugin
Write-Output 'Building...'
$buildArgs = @(
  '--plgx-create-from-folder', $Source
)
& $KeePass @buildArgs
Write-Output ''

# Move the generated plgx file to target location
$generatedPlgx = Join-Path $PSScriptRoot "$Name.plgx"
$plgxFile = Join-Path $Target "$Name.plgx"
if (Test-Path $generatedPlgx) {
  Move-Item -Path $generatedPlgx -Destination $plgxFile -Force
}

# Deploy plugin (only if build succeeded)
if (Test-Path $plgxFile) {
  Write-Output 'Deploying...'
  $deployDir = Join-Path $Source 'bin\Debug'
  if (-not (Test-Path $deployDir)) {
    New-Item -ItemType Directory -Path $deployDir | Out-Null
  }
  $oldParams = @{
    Path  = Join-Path $deployDir "$Name.*"
    Force = $true
  }
  Remove-Item @oldParams -ErrorAction SilentlyContinue
  $deployFile = Join-Path $deployDir "$Name.plgx"
  Copy-Item -Path $plgxFile -Destination $deployFile -Force
} else {
  Write-Output 'Build failed - .plgx file not created'
}
Write-Output ''
