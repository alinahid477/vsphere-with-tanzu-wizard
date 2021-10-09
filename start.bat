@ECHO OFF

echo "Unix convert start,..." 

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './converter.ps1'"

echo "Unix convert end,..."

set name=%1
set doforcebuild=%2

if "%name%" == "forcebuild" (
    set name=
    set doforcebuild="forcebuild"    
)

if "%name%" == "" (
    echo "assuming default name: k8stunnel"
    set name="k8stunnel"
)


set isexists=
FOR /F "delims=" %%i IN ('docker images  ^| findstr /i "%name"') DO set "isexists=%%i"
echo "docker image name %isexists% already exists. Will avoide build if not exists"

set dobuild=
if "%isexists%" == "" (set dobuild=y)
set param2=%2
if NOT "%param2%"=="%param2:forcebuild=%" (set dobuild=y)
if "%dobuild%" == "y" (docker build . -t %1)

set currdir=%cd%
docker run -it --rm -v %currdir%:/root/ --add-host kubernetes:127.0.0.1 --name %1 %1
PAUSE
