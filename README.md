# srtをopenjtalkで読ませて、動画にマージさせるやつ

プロジェクト直下に`comments.srt`と`target.mp4`を用意し、

```console
ruby main.rb
```

を実行することで発火。

`out_srt.srt`と`result.mp4`が生成される。

`out_srt.srt`は、読み上げの長さに応じて字幕が終わるタイミングを調整したものになる。

`result.mp4`は、読み上げが載せられた動画で、ついでに`out_srt.srt`をもとにした字幕が振られる。

## 環境の準備

完全に俺が使う用でつくったので他人が使いやすい形ではないです

macなら、brewでffmpeg, sox, openjtalkを入れましょう

読み上げボイスは25行目で~/voice/唱地ヨエ.htsvoiceを指定しています。変えましょう。

ここらへんを調整できたらもう使える環境になってると思います
