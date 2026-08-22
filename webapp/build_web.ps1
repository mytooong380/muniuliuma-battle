# 网页版构建：同步最新游戏代码 → pygbag 编译 WASM → 产物在 webapp/build/web/
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

# 每次构建用根目录最新代码覆盖，防止两份 tank_battle.py 漂移
Copy-Item "$root\tank_battle.py" "$PSScriptRoot\tank_battle.py" -Force
New-Item -ItemType Directory -Force -Path "$PSScriptRoot\assets" | Out-Null
Copy-Item "$root\assets\*" "$PSScriptRoot\assets\" -Force

Write-Output "--- pygbag building (first run downloads WASM toolchain, be patient)..."
python -m pygbag --build $PSScriptRoot 2>&1 | Select-Object -Last 15
Write-Output "--- customizing web shell (title/meta/colors, rerun-safe)..."
python "$PSScriptRoot\post_build_customize.py"
Write-Output "--- build output:"
Get-ChildItem "$PSScriptRoot\build\web" -ErrorAction SilentlyContinue | Select-Object Name, Length
