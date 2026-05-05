#!/usr/bin/env bash
set -e

echo "=== WindsurfAPI Setup ==="

# Create directories
echo "[1/4] Creating directories..."
mkdir -p /opt/windsurf/data/db
mkdir -p /tmp/windsurf-workspace

# Check LS binary
LS_PATH="/opt/windsurf/language_server_linux_x64"
if [ -f "$LS_PATH" ]; then
  chmod +x "$LS_PATH"
  echo "[2/4] Language Server found at $LS_PATH"
else
  echo "[2/4] WARNING: Language Server not found at $LS_PATH"
  echo "       Download it and place it there before starting the server"
  echo "       chmod +x $LS_PATH"
fi

# Generate .env if not exists
if [ ! -f .env ]; then
  echo "[3/4] Generating .env..."
  echo ""
  echo "--- 请配置以下参数（直接回车使用默认值）---"
  echo ""

  read -p "API_KEY (调用接口的密钥，留空则开放访问): " INPUT_API_KEY
  INPUT_API_KEY="${INPUT_API_KEY:-}"

  read -p "DASHBOARD_PASSWORD (管理面板密码，留空则开放): " INPUT_DASHBOARD_PWD
  INPUT_DASHBOARD_PWD="${INPUT_DASHBOARD_PWD:-}"

  read -p "CASCADE_POLL_INTERVAL_MS (轮询间隔ms，默认150): " INPUT_POLL_MS
  INPUT_POLL_MS="${INPUT_POLL_MS:-150}"

  read -p "DEFAULT_MODEL (默认模型，默认gpt-4o-mini): " INPUT_MODEL
  INPUT_MODEL="${INPUT_MODEL:-gpt-4o-mini}"

  cat > .env << ENVEOF
PORT=3003
API_KEY=${INPUT_API_KEY}
DATA_DIR=
DEFAULT_MODEL=${INPUT_MODEL}
MAX_TOKENS=8192
LOG_LEVEL=info
LS_BINARY_PATH=/opt/windsurf/language_server_linux_x64
LS_PORT=42100
DASHBOARD_PASSWORD=${INPUT_DASHBOARD_PWD}
CASCADE_POLL_INTERVAL_MS=${INPUT_POLL_MS}
ENVEOF
  echo ""
  echo "       .env 已生成，配置如下："
  echo "       API_KEY=${INPUT_API_KEY:-（未设置，开放访问）}"
  echo "       DASHBOARD_PASSWORD=${INPUT_DASHBOARD_PWD:-（未设置）}"
  echo "       CASCADE_POLL_INTERVAL_MS=${INPUT_POLL_MS}"
  echo "       DEFAULT_MODEL=${INPUT_MODEL}"
else
  echo "[3/4] .env already exists, skipping"
fi

# Check Node.js version
NODE_VER=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [ -z "$NODE_VER" ]; then
  echo "[4/4] WARNING: Node.js not found. Install Node.js >= 20"
elif [ "$NODE_VER" -lt 20 ]; then
  echo "[4/4] WARNING: Node.js v$NODE_VER detected, need >= 20"
else
  echo "[4/4] Node.js v$(node -v) OK"
fi

echo ""
echo "=== Done ==="
echo "Start:     node src/index.js"
echo "Dev:       node --watch src/index.js"
echo "Dashboard: http://localhost:3003/dashboard"
