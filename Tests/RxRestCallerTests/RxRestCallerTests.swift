import XCTest
import RxSwift
@testable import RxRestCaller

final class RxRestCallerTests: XCTestCase {
    
    func test_call_works() {
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

    static var allTests = [
        ("test_call_works", test_call_works),
    ]
}
