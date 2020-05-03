import XCTest
import RxSwift
@testable import RxRestCaller

final class RxRestCallerTests: XCTestCase {
    
    func test_get_works() {
          let service = RxRestCaller()

          let actualObservable: Observable<Dictionary<String, Any>> = service.get(url: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")

          let ex = self.expectation(description: "Fetching succeeds")
          _ = actualObservable.subscribe(
                  onNext: { jsonData in
                      XCTAssertNotNil(jsonData)
                      let explanation = jsonData["explanation"]
                      XCTAssertNotNil(explanation)
                      print(explanation!)
                      ex.fulfill()
                  },
                  onError: { error in
                      XCTFail()
                  },
                  onCompleted: nil,
                  onDisposed: nil
          )

          self.wait(for: [ex], timeout: 10.0)
      }
    
    func test_call_works() {
        let service = RxRestCaller()
        
        var request = URLRequest(url: URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!)
        request.httpMethod = "GET"
        
        let actualObservable: Observable<ResponseWithData> = service.call(urlRequest: request)
        
        let ex = self.expectation(description: "Fetching succeeds")
        _ = actualObservable.subscribe(
            onNext: { responseWithData in
                XCTAssertNotNil(responseWithData)
                XCTAssertNotNil(responseWithData.data)
                
                let jsonData : Dictionary<String, Any>
                do{
                    try jsonData = JSONSerialization.jsonObject(with: responseWithData.data!) as! Dictionary<String, Any>
                } catch {
                    XCTFail()
                    return
                }
                
                let explanation = jsonData["explanation"]
                XCTAssertNotNil(explanation)
                print(explanation!)
                ex.fulfill()
        },
            onError: { error in
                XCTFail()
        },
            onCompleted: nil,
            onDisposed: nil
        )
        
        self.wait(for: [ex], timeout: 10.0)
    }

    static var allTests = [
        ("test_call_works", test_get_works),
    ]
}
