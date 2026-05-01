source /usr/share/cachyos-fish-config/cachyos-config.fish



# ============================================================
# 🛠️ Master's Mode Switch (nvim / kate / code)
# ============================================================
set -gx MASTER_EDITOR kate   # ここを 'kate' や 'code' に変えるだけで一気に切り替わります
# ============================================================

# モードに応じたエディタ実行コマンドの定義
switch $MASTER_EDITOR
    case nvim
        alias e='nvim'
    case kate
        alias e='kate'
    case code
        alias e='code' # 標準の code コマンドを使用
end







# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
alias win11='quickemu --vm ~/windows-11/windows-11-Japanese.conf'

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
echo "  web     : テキストブラウザ (w3m) を起動"
echo "  google  : Google検索をブラウザで開く"
echo "  memo,aimemo     : 管理テキストを開く"
echo "  gui       : 現在ディレクトリをGUIで開く"
echo "  win11    : win11起動"
echo "  ai-ask,ai-file : ask ai会話 file ファイル参照会話  "
echo "  nnow    : 通信量表示リアルタイム"
echo "  nstat    : 1日の通信積算"
echo "  maintain: GitHubへバックアップ & システム更新"
echo "----------------------------------"


# 'reload' と打つだけで設定を最新にする
alias reload='source ~/.config/fish/config.fish'

# 管理用メモを一瞬で開く
alias memo='e ~/dotfiles/README.md'
# AIに読み込ませるための環境・設定サマリー
alias aimemo='e ~/dotfiles/AI_CONTEXT.md'
alias aimemo2='e ~/dotfiles/GEMINI_PROTOCOL.md'

alias confst='e ~/dotfiles/scripts/startup-sequence.sh'

# メンテナンスして再起動
alias m-reboot='maintain; reboot'
# config.fish への追加案
alias f-reboot='maintain; systemctl hibernate'

# zoxide の初期化
zoxide init fish | source

# マスター専用の「zz」エイリアス (インタラクティブ検索)
alias zz='zi'


# テキストブラウザ w3m のエイリアス
alias web='w3m'

# 検索コマンドの定義
# -n 5 : 検索結果を5件だけ出す（スッキリさせるため）
# -c jp : 日本のGoogleを使用
alias google='ddgr -n 5 --reg jp-jp'
# 番号を選んだ時に Chrome で開くための環境変数
# CachyOSのデフォルト名に合わせて指定
set -x BROWSER google-chrome-stable




# 再起動のエイリアス（安全確認付き）
function rb
    echo (set_color red)"Master, are you sure you want to REBOOT? (y/n)"(set_color normal)
    read -l confirm
    if test "$confirm" = "y"
        maintain
        # ハイバネートを試みて、失敗したら普通に再起動するか選ぶ
        if not sudo systemctl hibernate
            echo (set_color yellow)"⚠️ ハイバネートに失敗しました（スワップ不足）。"(set_color normal)
            echo "通常の再起動を実行しますか？ (y/n)"
            read -l r_confirm
            if test "$r_confirm" = "y"
                sudo reboot
            end
        end
    end
end

# Gemini CLI や Ollama (Gemma) に現在のコンテキストを流し込む
# 使い方: ask-ai "この環境で〇〇を自動化するスクリプトを書いて"
# 1. 背景知識（三位一体）のみで相談する
function ask-ai
    # 3つの基本コンテキストを連結
    set -l full_prompt (cat ~/dotfiles/AI_CONTEXT.md ~/dotfiles/README.md ~/dotfiles/GEMINI_PROTOCOL.md; echo -e "\n--- QUESTION ---\n$argv")
    
    echo $full_prompt | gemini-js
end 

# 使い方: ask-file [ターゲットファイル] "質問内容"
function ask-file
    if test (count $argv) -lt 2
        echo "使用法: ask-file [ファイル名] \"質問内容\""
        return
    end

    set -l target $argv[1]
    set -l question $argv[2]

    # 4つのコンテキストを結合して AI に流し込む
    # 1. AI_CONTEXT      : マスターの属性・基本理念
    # 2. README.md       : 現在の兵装・操作マニュアル
    # 3. GEMINI_PROTOCOL : ブラウザ版の invisible な制約・設定（作成予定）
    # 4. $target         : 解析対象のファイル
    if test -f $target
        cat ~/dotfiles/AI_CONTEXT.md \
            ~/dotfiles/README.md \
            ~/dotfiles/GEMINI_PROTOCOL.md \
            $target | gemini-js "$question"
    else
        echo "エラー: $target が見つかりません。"
    end
end




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
alias v='e'
# 'vf' で config.fish を即座に編集
alias vf='e ~/dotfiles/.config/fish/config.fish'


# 'conf' と打つだけで、設定ファイル（実体）を Neovim で開く
alias conf='e ~/dotfiles/.config/fish/config.fish'

# ついでに Neovim の設定も一瞬で開けるように
alias nconf='e ~/dotfiles/.config/nvim/init.lua'



# Wikipedia 検索関数
function wiki
    if test -z "$argv"
        echo "キーワードを入力してください (例: wiki 屋久島)"
        return
    end

    # Wikipedia API でサマリーを取得
    set -l summary (curl -s "https://ja.wikipedia.org/api/rest_v1/page/summary/$argv")
    
    # 内容があるかチェックして表示
    set -l extract (echo $summary | jq -r '.extract // "見つかりませんでした"')
    
    set_color yellow
    echo "--- Wikipedia Summary: $argv ---"
    set_color normal
    echo $extract
    echo ""
    
    set_color cyan
    echo "詳細を Chrome で開きますか？ (y/n)"
    set_color normal
    
    read -l confirm
    if test "$confirm" = "y"
        google-chrome-stable "https://ja.wikipedia.org/wiki/$argv" > /dev/null 2>&1 &
        disown
    end
end



# オリジナルヘルプを表示する関数
function fortress
    # bat が入っているので、色付きで綺麗に表示
    # --style=plain で余計な枠を消してスッキリ流せます
    bat --style=plain --paging=never ~/dotfiles/HELP.md
end

# 短いエイリアスも作っておくと便利です
alias h='fortress'


# --- ネットワーク監視兵装 ---

# リアルタイム速度監視 (nload)
alias nnow='nload'

# 1日の積算量を確認 (vnstat)
function nstat
    set_color yellow
    echo "--- 📊 本日の通信積算量 ---"
    set_color normal
    vnstat -d | grep (date '+%Y-%m-%d') # 今日の日付の行だけ抽出
end

# --- パケット解析兵装 ---

# GUI版 Wireshark をバックグラウンドで起動
alias wire='wireshark > /dev/null 2>&1 &; disown'

# CLI版 (tshark) でリアルタイムにパケットを流し見する
# -i any : 全てのインターフェースを監視
alias twire='tshark -i any'


function dot-link
    if test (count $argv) -lt 1
        echo "使用法: dot-link [ファイル名 または パス]"
        return
    end

    # 1. 相対パスを絶対パス（フルパス）に変換
    set -l target_path (realpath $argv[1])

    # 2. $HOME（家）のパスを取得
    set -l home_dir $HOME

    # 3. $HOME 以下のパスを抽出
    set -l rel_path (string replace $home_dir '' $target_path)

    # チェック：もし $HOME 以外のファイルを指定された場合の防衛
    if test "$target_path" = "$rel_path"
        set_color red
        echo "❌ エラー: $HOME 以下のファイルのみ対象です。"
        set_color normal
        return
    end

    # 4. dotfiles 側の目的地を計算
    set -l dot_dest "$home_dir/dotfiles$rel_path"
    set -l dot_dir (dirname $dot_dest)

    # 5. 移動先のディレクトリを作成
    mkdir -p $dot_dir

    # 6. 実体を移動してリンクを張る
    mv $target_path $dot_dest
    ln -s $dot_dest $target_path

    set_color green
    echo "✅ 実体を移動: $dot_dest"
    echo "✅ リンク作成: $target_path"
    set_color normal
end
