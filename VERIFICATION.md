# 動作検証記録

実施日：2026-09-21。対象：新規プロジェクト「畑島さんの指ハートチャレンジ」。
Ring SurvivorsのM00〜M13とは別の制作であり、そのファイル・進捗・セーブ・手動プレイログは変更していません。

## ローカル確認

- Godot 4.5.1で素材インポート、起動、GDScriptの実行、Web Release書き出しに成功。
- `tests/game_test.gd`：12,058チェック、失敗0。10,000回の抽選で同一ポーズ連続なし、指ハート間隔3〜7回、全7種出現を確認。
- 全手ポーズの得点判定、連打防止、演出中の停止、実際の0.8秒タイマーによる復帰、Enter/Space/クリック/タッチ、キーリピートの無視、RESETのスコア・演出初期化を確認。
- Web書き出しをHTTP配信し、Edge（Chromium）で下表の実操作を自動検証。JavaScript実行エラー・コンソールエラー0。
- スクリーンショットで日本語、女性、指の重ね位置、得点、操作説明、画面内への収まりを確認。

| 条件 | 表示サイズ | 操作・得点・連打・復帰・リセット |
|---|---|---|
| PC | 1280 × 720 | 合格：Enter / Space / 左クリック |
| スマートフォン相当 | 390 × 844 | 合格：タッチ |
| 小型スマートフォン相当 | 360 × 640 | 合格：タッチ |
| スマートフォン横画面相当 | 844 × 390 | 合格：タッチ |

## 公開先の最終確認

- 公開URL： https://badgio0906.github.io/finger-heart-challenge/
- [初回Pages公開処理](https://github.com/Badgio0906/finger-heart-challenge/actions/runs/35613247848)が成功。
- 公開URLに対して上記4画面のブラウザー検証を再実行し、すべて合格。Enter / Space / クリック / タッチで実際に得点できることを確認。
- 通常URL（QAなし）もHTTP 200、日本語タイトル一致、ゲーム描画とEnter操作、実行エラー0を確認。
- ローカル証拠： `tests/artifacts/browser-results.json`、各画面のPNG、`tests/artifacts/public-normal.png`。

## 再現方法

```powershell
godot --headless --path . --script tests/game_test.gd
godot --headless --path . --export-release Web web/index.html
node tools/serve.mjs
# 別ターミナル。PlaywrightとMicrosoft Edgeが必要。
node tests/browser_test.cjs
# 公開先を検証する場合
node tests/browser_test.cjs https://badgio0906.github.io/finger-heart-challenge/
```

Playwrightを別パスに置く場合は `PLAYWRIGHT_MODULE` にそのモジュールパスを指定できます。
テストの画面とJSON結果は `tests/artifacts/` に保存します（Git管理対象外）。
`?qa=1` はゲーム状態の読取専用観測を有効化します。自動検証でゲーム状態やポーズをブラウザーから書き換える機能はありません。

## 検証の限界

- タッチはChromiumのモバイル相当環境。iPhone Safari・Android実機での操作・性能は未確認です。
- WebGL 2対応ブラウザーが必要です。低性能端末やバックグラウンドタブでは切替の実時間が延びる場合があります。
- 音は仕様上任意のため追加していません。
