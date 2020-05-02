import Foundation
import RxSwift

private enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case PATCH = "PATCH"
}

fileprivate let responseDataMapper = { (responseData: ResponseWithData) in
    return try JSONSerialization.jsonObject(with: responseData.data!) as! Dictionary<String, Any>
}

open class RxRestCaller {
    
    private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        
    public init() {}
    
    /**
        calls the provided `URLRequest` and returns an `Observable<Dictionary<String, Any>>` representing
        the response's json payload (assumed to be an object, not an array)
    */
    open func callJson(urlRequest: URLRequest) -> Observable<Dictionary<String, Any>> {
        return call(urlRequest: urlRequest)
            .map(responseDataMapper)
    }
    
    /**
        calls the provided `url` with `GET` method and returns an `Observable<Dictionary<String, Any>>` representing
        the response's json payload (assumed to be an object, not an array)
    */
    open func get(url: String) -> Observable<Dictionary<String, Any>>{
        return call(urlRequest: buildRequest(url: url, method: .GET))
            .map(responseDataMapper)
    }
    
    /**
        calls the provided `url` with `GET` method and returns an `Observable<Dictionary<String, Any>>` representing
        the response's json payload (assumed to be an object, not an array)
    */
    @available(*, deprecated, message: "use get(url:) instead")
    open func callJsonRESTAsync(url: String) -> Observable<Dictionary<String, Any>> {
        return call(urlRequest: buildRequest(url: url, method: .GET))
            .map(responseDataMapper)
    }
    
    /**
        calls the provided `URLRequest` and returns an `Observable<ResponseWithData>` representing
        the response and its data
    */
    open func call(urlRequest: URLRequest) -> Observable<ResponseWithData> {
        return Observable.create({ observer in
            let task: URLSessionDataTask =
                self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                    if let response = response  {
                        observer.onNext(ResponseWithData(data: data, response: response))
                        observer.onCompleted()
                    } else if let error = error {
                        observer.onError(error)
                    }
            }
            task.resume()
            return Disposables.create(with: {
                task.cancel()
            })
        })
    }
    
    private func buildRequest(url: String, method: HttpMethod) -> URLRequest {
        let url = URL(string: url)
        
        var request = URLRequest(url: url!)
        request.httpMethod = method.rawValue
        return request
    }
}

/// representation of the result of `URLSessionDataTask`, contains `Data?` and `URLResponse`
public struct ResponseWithData {
    public let data: Data?
    public let response: URLResponse
}
