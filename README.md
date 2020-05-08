# RxRestCaller

A simple library (backed by URLSession)  that allows to do REST calls and returns RxSwift `Observable`s

### Usage

#### First variant

```swift
let caller: RxRestCaller()

var request = URLRequest(url: URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!)
request.httpMethod = "GET"

caller.call(request: request, for: ExpectedReturnType.self)
.subscribe(
    onNext: {responseData: ExpectedReturnType in
        ... 
    },
    onError:  {_ in }
    onCompleted:  {_ in }
)
```

#### Second variant

```swift
let caller: RxRestCaller()

var request = URLRequest(url: URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!)
request.httpMethod = "GET"

caller.call(request: request, returnType: ExpectedReturnType.self)
.subscribe(
    onNext: {responseWithData: ResponseWithTypedData<ExpectedReturnType> in
        responseWithData.
    },
    onError:  {_ in }
    onCompleted:  {_ in }
)
```