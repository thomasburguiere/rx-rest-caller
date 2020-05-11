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

open class RxRestCaller {

    private let session: URLSession
    private let jsonDecoder = JSONDecoder()

    public init(session: URLSession? = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session!
    }

    /**
        calls the provided `URLRequest` and returns an `Observable<ResponseWithTypedData<T>>` representing
        the response and its typed data
    */
    open func call<T: Decodable>(urlRequest: URLRequest, returnType: T.Type) -> Observable<ResponseWithTypedData<T>> {
        return call(urlRequest: urlRequest)
                .map { responseWithRawData in
                    let typedData: T? = try? self.jsonDecoder.decode(returnType, from: responseWithRawData.data!)
                    return ResponseWithTypedData(data: typedData, response: responseWithRawData.response)
                }
    }

    /**
        calls the provided `URLRequest` and returns an `Observable<T>` representing
        the responses' data. Errors (connection error, 404, 500, etc...) will returned in the onError event of the
        Observable
    */
    open func call<T: Decodable>(urlRequest: URLRequest, for returnType: T.Type) -> Observable<T> {
        return Observable.create({ observer in
            let task: URLSessionDataTask = self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in

                guard error == nil else {
                    observer.onError(error!)
                    return
                }

                if response == nil || (response!.isKind(of: HTTPURLResponse.self) == false) {
                    observer.onError(fatalError("response is missing, or not of type HTTPURLResponse"))
                    return
                }

                let httpResponse = response as! HTTPURLResponse

                guard httpResponse.statusCode < 400 else {
                    observer.onError(RxRestCallerError("response has status \(httpResponse.statusCode)"))
                    return
                }

                let typedData: T? = try? self.jsonDecoder.decode(returnType, from: data!)
                observer.on(.next(typedData!))
                observer.on(.completed)
            }
            task.resume()
            return Disposables.create(with: {
                task.cancel()
            })
        });
    }

    /**
        calls the provided `URLRequest` and returns an `Observable<ResponseWithData>` representing
        the response and its raw data
    */
    open func call(urlRequest: URLRequest) -> Observable<ResponseWithData> {
        return Observable.create({ observer in
            let task: URLSessionDataTask =
                    self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                        if let response = response {
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

    /**
    calls the provided `URLRequest` and returns an `Observable<Data>` representing
    the responses' raw data. Errors (connection error, 404, 500, etc...) will returned in the onError event of the
    Observable. If the response contains no data, the Observable will just complete
    */
    open func callForData(urlRequest: URLRequest) -> Observable<Data> {
        return Observable.create({ observer in
            let task: URLSessionDataTask = self.session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }

                guard response != nil else {
                    observer.onError(fatalError("response is missing"))
                    return
                }

                guard response!.isKind(of: HTTPURLResponse.self) else {
                    observer.onError(fatalError("response is not of type HTTPURLResponse"))
                    return
                }

                let httpResponse = response as! HTTPURLResponse

                guard httpResponse.statusCode < 400 else {
                    observer.onError(RxRestCallerError("response has status \(httpResponse.statusCode)"))
                    return
                }

                if data != nil && data!.count > 0 {
                    observer.onNext(data!)
                }

                observer.onCompleted()
            }
            task.resume()
            return Disposables.create(with: {
                task.cancel()
            })
        })
    }
}

/// representation of the result of `URLSessionDataTask`, contains `Data?` and `URLResponse`
public struct ResponseWithData {
    public let data: Data?
    public let response: URLResponse
}

public struct ResponseWithTypedData<T> {
    public let data: T?
    public let response: URLResponse
}
