# AutoUpdateProjectVersionPS

## About

I was unable to find an extension in VS 2022 that would automatically set the version of my projects as I wanted them and supported the new SDK style projects, so I created this simple script to fill that gap. I thought I would share it so others can modify it to fit their needs.

## Prerequisites

This script should work with either PS 5.1 or PS 7+, its only tested with PS 7+.

## Setup automatic versioning in VS

First copy the ps1 file to the root of the project folder you want to have auto versioned. *Make sure its in the project folder and not the solution folder.*

In Visual Studio go to your projects property page.
Find the `Pre-build event` section under `Build` and paste one of the below lines depending what version of PS you are using.

### Powershell Core (PS 7+)

```
pwsh -File "$(ProjectDir)UpdateAppVersion.ps1"
```

### Powershell 5.1

```
powershell -File "$(ProjectDir)UpdateAppVersion.ps1"
```

Now when you build your project in VS, your project version will be automatically set to something like `2022.07.28.123` and the build number will auto increment.

## Using to manually update the project version

First copy the ps1 file to the root of the project folder you want to have auto versioned. *Make sure its in the project folder and not the solution folder.*

When you want to update the project version you can right click the ps1 file and select `Run with Powershell`
