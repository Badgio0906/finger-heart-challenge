# 畑島さんの指ハートチャレンジ

笑顔の畑島さんの手を、指ハートのタイミングで止めるブラウザゲームです。5回成功するごとに速くなり、全5段階・合計25回成功で完全クリア。1回の押し間違いで失敗となります。

## 遊ぶ

https://Badgio0906.github.io/finger-heart-challenge/

- PC：Enter / Space / 左クリック
- スマートフォン：画面のどこでもタップ
- RESET：成功数・速度・演出を最初に戻す
- 通常の成功表示は0.8秒。その後、自動的に再開します。5回ごとに次の段階へ進みます。
- Clear：両手を上げて喜ぶ畑島さんと「これであなたも指ハートマスター」。
- Failure：両手で顔を覆う畑島さんと「指ハートマスターへの道は遠い」。
- 結果画面は「もう一度チャレンジ」で第1段階から再挑戦できます。
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
- `assets/art_v2/body.png`：新しく制作した固定の女性本体
- `assets/art_v2/`：共通座標で差し替える7種の手。指ハートのお手本も同じ素材を使用
- `assets/ui/`：アイコン
- `assets/fonts/`：Noto Sans JPとSIL Open Font License
- `docs/ART_DIRECTION.md`：イラストの制作方法と最終生成プロンプト
- `tests/game_test.gd`：抽選、入力、得点、連打、復帰、リセットの自動検証
- `export_presets.cfg`：Web書き出し設定
- `.github/workflows/deploy-pages.yml`：公開処理
- `web/`：書き出し済みゲーム

## 調整

`scripts/main.gd` 冒頭の `STAGE_INTERVALS`（0.65 / 0.55 / 0.45 / 0.35 / 0.25秒）、`SUCCESSES_PER_STAGE`（5回）、`RESULT_DURATION`（0.8秒）で調整できます。
速度は未指定のため上記を初期調整値としています。同じポーズは連続しません。指ハートの間隔は3〜7回の切替に1回です。
描画を止めているタブや低フレームレート時は実時間が伸びる場合があります。

## 素材

女性と7種の手は、このゲームのために内蔵image_genで新たに制作した透過PNGです（2026-09-21全面改訂）。特定の実在人物の似顔絵ではありません。
女性本体と袖は固定し、手の部分だけを差し替えます。アイコンはオリジナルSVGです。
結果用の女性イラスト2枚も内蔵image_genで制作しました。保存先と最終プロンプトは `docs/RESULT_ART.md` に記録しています。
フォントは [Noto Sans JP](https://github.com/notofonts/noto-cjk/tree/main/Sans/SubsetOTF/JP)（SIL OFL 1.1）を同梱しています。
外部画像、アクセス解析、広告、サウンド、サーバーへのスコア送信はありません。

ゲームエンジン： [Godot Engine — MIT License](https://godotengine.org/license/)。

Web出力設定は[Godot 4.5の公式ガイド](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html)に基づき、GitHub Pagesで動作するシングルスレッド構成を採用しています。
