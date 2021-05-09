#!/usr/local/microsoft/powershell/7/pwsh
if (-not (Test-Path ./temp/)) {
    mkdir temp
}
pushd temp;
svn checkout https://repos.curseforge.com/wow/ace3/trunk ace3
popd
gci ./temp/ace3/ -Directory -Exclude "tests" | foreach {
    Remove-Item "./Libs/$($_.Name)/" -Recurse -Force
    Copy-Item $_.FullName "./Libs/$($_.Name)/" -Recurse -Force
}
Remove-Item ./temp/ -Recurse -Force

Invoke-WebRequest https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh -OutFile release.sh
chmod +x release.sh
