import XCTest
import RxSwift
@testable import RxRestCaller

final class RxRestCallerTests: XCTestCase {
    
   
    func test_call_with_return_type_works() {
        let service = RxRestCaller()
        
        var request = URLRequest(url: URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!)
        request.httpMethod = "GET"
        
        let expectation = self.expectation(description: "Fetching succeeds")
        _ = service.call(urlRequest: request, returnType: ResponseType.self).subscribe(
            onNext: {resp in
                
                XCTAssertNotNil(resp)
                XCTAssertNotNil(resp.data!.explanation)
                expectation.fulfill()
        },
            onError: { err in XCTFail(err.localizedDescription) },
            onCompleted: nil,
            onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }

    func test_call_for_type_works() {
        let service = RxRestCaller()

        var request = URLRequest(url: URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!)
        request.httpMethod = "GET"

        let expectation = self.expectation(description: "Fetching succeeds")


        _ = service.call(urlRequest: request, for: ResponseType.self).subscribe(
                onNext: {resp in
                    XCTAssertNotNil(resp)
                    XCTAssertNotNil(resp.explanation)
                    expectation.fulfill()
                },
                onError: { err in XCTFail(err.localizedDescription) },
                onCompleted: nil,
                onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }

    func test_call_for_type_triggers_onError_for_connection_refused() {
        let service = RxRestCaller()

        var request = URLRequest(url: URL(string: "https://kurwa.noop.doesnt.exist.nope")!)
        request.httpMethod = "GET"

        let expectation = self.expectation(description: "Fetching fails")


        _ = service.call(urlRequest: request, for: ResponseType.self).subscribe(
                onNext: {resp in
                    XCTFail("onError should have been triggered")
                },
                onError: { err in expectation.fulfill() },
                onCompleted: nil,
                onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }

    func test_call_for_type_triggers_onError_for_4XX() {
        let service = RxRestCaller()

        var request = URLRequest(url: URL(string: "https://identity-sc.test.mdl.swisscom.ch/me")!) // will trigger 400
        request.httpMethod = "GET"

        let expectation = self.expectation(description: "Fetching fails")


        _ = service.call(urlRequest: request, for: ResponseType.self).subscribe(
                onNext: {resp in
                    XCTFail("onError should have been triggered")
                },
                onError: { err in expectation.fulfill() },
                onCompleted: nil,
                onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }

    func test_call_for_data_works() {
        let service = RxRestCaller()

        var request = URLRequest(url: URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!)
        request.httpMethod = "GET"

        let expectation = self.expectation(description: "Fetching succeeds")

        _ = service.callForData(urlRequest: request).subscribe(
                onNext: {resp in
                    XCTAssertNotNil(resp)
                    expectation.fulfill()
                },
                onError: { err in XCTFail(err.localizedDescription) },
                onCompleted: nil,
                onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }

    func test_call_for_data_completes_without_onNext_for_response_without_data() {
        let service = RxRestCaller()

        var request = URLRequest(url: URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!)
        request.httpMethod = "HEAD"

        let expectation = self.expectation(description: "Fetching succeeds")

        _ = service.callForData(urlRequest: request).subscribe(
                onNext: {resp in
                    XCTFail("onNext should not have been emitted")
                },
                onError: { err in XCTFail(err.localizedDescription) },
                onCompleted: { expectation.fulfill()},
                onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }

    func test_call_for_data_triggers_onError_for_connection_refused() {
        let service = RxRestCaller()

        var request = URLRequest(url: URL(string: "https://kurwa.noop.doesnt.exist.nope")!)
        request.httpMethod = "GET"

        let expectation = self.expectation(description: "Fetching fails")


        _ = service.callForData(urlRequest: request).subscribe(
                onNext: {resp in
                    XCTFail("onError should have been triggered")
                },
                onError: { err in expectation.fulfill() },
                onCompleted: nil,
                onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }

    func test_call_for_data_triggers_onError_for_4XX() {
        let service = RxRestCaller()

        var request = URLRequest(url: URL(string: "https://identity-sc.test.mdl.swisscom.ch/me")!) // will trigger 400
        request.httpMethod = "GET"

        let expectation = self.expectation(description: "Fetching fails")


        _ = service.callForData(urlRequest: request).subscribe(
                onNext: {resp in
                    XCTFail("onError should have been triggered")
                },
                onError: { err in expectation.fulfill() },
                onCompleted: nil,
                onDisposed: nil
        )
        self.wait(for: [expectation], timeout: 10.0)
    }
    
    private struct ResponseType: Codable {
        var explanation: String
    }


}
