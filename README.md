🛠️ 基本の操作サイクル
いじる: conf または nconf で設定を編集。

即反映: reload で新しい設定を読み込む。

保存: maintain で GitHub にバックアップ。

📂 ファイル操作
CUI: cd, ls, fzf (Ctrl+r / Ctrl+t) を活用。

GUI: 「ここからはマウスがいいな」と思ったら gui と打つ。

ターミナルに 「📂 Opening [現在のパス] in Dolphin...」 と表示されます。

🆘 緊急時のトラブルシューティング
画面が固まった？: Ctrl + z を押した可能性があります。fg と打って戻りましょう。

保存できない？: 既に別の場所で開いている警告です。:q! で一度閉じ、fg で元の画面に戻ります。

🛠️ 運用ステップ
インストール: sudo pacman -S w3m

設定編集: conf でエイリアスとガイドを追記。

反映: reload

保存: maintain で GitHub へ。



## 🌐 ネットワーク索敵兵装 (Updated: 2026-05-01)
- **google (ddgr)**: Google/DuckDuckGo 検索。結果を 5 件表示し、番号選択で Chrome 起動[cite: 1, 2]。
- **wiki (Custom Function)**: Wikipedia API 直結。概要を CUI で読み、必要時のみ Chrome へ移行。
- **web (w3m)**: 超軽量テキストブラウザでの直接閲覧。
