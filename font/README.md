---
tags:
  - Computer
  - terminal tool
type: config
date: 2026-11-12
---

# kitty 字体

`kitty-font.conf` 里用到的字体，随仓库一起分发，clone 下来即可安装，不必再单独去下载。

---

## 字体清单

| 文件 | 配置中的字体名 | 配置项 |
|------|----------|--------|
| `VictorMonoNerdFontMono-Light.ttf` | VictorMono Nerd Font Mono Light | `font_family` |
| `VictorMonoNerdFontMono-SemiBold.ttf` | VictorMono Nerd Font Mono SemiBold | `bold_font` |
| `VictorMonoNerdFontMono-LightItalic.ttf` | VictorMono Nerd Font Mono Light Italic | `italic_font` |
| `VictorMonoNerdFontMono-SemiBoldItalic.ttf` | VictorMono Nerd Font Mono SemiBold Italic | `bold_italic_font` |
| `LXGWWenKai-Regular.ttf` | LXGW WenKai Regular（霞鹜文楷） | `symbol_map`（中文 U+4E00–U+9FCB） |

对应的 `kitty-font.conf` 片段：

```conf
font_size                                    20
font_family                                  VictorMono Nerd Font Mono Light
bold_font                                    VictorMono Nerd Font Mono SemiBold
italic_font                                  VictorMono Nerd Font Mono Light Italic
bold_italic_font                             VictorMono Nerd Font Mono SemiBold Italic
symbol_map                                   U+4E00-U+9fA5,U+9FA6-U+9FCB       LXGW WenKai Regular
```

> [!note] 为什么用「Nerd Font Mono」版本
> 等宽版把图标字符宽度对齐到单字符格，kitty 里状态栏、`eza --icons`、`starship` 提示符才不会错位。

---

## 安装

```bash
git clone https://github.com/WongKaXing/kitty.git
cd kitty/font
./install.sh
```

脚本会：

1. 把 `font/` 下的 `.ttf` 复制到 `~/Library/Fonts`（macOS）或 `~/.local/share/fonts`（Linux）
2. 内容相同的字体自动跳过，内容不同的默认跳过，避免覆盖你手动装过的版本
3. Linux 下顺带执行 `fc-cache -f`

常用选项：

```bash
./install.sh --dry-run     # 只显示会做什么，不写入
./install.sh --force       # 覆盖已存在但内容不同的字体
./install.sh --dest DIR    # 装到指定目录
```

> [!tip] 装完 kitty 还是旧字体？
> macOS 上先完全退出 kitty（Cmd+Q，不是关窗口）再重开。仍然不对就执行 `atsutil databases -removeUser` 清掉用户字体缓存。

---

## 验证

```bash
# macOS / Linux 通用，列出 kitty 能识别的字体
kitty +list-fonts | grep -i -e 'Victor Mono' -e 'LXGW'

# Linux
fc-list | grep -i -e VictorMono -e LXGW
```

---

## 备选字体（未包含）

`kitty-font.conf` 里几行被注释掉的可选配置，对应的字体没有放进仓库，需要时自行安装：

| 字体 | 配置项 | 获取方式 |
|------|--------|----------|
| Fira Code Regular / Medium | `font_family` / `bold_font` | `brew install --cask font-fira-code` |
| VictorMono Nerd Font Mono Thin / Bold Italic | `italic_font` / `bold_italic_font` | `brew install --cask font-victor-mono-nerd-font` |
| JetBrainsMono Nerd Font Mono Thin / Bold Italic | `italic_font` / `bold_italic_font` | `brew install --cask font-jetbrains-mono-nerd-font` |

> [!warning] 仓库体积
> `LXGWWenKai-Regular.ttf` 单个 24 MB，加上 Victor Mono 四个字重总计约 34 MB。克隆会比较慢，属预期。

---

## 许可证

- Victor Mono — SIL Open Font License 1.1
- LXGW WenKai 霞鹜文楷 — SIL Open Font License 1.1（派生自 Klee One）

两种字体均允许随项目一起分发。
