# RxRestCaller

A simple library (backed by URLSession)  that allows to do REST calls and returns RxSwift `Observable`s

### Usage

```swift
let caller: RxRestCaller

let responsePayload:Observable<Dictionary<String, Any>> =  caller.callJsonRESTAsync("https://myapi/")
```
