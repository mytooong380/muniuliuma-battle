"""网页版入口：pygbag 要求 main.py + asyncio.run 标准形态（由构建脚本同步自 tank_battle.py）"""
import asyncio
import pygame                 # 显式声明依赖：pygbag 只扫描入口文件的 import，缺此行 pygame 不入包
from tank_battle import main

asyncio.run(main())
