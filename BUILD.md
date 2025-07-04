# Build & Run Guide

## Prerequisites

* Windows with Visual Studio 2019+ **or** MSBuild 16+
* .NET Framework 4.5 targeting pack (VS installs it)
* NuGet ≥ 5.8 (nuget.exe in PATH)
* KeePass 2.34+ installed (for `.plgx` creation)

> Linux / macOS users can build the DLL with `msbuild` under Mono,
> but `.plgx` packaging is Windows-only because it requires KeePass.

---

## PowerShell automation

Restore, build the plugin and run tests in one script:

```powershell
# Restore packages
nuget restore .\YetAnotherFaviconDownloader.sln

# Build plugin (Release)
$buildParams = @{
    Path      = 'YAFD/YetAnotherFaviconDownloader.csproj'
    Property  = @{ Configuration = 'Release' }
    Verbosity = 'minimal'
}
msbuild @buildParams

# Build and run Tests (Debug)
$testBuild = @{
    Path      = 'Tests/Tests.csproj'
    Property  = @{ Configuration = 'Debug' }
    Verbosity = 'minimal'
}
msbuild @testBuild

# Locate vstest and execute
$vstestExe = Join-Path $Env:ProgramFilesX86 'Microsoft Visual Studio\2019\Enterprise\Common7\IDE\Extensions\TestPlatform\vstest.console.exe'
& $vstestExe 'Tests/bin/Debug/Tests.dll'
```

---

## Cleaning generated artifacts

```powershell
msbuild /t:Clean
git clean -xfd
```

Include the output of `msbuild -version` and `KeePass.exe --version` when opening build‐related issues.

## Scripted MSBuild workflow (PowerShell)

This script works in Windows PowerShell 5.1 and PowerShell 7+

```powershell
$msbParams = @{
    Path      = 'YAFD/YetAnotherFaviconDownloader.csproj'
    Property  = @{ Configuration = 'Release' }
    Verbosity = 'minimal'
}
msbuild @msbParams
```

---

## Building and running tests

### PowerShell one-liner

```powershell
msbuild Tests/Tests.csproj /p:Configuration=Debug;
vstest.console Tests\bin\Debug\Tests.dll
```

Specify `/p:Configuration=Release` to test an optimized build.

### PowerShell workflow

Same as above, expressed with splatting and without external helpers.

```powershell
$buildParams = @{
    Path     = 'Tests/Tests.csproj'
    Property = @{ Configuration = 'Debug' }
    Verbosity= 'minimal'
}
msbuild @buildParams

$vstestExe = Join-Path $Env:ProgramFilesX86 'Microsoft Visual Studio\2019\Enterprise\Common7\IDE\Extensions\TestPlatform\vstest.console.exe'
$vstestDll = 'Tests/bin/Debug/Tests.dll'

& $vstestExe $vstestDll
```

---

## Cleaning generated artifacts

```powershell
msbuild /t:Clean
git clean -xfd
```

Include the output of `msbuild -version` and `KeePass.exe --version`
when opening build-related issues.

```bat
msbuild /t:Clean
git clean -xfd
```

Include the output of `msbuild -version` and `KeePass.exe --version`
when opening build-related issues.
