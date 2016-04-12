RECAIUS 音声認識/音声合成APIサンプルアプリケーション(iOS版)  
====

このプロジェクトは、RECAIUS 音声認識/音声合成のWeb APIを利用して動作するアプリケーションを公開しています。  

## Description
このプロジェクトのアプリケーションを動作させる場合は、事前にRECAIUS APIのディベロッパー登録が必要です。  
登録は、[こちらのサイト](https://developer.recaius.io/jp/top.html)から行えます。  

アプリケーションを起動して、単語を問いかけると[Wikipedia](https://ja.wikipedia.org/)で単語を検索して、意味を読み上げてくれます。  

具体的には、  

* あなた：「Hey！」と話しかける
* アプリ：「はい」と応える
* あなた：「アイスクリーム」と話しかける
* アプリ：（Wikipediaで検索）アイスクリームのページの内容を読み上げる

という動きになります。

## Requirement

* Xcode 7.3
* Carthage 0.15.2
* iOS 9.0以上

サードパーティーライブラリを管理するために[Carthage](https://github.com/Carthage/Carthage)を利用しています。  
[Installing Carthage](https://github.com/Carthage/Carthage#installing-carthage)を参考に、インストールを行ってください。  

シミュレータでもMacのマイクとスピーカーを用いて動作を確認することができます。  
また、Xcode 7からApple IDさえ持っていれば、Apple Developer Programに加入していなくても、実機上でアプリが実行できるようになりました。  

## Usage & Install

<1> Carthageを実行し必要なライブラリをインストールします  

```
carthage update --platform iOS --no-use-binaries
```

なお、サードパーティーライブラリのビルドの際に、多くのWarmingが表示されます。  
これはSwift 2.2で非推奨になった記述をライブラリが含んでいるためです。  
ビルド自体は問題なく行われ、利用時も影響はないため無視していだたいて大丈夫です。  

<2> シミュレータでの動作の確認  

`recaius-ios-sample`スキーマを選択し、任意のシミュレータを選択した状態で、実行するとシミュレータ上で動作を確認することができます。  

<3> アプリケーションを実機にインストールします

実機を接続し、接続したデバイスを選択した状態で、実行ボタンを押してください。  
もし、ビルド中にエラーが発生してダイアログが表示された場合、その内容に従ってください。  
Apple Developer Programに加入しておらず、初めて実機で動作確認を行うといった方は、[Xcode7で1円も払わずに自作iOSアプリを実機確認する](http://qiita.com/FumihikoSHIROYAMA/items/a754f77c41b585c90329)等のポストが参考になると思います。  

## Licence

* MIT
    * This software is released under the MIT License, see LICENSE.txt.

本プログラムを利用して宣伝などを行う場合、[こちらのサイト](https://developer.recaius.io/jp/contact.html)からご連絡ください。

## Author

[recaius-dev-jp](https://github.com/recaius-dev-jp)
