#####################################################################
# Setup for Visual Studio auto increment on build
# 1.) Place this script in the root of your project you want to be auto versioned
# 2.) Go to your projects property page in VS
# 3.) Find Build -> Events -> Pre-build event
# 4.) Paste one of the below commands depending on what version of Powershell you have
# For PS core: pwsh -File "$(ProjectDir)UpdateAppVersionNet.ps1"
# For PS 5.1: powershell -File "$(ProjectDir)UpdateAppVersionNet.ps1"
#####################################################################

# Read the current version tag in the csproj file and update to todays date and increment the build number
[System.IO.DirectoryInfo]$scriptPath = $PSScriptRoot
[System.IO.DirectoryInfo]$propertiesPath = "$PSScriptRoot\Properties"

# Get the csproj file
$csproj = $scriptPath.GetFiles("*.csproj") | Select-Object -First 1

# Read the file contents
$content = Get-Content -Path $csproj.FullName -Raw

# Make sure its not an SDK project type
if(($content -match '<Project Sdk="Microsoft.NET.Sdk\.{0,1}.*?">')){
    "Project file '$($csproj.Name)' is an SDK type. Expected old style."
    return
}

# Get assembly info file
$assemblyInfo = $propertiesPath.GetFiles("AssemblyInfo.cs") | Select-Object -First 1

# Read file contents
$content = Get-Content -Path $assemblyInfo.FullName -Raw

# Get the current project version and build
if($content -match '(?m)^\[assembly: AssemblyVersion\("(\d{4})\.(\d{2})\.(\d{2})\.(\d+)"\)\]'){
    [int]$build = $Matches.4
    $year = Get-Date -Format "yyyy"
    $month = Get-Date -Format "MM"
    $day = Get-Date -Format "dd"

    "Incrementing version [assembly: AssemblyVersion(`"$year.$month.$day.$($build + 1)`")]"
    $content = $content -replace '(?m)^\[assembly: AssemblyVersion\(.+\)\]', "[assembly: AssemblyVersion(`"$year.$month.$day.$($build + 1)`")]"
    Set-Content -Path $assemblyInfo.FullName -Value $content -NoNewline -Force

    return
}

# There is a version tag but its not in a format we know how to read
if($content -match '(?m)^\[assembly: AssemblyVersion\(.+\)\]'){
    [int]$build = 1
    $year = Get-Date -Format "yyyy"
    $month = Get-Date -Format "MM"
    $day = Get-Date -Format "dd"

    "Formatting version tag [assembly: AssemblyVersion(`"$year.$month.$day.$build`")]"
    $content = $content -replace '(?m)^\[assembly: AssemblyVersion\(.+\)\]', "[assembly: AssemblyVersion(`"$year.$month.$day.$build`")]"
    Set-Content -Path $assemblyInfo.FullName -Value $content -NoNewline -Force

    return
}

# There is no version tag
"No version tag found in assemblyinfo.cs"