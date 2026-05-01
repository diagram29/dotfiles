#!/bin/bash
# --- Master's Startup Sequence ---

# 1. ブラウザを起動
google-chrome-stable &

# 2. VS Code を起動
code &

# 3. その他、常駐させたいものがあれば追記
# (例: dolphin --daemon &)

echo "Startup sequence completed."
