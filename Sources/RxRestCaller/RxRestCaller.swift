import Foundation
import RxSwift

public protocol RxRestCaller {
    func get(url: String) -> Observable<Dictionary<String, Any>>
    
    func call(urlRequest: URLRequest) -> Observable<Dictionary<String, Any>>
    
    @available(*, deprecated)
    func callJsonRESTAsync(url: String) -> Observable<Dictionary<String, Any>>
}

public enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case PATCH = "PATCH"
}

open class DefaultRxRestCaller: RxRestCaller {
    
    private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        
    public init() {}
    
    public func call(urlRequest: URLRequest) -> Observable<Dictionary<String, Any>> {
        return callJsonRESTAsync(urlRequest: urlRequest)
    }
    
    open func get(url: String) -> Observable<Dictionary<String, Any>>{
        return callJsonRESTAsync(urlRequest: buildRequest(url: url, method: .GET))
    }
    
    @available(*, deprecated)
    open func callJsonRESTAsync(url: String) -> Observable<Dictionary<String, Any>> {
        return callJsonRESTAsync(urlRequest: buildRequest(url: url, method: .GET))
    }
    
    private func callJsonRESTAsync(urlRequest: URLRequest) -> Observable<Dictionary<String, Any>> {
        return Observable.create({ observer in
            let task: URLSessionDataTask =
                self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                    if let data: Data = data {
                        do {
                            // Convert the data to JSON
                            let jsonSerialized = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any>
                            observer.onNext(jsonSerialized!)
                            observer.onCompleted()
                        } catch let error as NSError {
                            observer.onError(error)
                        }
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
