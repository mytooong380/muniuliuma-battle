@echo off
chcp 65001 >nul
title 木牛流马大战 - 一键环境配置启动器
cd /d "%~dp0"
setlocal EnableDelayedExpansion

set "GAME=tank_battle.py"
set "PYZIP=https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip"
set "GETPIP=https://bootstrap.pypa.io/get-pip.py"
set "PYEXE="
set "PYARG="

echo ================================================
echo     木牛流马大战 - 一键配置启动器
echo ================================================
echo.
echo [1/3] 检测 Python 运行环境...

rem ---- 优先复用本机已装的 Python（执行验证，防商店假别名） ----
python -c "import sys" >nul 2>nul && set "PYEXE=python"
if not defined PYEXE py -3 -c "import sys" >nul 2>nul && set "PYEXE=py" && set "PYARG=-3"
if not defined PYEXE python3 -c "import sys" >nul 2>nul && set "PYEXE=python3"

if defined PYEXE (
    echo       已找到本机 Python，直接复用。
) else if exist "runtime\python.exe" (
    set "PYEXE=runtime\python.exe"
    echo       复用先前下载的便携运行环境 runtime\。
) else (
    echo       未检测到 Python，开始下载便携版运行环境（约 11MB，免管理员）...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='silentContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest '%PYZIP%' -OutFile 'python_embed.zip'; Invoke-WebRequest '%GETPIP%' -OutFile 'get-pip.py'"
    if not exist "python_embed.zip" goto :err_net
    powershell -NoProfile -Command "Expand-Archive -Path 'python_embed.zip' -DestinationPath 'runtime' -Force"
    del python_embed.zip >nul 2>nul
    if not exist "runtime\python.exe" goto :err_net
    echo import site>> "runtime\python311._pth"
    runtime\python.exe get-pip.py --no-warranty -q
    del get-pip.py >nul 2>nul
    set "PYEXE=runtime\python.exe"
    echo       便携环境就绪。
)
echo       使用解释器: !PYEXE! !PYARG!
echo.

echo [2/3] 检查游戏依赖 pygame（首次自动安装，请稍候）...
set "RETRY=0"

:install_dep
"%PYEXE%" !PYARG! -m pip install -q --disable-pip-version-check pygame-ce 2>nul
"%PYEXE%" !PYARG! -c "import pygame" >nul 2>nul
if not errorlevel 1 goto :dep_ok
"%PYEXE%" !PYARG! -m pip install -q --disable-pip-version-check pygame 2>nul
"%PYEXE%" !PYARG! -c "import pygame" >nul 2>nul
if not errorlevel 1 goto :dep_ok
if %RETRY%==0 (
    set /a RETRY+=1
    echo       官方源较慢，改用国内镜像重试...
    "%PYEXE%" !PYARG! -m pip install -q --disable-pip-version-check -i https://pypi.tuna.tsinghua.edu.cn/simple pygame
    goto :install_dep
)
goto :err_pyg

:dep_ok
echo       依赖就绪。
echo.

echo [3/3] 启动 木牛流马大战 ！
echo.
"%PYEXE%" !PYARG! "%GAME%"
echo.
echo 游戏已退出，感谢游玩！按任意键关闭窗口...
pause >nul
exit /b 0

:err_net
echo.
echo [出错] 网络下载失败：请联网后重试，或手动安装 Python 3.8+
echo        （https://www.python.org/downloads/）后再运行本文件。
pause
exit /b 1

:err_pyg
echo.
echo [出错] pygame 安装失败：请检查网络或防火墙后重试本文件。
pause
exit /b 1
