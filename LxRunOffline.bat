@echo off
setlocal enabledelayedexpansion

:: 检查是否有管理员权限（LxRunOffline需要在管理员权限下执行）
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges. Attempting to restart with elevated permissions...
    :: 使用管理员权限重新启动脚本
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb runAs"
    exit /b
)

:: 设置目标目录根路径
set TARGET_BASE_DIR=E:\wsl

:: 创建临时目录
set TEMP_DIR=%TEMP%/LxRunOffline
if not exist %TEMP_DIR% (
    mkdir %TEMP_DIR%
)

:: 设置下载链接和文件名
@REM set DOWNLOAD_URL=https://github.com/DDoSolitary/LxRunOffline/releases/download/v3.5.0/LxRunOffline-v3.5.0-msvc.zip
@REM set ZIP_FILE=LxRunOffline-v3.5.0-mingw.zip
set DOWNLOAD_URL=https://github.com/Andy1208-lee/LxRunOffline/raw/refs/heads/main/LxRunOffline-v3.5.0-11-gfdab71a-msvc.zip
set ZIP_FILE=LxRunOffline-v3.5.0-11-gfdab71a-msvc
set ZIP_PATH=%TEMP_DIR%\%ZIP_FILE%.zip

:: 判断文件是否已存在，如果不存在则下载
if not exist "%ZIP_PATH%" (
    echo Downloading LxRunOffline...
    powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_PATH%'"
    :: 解压 ZIP 文件
    echo Extracting files...
    powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%TEMP_DIR%'"
) else (
    echo File already exists, skipping download.
)

:: 获取当前安装的 WSL 发行版
echo Listing available WSL distributions...
wsl -l -q

:: 提示用户输入要迁移的系统名称
set /p "selection=Please enter the name of the distribution to migrate: "

:: 设置选中的系统名称
set DISTRO_NAME=%selection%

:: 如果选择的系统为空，则退出
if "%DISTRO_NAME%"=="" (
    echo Invalid selection, exiting...
    rd /s /q %TEMP_DIR%
    exit /b
)

:: 创建安装目录
set INSTALL_DIR=%TARGET_BASE_DIR%\%DISTRO_NAME%
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

:: 迁移并安装选择的系统
echo Migrating %DISTRO_NAME% to %INSTALL_DIR%...
%TEMP_DIR%/%ZIP_FILE%/LxRunOffline.exe m -n %DISTRO_NAME% -d %INSTALL_DIR%

:: 清理临时文件
echo Cleaning up...
rd /s /q %TEMP_DIR%

echo Migration complete. Press any key to exit.
pause
