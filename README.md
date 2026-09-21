# 畑島さんの指ハートチャレンジ

笑顔の畑島さんの手を、指ハートのタイミングで止めるブラウザゲームです。成功で +1 点、失敗しても減点なし。何度でも挑戦できます。

## 遊ぶ

https://Badgio0906.github.io/finger-heart-challenge/

- PC：Enter / Space / 左クリック
- スマートフォン：画面のどこでもタップ
- RESET：スコアと演出をリセット
- 判定の表示は0.8秒。その後、自動的に次のラウンドへ進みます。
- スコアは現在のプレイ中のみ保持します。ページを再読み込みすると0になります。

## 開発環境と実行

Godot 4.5.1 / GDScript / Compatibilityレンダラー / Webのシングルスレッド書き出し。
Godotで `project.godot` を開いてF6またはF5で実行してください。

```powershell
godot --headless --path . --editor --import
godot --headless --path . --script tests/game_test.gd
godot --headless --path . --export-release Web web/index.html
node tools/serve.mjs
```

HTTP確認先： http://localhost:8765/ （ファイルの直接起動は不可）。
書き出し後の `web/` 一式をコミットし、mainへのpushでGitHub ActionsがPagesへ公開します。

## 構成

- `scenes/Main.tscn`：ゲームの入口
- `scripts/main.gd`：UI、手の抽選、入力、判定、スコア、演出
- `assets/woman/woman_body.svg`：固定の女性本体
- `assets/hands/`：共通座標で差し替える7種の手
- `assets/ui/`：指ハートのお手本とアイコン
- `assets/fonts/`：Noto Sans JPとSIL Open Font License
- `tools/create-art.mjs`：オリジナルSVG素材の再生成
- `tests/game_test.gd`：抽選、入力、得点、連打、復帰、リセットの自動検証
- `export_presets.cfg`：Web書き出し設定
- `.github/workflows/deploy-pages.yml`：公開処理
- `web/`：書き出し済みゲーム

## 調整

`scripts/main.gd` 冒頭の `HAND_CHANGE_INTERVAL`（0.65秒）と `RESULT_DURATION`（0.8秒）で調整できます。
同じポーズは連続しません。指ハートの間隔は3〜7回の切替に1回です。成功・失敗後も同じ抽選ルールを継続します。
描画を止めているタブや低フレームレート時は実時間が伸びる場合があります。

## 素材

女性・手・アイコンはこのゲームのために作成したオリジナルSVGです。特定の実在人物の似顔絵ではありません。
フォントは [Noto Sans JP](https://github.com/notofonts/noto-cjk/tree/main/Sans/SubsetOTF/JP)（SIL OFL 1.1）を同梱しています。
外部画像、アクセス解析、広告、サウンド、サーバーへのスコア送信はありません。

ゲームエンジン： [Godot Engine — MIT License](https://godotengine.org/license/)。

Web出力設定は[Godot 4.5の公式ガイド](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html)に基づき、GitHub Pagesで動作するシングルスレッド構成を採用しています。
