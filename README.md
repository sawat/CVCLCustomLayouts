CVCLCustomLayouts
=================

これは、UICollectionViewのカスタムレイアウト集です。

![image](https://github.com/sawat/CVCLCustomLayouts/blob/master/ScreenShots/ss1_cover_flow.png?raw=true)


注意
====
iOS6.0.1において、UICollectionViewLayoutのデコレーションビューの生成と再利用に
バグがあるようです。具体的に言うと、スクロールアウトして非表示になったデコレーションビューの
インスタンスが正しく再利用されず、スクロールするたび、無限にインスタンスが生成され再利用プールに
キャッシュされるようです（広義のメモリリーク）。

CVCLCoverFlowLayoutのreflectionプロパティにYESを設定した場合に表示される
鏡像はデコレーションビューを使用しています。
そのため、UICollectionViewの上記のバグが修正されない限り、メモリリークが発生することにご注意ください。

LICENCE
=======

The MIT License

Copyright (c) 2012 Tatsuhiro Sawa

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.