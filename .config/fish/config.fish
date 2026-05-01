source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
alias win11='quickemu --vm windows-11-Japanese.conf'
#set -gx GOOGLE_API_KEY ''

# 現在時刻を変数に格納
set current_time (date '+%Y/%m/%d %H:%M')

set_color green
# 起動時の挨拶（日本語版）
echo "--- 🛠️ お帰りなさい、マスター。環境は整っています。 ---"
echo "現在の時刻は $current_time です。"

# 起動時のメッセージ
echo "
   __  ___              __           
  /  |/  /___ _ ___ / /_ ___  ____
 / /|_/ // __ `// __// __// _ \/ __/
/_/  /_/ \__,_/ \__//_/  \___/_/     
"
echo "システムの準備が完了しました。本日は何を構築しますか？"

set_color normal
echo "--- ターミナル「要塞」へようこそ ---"

# 起動時のコマンドガイド
echo "--- 🛠️  Master's Command Guide ---"
set_color yellow
echo " [常用コマンド] "
set_color normal
echo "  conf    : Fish設定を編集"
echo "  nconf   : Neovim設定を編集"
echo "  reload  : 設定を即座に反映"
echo "  maintain: GitHubへバックアップ & システム更新"
echo "----------------------------------"


# 'reload' と打つだけで設定を最新にする
alias reload='source ~/.config/fish/config.fish'

# --- ここから関数版 gui ---
function gui
    set current_dir (pwd)
    set_color cyan
    echo "📂 Opening $current_dir in Dolphin..."
    set_color normal
    dolphin . > /dev/null 2>&1 &
    disown
end
# --- ここまで ---

# ガイドの表示部分はそのまま（あるいは関数の下に移動）
echo "  gui     : 現在のディレクトリをGUIで開く"


# 記憶を引き継ぐGeminiチャット関数

function g-chat
    set -l sys_file ~/.config/gemini_system.txt
    set -l mem_file ~/.config/gemini_memory.txt

    # ファイルチェック（前回と同様）
    if not test -e $sys_file; echo "【ロール設定】専属アシスタント" > $sys_file; end
    if not test -e $mem_file; touch $mem_file; end

    # マスターの入力を記録
    echo "マスター: $argv" >> $mem_file

    # プロンプト作成
    set -l prompt "$(cat $sys_file)\n\n【現在のシステム状態】\n$(fastfetch --format json)\n\n【会話履歴】\n$(cat $mem_file)\n\n【マスターからの指示】\n$argv"

    # --- 変更点：clearを廃止し、区切り線を入れる ---
    echo (set_color yellow)"--- Gemini is thinking... ---"(set_color normal)

    set -l response (gemini-js "$prompt")

    # 回答を表示（前後の文脈を残したまま）
    printf "\n%s\n\n" "$response"
    echo (set_color blue)"------------------------------------------"(set_color normal)

    # 応答を記録
    echo "AI: $response" >> $mem_file
    echo "------------------------" >> $mem_file
end

# 記憶を消去する（リセット用）関数
function g-clear
    rm -f ~/.config/gemini_memory.txt
    echo "記憶を完全に消去しました。"
end

# LLM起動前にRAMのPage Cacheを掃除し、ブラウザを大人しくさせる
function ollama-boost
    sync
    # ユーザー権限で可能な範囲のメモリ返却を促す
    echo "Master, clearing Page Cache for LLM..."
    sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
end

# モデル名を指定して起動する際のラップ
function q-run
    ollama-boost
    ollama run $argv
end


# エイリアスの設定（fishではaliasコマンドがそのまま使えます）
alias ls='eza --icons --group-directories-first'
alias ll='eza -al --icons --group-directories-first'
alias cat='bat --paging=never'

# fzfの設定（fishの変数定義はsetで行います）
set -x FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --exclude .git'
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

fzf_configure_bindings --directory=\ct --history=\cr



# マスター専用：環境同期・保守スクリプト
function maintain
    echo "--- 🛠️  Master's Environment Maintenance Starting... ---"

    # 1. デスクトップにシンボリックリンクがあるか確認（なければ作成）
    if not test -L ~/デスクトップ/config.fish
        ln -s ~/dotfiles/.config/fish/config.fish ~/デスクトップ/config.fish
        echo "✅ Created symbolic link to Desktop."
    end

    # 2. システムアップデート (CachyOS / pacman)
    echo "🚀 Updating system..."
    sudo pacman -Syu --noconfirm

    # 3. パッケージリストの更新保存
    echo "📋 Saving software list..."
    pacman -Qe > ~/dotfiles/pkglist.txt

    # maintain 関数内の「4. GitHubへ自動プッシュ」の前に挿入を推奨
echo "🔍 Checking fish config syntax..."
fish -n ~/.config/fish/config.fish
if test $status -eq 0
    echo "✅ Syntax OK."
else
    echo "❌ Syntax Error! Please fix before pushing."
    return 1
end


    # 4. GitHubへ自動プッシュ
    echo "📤 Syncing with GitHub..."
    cd ~/dotfiles
    git add .
    set current_time (date "+%Y-%m-%d %H:%M:%S")
    git commit -m "Auto-sync: $current_time"
    git push origin main
    cd -

    echo "--- ✨ All tasks completed, Master! ---"
end

# 上の階層へ素早く移動
alias ..='cd ..'
alias ...='cd ../..'

# ディレクトリ移動後に自動で ls (eza) を実行
function cd
    builtin cd $argv
    ls
end


# デフォルトエディタを Neovim に設定
set -gx EDITOR nvim
set -gx VISUAL nvim

# 'v' だけで nvim を起動
alias v='nvim'
# 'vf' で config.fish を即座に編集
alias vf='nvim ~/dotfiles/.config/fish/config.fish'


# 'conf' と打つだけで、設定ファイル（実体）を Neovim で開く
alias conf='nvim ~/dotfiles/.config/fish/config.fish'

# ついでに Neovim の設定も一瞬で開けるように
alias nconf='nvim ~/dotfiles/.config/nvim/init.lua'
