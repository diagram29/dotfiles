source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
alias win11='quickemu --vm windows-11-Japanese.conf'
#set -gx GOOGLE_API_KEY ''

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
