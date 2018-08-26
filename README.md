# MovieCapture
capture movie at your application for macOS

[![Language: Swift](https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgray.svg?style=flat)](https://img.shields.io/)
[![License](https://img.shields.io/github/license/masakih/MovieCapture.svg?style=flat)](https://github.com/masakih/MovieCapture/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub release](https://img.shields.io/github/release/masakih/MovieCapture.svg)](https://github.com/masakih/MovieCapture/releases/latest)

## 使い方
すごく簡単。

```swift
import MovieCapture

class ViewController: NSViewController {

    private var capture: MovieCapture?
    
    private let captureFrame = NSRect(x: 0, y: 0, width: 100, height: 100)
    
    @IBAction private func start(_: Any) {
        
        do {
            
            try capture = MovieCapture(screenFrame: captureFrame)
            
            try capture?.start()
            
        } catch {
            
            print(error)
        }
    }
    
    @IBAction private func finish(_: Any) {
        
        capture?.stop { url, error in
            
            if let error = error {
                
                print(error)
                return
            }
            
            NSWorkspace.shared.open(url)
        }
    }
}
```

## 音声入力
もしあなたのユーザーが Soundflower をインストールしているなら、それが使われる。
