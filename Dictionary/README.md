# Dictionary

binding macOS Dictionary.app to cli tools

## Usage

```ruby
require "Dictionary"
> DictionaryServices.getActiveDictionaries
=> [
  #<DCSDictionary[English]>,
  #<DCSDictionary[English Thesaurus]>,
  #<DCSDictionary[Simplified Chinese - English]>,
  #<DCSDictionary[Japanese - English]>,
  #<DCSDictionary[Japanese]>,
  #<DCSDictionary[Simplified Chinese]>
]
> DictionaryServices.getActiveDictionaries.map(&:short_name)
=> [
  "English",
  "English Thesaurus",
  "Simplified Chinese - English",
  "Japanese - English",
  "Japanese",
  "Simplified Chinese" ]
> DictionaryServices.getActiveDictionaries
  .select{|d| d.short_name == "Japanese - English"}[0]
  .text_definition 'hello'
=> "hel･lo | həlóʊ, hel- | 間投詞 (!｟英｠ hallo, ｟主に英｠ hulloともつづる)..."
```

## References

- https://nshipster.com/dictionary-services/
- http://michaelchinen.com/2013/08/25/mac-dictionary-services/
- http://tobioka.net/716
- https://qiita.com/doraTeX/items/9b290f4e39f1e100558b