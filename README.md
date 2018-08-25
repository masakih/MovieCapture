# MovieCapture
capture movie at your application for macOS


## 使い方
すごく簡単。

```swift
import MovieCapture

class ViewCOntroller: NSViewController {

    private var capture: MovieCapture?
    
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
