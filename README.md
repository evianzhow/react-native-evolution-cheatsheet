# React Native Evolution Cheatsheet

Browse for React Native Components and APIs availability from version to version, see the evolutions.

## Getting Started

These tables are generated from the table of contents of the official [Getting Started](http://facebook.github.io/react-native/docs/getting-started.html), using a Ruby script. The website itself is using GitHub Pages, powered by [jekyll](https://jekyllrb.com).

### Prerequisites

Install Ruby first if you have it on your computer.

```
gem install --no-rdoc --no-ri nokogiri semantic
```

### Generating

Run the Ruby script to generate `rn-components-evolution.csv` and `rn-components-evolution.csv` under working directory from the docs.

```
ruby main.rb
```
or
```
chmod +x main.rb
./main.rb
```

Import those two CSVs into Microsoft Excel or LibreOffice Calc using UTF-8 encoding, then **do an whole spreadsheet transpose**.

## Future Plans

To include other evolutions such as:

- [ ]Syntax
- [ ]_etc._

## License

This document is licensed under the CC-BY-4.0 - see the [LICENSE](LICENSE) file for details.
