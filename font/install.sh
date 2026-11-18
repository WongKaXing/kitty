#!/usr/bin/env bash
#
# 安装 kitty 配置所需字体
#
# 用法：
#   ./install.sh              安装到用户字体目录（macOS: ~/Library/Fonts）
#   ./install.sh --force      覆盖已存在但内容不同的字体
#   ./install.sh --dry-run    只显示会做什么，不写入
#   ./install.sh --dest DIR   安装到指定目录
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=0
DRY_RUN=0
DEST=""

usage() {
  cat <<'EOF'
用法: ./install.sh [选项]

选项:
  -f, --force       已存在且内容不同的字体也覆盖（默认跳过）
  -n, --dry-run     试运行，不写入任何文件
  -d, --dest DIR    安装到指定目录（默认 macOS: ~/Library/Fonts，
                    Linux: ~/.local/share/fonts）
  -h, --help        显示本帮助
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force)   FORCE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -d|--dest)    DEST="${2:-}"; [ -n "$DEST" ] || { echo "错误: --dest 需要一个目录参数" >&2; exit 1; }; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            echo "错误: 未知参数 $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

# --- 目标目录 ---------------------------------------------------------------
if [ -z "$DEST" ]; then
  case "$(uname -s)" in
    Darwin) DEST="$HOME/Library/Fonts" ;;
    Linux)  DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts" ;;
    *)
      echo "错误: 不支持的系统 $(uname -s)，请用 --dest 指定目标目录" >&2
      exit 1
      ;;
  esac
fi

# --- 收集字体文件 -----------------------------------------------------------
shopt -s nullglob
FONTS=("$SCRIPT_DIR"/*.ttf "$SCRIPT_DIR"/*.otf)
shopt -u nullglob

if [ ${#FONTS[@]} -eq 0 ]; then
  echo "错误: $SCRIPT_DIR 下没有找到 .ttf / .otf 字体文件" >&2
  exit 1
fi

echo "字体来源: $SCRIPT_DIR"
echo "安装目标: $DEST"
echo "字体数量: ${#FONTS[@]}"
[ "$DRY_RUN" -eq 1 ] && echo "== 试运行模式，不会写入任何文件 =="
echo

[ "$DRY_RUN" -eq 1 ] || mkdir -p "$DEST"

installed=0
updated=0
skipped=0

for src in "${FONTS[@]}"; do
  name="$(basename "$src")"
  dst="$DEST/$name"

  if [ -f "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      echo "  跳过   $name（已存在且内容一致）"
      skipped=$((skipped + 1))
      continue
    fi
    if [ "$FORCE" -ne 1 ]; then
      echo "  跳过   $name（已存在但内容不同，加 --force 覆盖）"
      skipped=$((skipped + 1))
      continue
    fi
    action="覆盖"
    updated=$((updated + 1))
  else
    action="安装"
    installed=$((installed + 1))
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  $action   $name -> $dst"
  else
    cp "$src" "$dst"
    echo "  $action   $name"
  fi
done

echo
echo "完成: 新安装 $installed，覆盖 $updated，跳过 $skipped"

# --- 刷新字体缓存 -----------------------------------------------------------
if [ "$DRY_RUN" -ne 1 ]; then
  case "$(uname -s)" in
    Darwin)
      echo "macOS: ~/Library/Fonts 会被自动索引，无需手动刷新。"
      echo "如果 kitty 没生效，先完全退出 kitty（Cmd+Q）再重新打开。"
      ;;
    Linux)
      if command -v fc-cache >/dev/null 2>&1; then
        echo "刷新字体缓存（fc-cache）..."
        fc-cache -f "$DEST" >/dev/null 2>&1 || true
      else
        echo "提示: 未找到 fc-cache，请手动执行 fc-cache -f"
      fi
      echo "验证: fc-list | grep -i -e VictorMono -e LXGW"
      ;;
  esac
fi

if [ "$DRY_RUN" -ne 1 ]; then
  echo
  echo "验证字体是否可被 kitty 识别:"
  echo "  kitty +list-fonts --show-system | grep -i -e 'Victor Mono' -e 'LXGW'"
fi
