# Dictionary

binding macOS Dictionary.app to cli tools

## Usage

```ruby
require "Dictionary"
> DictionaryServices.getActiveDictionaries
=> [
 #<DictionaryServices::DCSDictionary:0x00007fbe98af5600>,
 #<DictionaryServices::DCSDictionary:0x00007fbe98af55d8>,
 #<DictionaryServices::DCSDictionary:0x00007fbe98af55b0>,
 #<DictionaryServices::DCSDictionary:0x00007fbe98af5588>,
 #<DictionaryServices::DCSDictionary:0x00007fbe98af5560>,
 #<DictionaryServices::DCSDictionary:0x00007fbe98af5538>
]
> DictionaryServices.getActiveDictionaries.map(&:short_name)
=> ["English", "English Thesaurus", "Simplified Chinese - English", "Japanese - English", "Japanese", "Simplified Chinese"]
> DictionaryServices.getActiveDictionaries.select{|d| d.short_name == "Japanese - English"}[0].text_definition 'hello'
=> "hel･lo | həlóʊ, hel- | 間投詞 (!｟英｠ hallo, ｟主に英｠ hulloともつづる) 1 やあ, こんにちは(｟くだけて｠ hi) (!昼夜の別なく用いる一般的なあいさつ) ▸ Hello, Paul. How's it going?やあ, ポール. 調子はどう ▸ Hello there, Mike. やあ, マイク(→ there間投詞) ▸ Hello again, I'm Donna with “Music Paradise.” こんにちは, 「ミュージックパラダイス」のドナです (!ラジオ･テレビ司会者からの番組冒頭のあいさつ) . 2 もしもし (!電話の応対) ▸ Hello, this is Jennifer speaking. May I speak to Mark, please? 〘電話〙 もしもし, ジェニファーですが. マークさんをお願いします. 3 おーい, ちょっとー, ねえ, あのー, もしもし (!注意を引くために呼びかけて) ▸ Hello, is anyone home? すみません, どなたかおられますか. 4 正気か, ホント, えっ (!不注意な言動に対する反応) ▸ Hello? なんだって. 5 ｟英｠ おや, あら, まあ (!驚き･当惑を表す) . 名詞複～s | -z | Chelloというあいさつ, ちょっとしたあいさつ ▸ Say hello to your father (for me).お父さんによろしくね (!この表現では無冠詞) . 動詞自動詞他動詞(…に)helloとあいさつする."
```

## References

https://nshipster.com/dictionary-services/
http://michaelchinen.com/2013/08/25/mac-dictionary-services/
http://tobioka.net/716
https://qiita.com/doraTeX/items/9b290f4e39f1e100558b