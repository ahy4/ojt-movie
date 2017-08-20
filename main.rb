require 'srt'

def get_start_time(str)
  str.split(" --> ")[0].gsub(":", "_")
end

def to_ms(timestr)
  tmp = timestr.gsub(",", "_").split("_")
  h = tmp[0].to_f
  m = tmp[1].to_f
  s = tmp[2].to_f
  ms = tmp[3].to_f
  return ms + 1000 * (s + 60 * (m + 60 * h))
end

def to_timestr(ms)
  h = ((ms / 3600000).floor + 100).to_s[1..-1].to_f
  m = (((ms - h * 3600000)/60000).floor + 100).to_s[1..-1].to_f
  s = (((ms - h * 3600000 - m * 60000)/1000).floor + 100).to_s[1..-1].to_f
  ms = ms % 1000
  fill = -> (num) { format("%02d", num.to_i) }
  return "#{fill[h]}:#{fill[m]}:#{fill[s]},#{format("%03d", ms.to_i)}"
end

ojt = "open_jtalk -x /usr/local/Cellar/open-jtalk/1.10_1/dic -m ~/voice/唱地ヨエ.htsvoice -fm 3.5 -a 0.5 -jf 0.6 -ow "

puts "=== srtの読み上げ中 ==="
out_srt = ""
commentFile = SRT::File.parse(File.new("/Users/noko/homestead/ojt-movie/comments.srt"))
`rm -rf tmp/voices/*`
commentFile.lines.each do |comment|
  `echo "#{comment.text.join(" ")}" > tmp/filename-tmp.txt`
  start_time = get_start_time(comment.time_str)
  `#{ojt} tmp/voices/#{start_time}.wav tmp/filename-tmp.txt`

  duration = `soxi -D tmp/voices/#{start_time}.wav`.to_f * 1000
  start_ms = to_ms(start_time)
  # puts start_ms
  # puts `soxi -D tmp/voices/#{start_time}.wav`
  end_time = to_timestr(duration + start_ms)
  out_srt += "#{comment.sequence}\n#{start_time.gsub("_", ":")} --> #{end_time}\n#{comment.text.join("\n")}\n\n"
end

`echo "#{out_srt}" > out_srt.srt`

puts "=== srt更新完了 ==="
puts " >> out_srt.srt"

puts "=== 無音追加処理中 ==="
`rm -rf tmp/spaced/*`
`ls tmp/voices`.split(".wav\n").each do |filename|
  time = filename.gsub("_", ":")
  ms = to_ms(filename)
  sec = (ms / 1000).to_s
  `sox -n -r 48000 -c 1 tmp/silence_tmp.wav trim 0.0 #{sec}`
  `sox tmp/silence_tmp.wav tmp/voices/#{filename}.wav tmp/spaced/#{filename}.wav`
end
`rm -rf tmp/voices/*`
puts "=== voice合成中 ==="
files = `ls tmp/spaced/`.split("\n").map { |name| "tmp/spaced/#{name}" } .join(" ")
`sox -m #{files} tmp/voice_bundled.wav gain -n`
`rm -rf tmp/spaced/*`

puts "=== 音声と動画を合成中 ==="
`ffmpeg -y -i target.mp4 -an -vcodec copy tmp/target-movie.mp4`
`ffmpeg -i target.mp4 -vn -acodec pcm_s16le -ar 48000 -ac 2 tmp/target-sound.wav`
`sox tmp/voice_bundled.wav -c 2 tmp/channel-changed-voice.wav`
`sox -m tmp/target-sound.wav tmp/channel-changed-voice.wav tmp/sound-full.wav`
`ffmpeg -y -i tmp/target-movie.mp4 -i tmp/sound-full.wav -map 0:0 -map 1:0 tmp/merged.mp4`
`ffmpeg -y -i tmp/merged.mp4 -vf subtitles=out_srt.srt result.mp4`

`rm tmp/*.wav tmp/*.mp4 tmp/*.txt`

puts "† 完了 †"

