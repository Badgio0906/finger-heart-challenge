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

## F09：イラスト全面改訂（2026-09-21）

- 女性本体・指ハート・キツネ・ピース・OK・サムズアップ・手のひら・人差し指の8枚を内蔵image_genで新規制作。透過PNGとプロンプトを保存。
- 旧SVGの女性と手、お手本、旧素材の再生成スクリプトを削除。スコア欄のお手本も新しい指ハートに統一。
- 固定の女性本体、差し替える手、固定の袖口の3レイヤーで組み込み、手首の位置・袖の重なりを通常描画で確認。
- ローカルHTTP版をPC・スマートフォン相当の4画面で再検証し、すべて合格。7ポーズの実際のゲーム画面も個別に取得。
- 証拠： `tests/artifacts/art-v2-pose-0.png`〜`art-v2-pose-6.png`、各端末スクリーンショット、`browser-results.json`。

## F10：腕と手先の左右不一致修正（2026-09-22）

- 原因：元素材に左右の手が混在しており、指ハート・サムズアップが反転対象から漏れていた。
- `RIGHT_HAND_SOURCES` に右手素材4種類をまとめ、固定の左腕に合わせる。反転時の手首位置補正も共通適用。お手本も同じ定義を参照。
- 7ポーズを実際のゲーム入力で停止させ、親指の位置・手首の接続を一覧で目視確認：[確認画面](docs/handedness-review.png)。
- Web Release書き出し成功。ローカルHTTP版のPC 1280×720、スマートフォン相当390×844 / 360×640 / 844×390の入力・得点・復帰・リセットはすべて合格。

## F11：OKサインの左右修正（2026-09-22）

- F10ではOK素材の左右を誤判定しており、反転漏れが残っていた。F10の全ポーズの向き確認は不十分だったため、この記録で訂正する。
- `HandType.OK` を反転対象へ追加し、既存の手首位置補正も適用。
- Web Release書き出し成功。PC 1280×720とスマートフォン相当390×844でOKポーズを実入力で停止し、得点が増えないこと、演出後に再開すること、実行エラー0を確認。
- 両画面で反転後のOKサインと袖口の接続を目視確認：[修正画面](docs/ok-handedness-fixed.png)。ローカル証拠は `tests/artifacts/ok-fixed-desktop.png`、`ok-fixed-mobile.png`。

## F12：パーの左右修正（2026-09-22）

- F10で手のひら素材も左右を誤判定していた。`HandType.OPEN` を反転対象へ追加し、既存の手首位置補正を適用。
- Web Release書き出し成功。PC 1280×720・スマートフォン相当390×844でパーを実入力で停止し、加点なし・演出後の再開・実行エラー0を確認。
- 親指が顔側になる向きと袖口への接続を両画面で目視確認：[修正画面](docs/open-handedness-fixed.png)。ローカル証拠：`tests/artifacts/open-fixed-desktop.png`、`open-fixed-mobile.png`。

## F13：5段階チャレンジと結果画面（2026-09-22）

- 最新ユーザー指示により、従来の失敗後の自動再開を廃止。5回成功ごとに進み、25回成功でClear・1回の押し間違いでFailureになる。仕様は `docs/CHALLENGE_RULES.md`。
- 同じ女性のClear / Failure専用イラストを内蔵image_genで制作し、指定メッセージと再挑戦ボタンを実装。素材と最終プロンプトは `docs/RESULT_ART.md`。
- Godotのロジック検証：12,171チェック、失敗0。5・10・15・20回目の速度変更、25回目のクリア、全不正解ポーズでの終了、結果保持、再挑戦、入力・連打防止・RESETを確認。
- Web Releaseを書き出し、PC 1280×720とスマートフォン相当390×844の実際のキー・タップでそれぞれ25回成功までプレイ。各段階の速度、Clear / Failureの表示と文言、結果保持、再挑戦、RESETが合格。コンソール・実行エラー0。
- Clear画面を360×640・844×390へ変更して表示を確認。イラスト・指定文言・再挑戦ボタンが画面内に収まることを目視確認。
- 証拠：[Clear画面](docs/clear-screen.png)、[Failure画面](docs/failure-screen.png)、`tests/artifacts/browser-results.json`、`clear-*.png`、`failure-*.png`。
- Web出力から検証資料の画像を除外し、ゲーム内で使用する素材のみを収録。

## 検証の限界

- タッチはChromiumのモバイル相当環境。iPhone Safari・Android実機での操作・性能は未確認です。
- WebGL 2対応ブラウザーが必要です。低性能端末やバックグラウンドタブでは切替の実時間が延びる場合があります。
- 音は仕様上任意のため追加していません。
