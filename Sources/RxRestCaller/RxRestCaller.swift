import Foundation
import RxSwift

public class RxRestCaller {
    
    public init() {}
    
    private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    public func callJsonRESTAsync(url: String) -> Observable<Dictionary<String, Any>> {
        let url = URL(string: url)
        
        return Observable.create({ observer in
            let task: URLSessionDataTask =
                self.session.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
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
}
