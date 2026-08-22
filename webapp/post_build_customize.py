"""pygbag 构建后定制 HTML 外壳：模板每次重打包都会覆盖 index.html，钩子必须可重跑。

替换全部用字面量锚点：模板升级导致锚点漂移时仅告警跳过，绝不中断构建。
"""
import logging
from pathlib import Path

WEB = Path(__file__).parent / "build" / "web"
URL = "https://mytooong380.github.io/muniuliuma-battle/"

PATCHES = [
    ('<html lang="en-us">', '<html lang="zh-CN">', "语言标记"),
    ("<title>webapp</title>", "<title>木牛流马大战 · 三国坦克大战（在线版）</title>", "页面标题"),
    ('body.style.background = "#7f7f7f"', 'body.style.background = "#12160f"', "加载底色"),
    ("background: green;", "background: #1a2013; border: 2px solid #d6bb62; border-radius: 10px; font-size: 18px;", "提示框底色"),
    ("color: blue;", "color: #e8cc70;", "提示框文字色"),
    ("padding: 12px 24px;", "padding: 20px 32px;", "提示框内边距"),
    ('msg  = "Ready to start ! Please click/touch page"',
     'msg  = "点击画面开始游戏（浏览器需先确认音频权限）"', "开始提示中文化"),
    ("font-family: arial;", 'font-family: "PingFang SC","Microsoft YaHei",system-ui,sans-serif;', "字体栈"),
    ("background-color:powderblue;",
     "background-color:#12160f;overflow:hidden;touch-action:none;", "页面底色+移动端溢出保护"),
]

META_BLOCK = (
    '    <meta name="description" content="木牛流马大战 —— 三国主题坦克大战：'
    '普通模式/无尽模式/军械商城/传送门/草坪隐身，浏览器直接玩。">\n'
    '    <meta name="theme-color" content="#12160f">\n'
    '    <meta property="og:title" content="木牛流马大战 · 三国坦克大战">\n'
    '    <meta property="og:description" content="普通模式 / 无尽模式 / 军械商城 / '
    '传送门 / 草坪隐身 —— 打开即玩">\n'
    '    <meta property="og:type" content="website">\n'
    f'    <meta property="og:url" content="{URL}">\n'
    f'    <meta property="og:image" content="{URL}preview_menu.png">\n'
    '    <meta name="twitter:card" content="summary_large_image">'
)


def patch_html():
    """字面量替换 + meta 注入：每处失败只告警，保证构建永不因外壳定制中断"""
    p = WEB / "index.html"
    if not p.exists():
        logging.error("外壳定制失败：找不到 %s（请先运行 pygbag 构建）", p)
        return
    html = p.read_text(encoding="utf-8", errors="ignore")
    for old, new, why in PATCHES:
        if old not in html:
            logging.warning("外壳定制跳过（锚点未找到）: %s", why)
        html = html.replace(old, new)
    anchor = '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
    if 'og:title' not in html:
        html = html.replace(anchor, anchor + "\n" + META_BLOCK, 1)
    p.write_text(html, encoding="utf-8")
    logging.info("外壳定制完成: %s", p)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="[%(levelname)s] %(message)s")
    patch_html()
