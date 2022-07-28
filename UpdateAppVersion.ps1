#####################################################################
# Setup for Visual Studio auto increment on build
# 1.) Place this script in the root of your project you want to be auto versioned
# 2.) Go to your projects property page in VS
# 3.) Find Build -> Events -> Pre-build event
# 4.) Paste one of the below commands depending on what version of Powershell you have
# For PS core: pwsh -File "$(ProjectDir)UpdateAppVersion.ps1"
# For PS 5.1: powershell -File "$(ProjectDir)UpdateAppVersion.ps1"
#####################################################################

# Read the current version tag in the csproj file and update to todays date and increment the build number
[System.IO.DirectoryInfo]$scriptPath = $PSScriptRoot

# Get the csproj file
$csproj = $scriptPath.GetFiles("*.csproj") | Select-Object -First 1

# Read the file contents
$content = Get-Content -Path $csproj.FullName -Raw

# Make sure its an SDK project type
if(!($content -match '<Project Sdk="Microsoft.NET.Sdk\.{0,1}.*?">')){
    "Project file '$($csproj.Name)' is not recongized as an SDK type."
    return
}

# Get the current project version and build
if($content -match '<Version>(\d{4})\.(\d{2})\.(\d{2})\.(\d+)</Version>'){
    [int]$build = $Matches.4
    $year = Get-Date -Format "yyyy"
    $month = Get-Date -Format "MM"
    $day = Get-Date -Format "dd"

    "Incrementing version <Version>$year.$month.$day.$($build + 1)</Version>"
    $content = $content -replace '<Version>.+</Version>', "<Version>$year.$month.$day.$($build + 1)</Version>"
    Set-Content -Path $csproj.FullName -Value $content -Force

    return
}

# There is a version tag but its not in a format we know how to read
if($content -match '<Version>.+</Version>'){
    [int]$build = 1
    $year = Get-Date -Format "yyyy"
    $month = Get-Date -Format "MM"
    $day = Get-Date -Format "dd"

    "Formatting version tag<Version>$year.$month.$day.$build</Version>"
    $content = $content -replace '<Version>.+</Version>', "<Version>$year.$month.$day.$build</Version>"
    Set-Content -Path $csproj.FullName -Value $content -Force

    return
}

# There is no version tag, we need to add it
[int]$build = 1
$year = Get-Date -Format "yyyy"
$month = Get-Date -Format "MM"
$day = Get-Date -Format "dd"

"Adding version tag <Version>$year.$month.$day.$build</Version>"
$split = $content -split '</PropertyGroup>'
$split[0] += "    <Version>$year.$month.$day.$build</Version>`n"
$content = $split -join '    </PropertyGroup>'
Set-Content -Path $csproj.FullName -Value $content -Force