import Foundation
import RxSwift

public enum HttpMethod: String {
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
    
    open func callJson(urlRequest: URLRequest) -> Observable<Dictionary<String, Any>> {
        return call(urlRequest: urlRequest)
            .map(responseDataMapper)
    }
    
    open func get(url: String) -> Observable<Dictionary<String, Any>>{
        return call(urlRequest: buildRequest(url: url, method: .GET))
            .map(responseDataMapper)
    }
    
    @available(*, deprecated, message: "use get(url:) instead")
    open func callJsonRESTAsync(url: String) -> Observable<Dictionary<String, Any>> {
        return call(urlRequest: buildRequest(url: url, method: .GET))
            .map(responseDataMapper)
    }
    
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

public struct ResponseWithData {
    public let data: Data?
    public let response: URLResponse
}
