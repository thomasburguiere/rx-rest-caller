//
// Created by Thomas Burguiere on 08.05.20.
//

import Foundation

struct RxRestCallerError: Error {
    var localizedDescription: String

    init(_ message: String) {
        self.localizedDescription = message
    }

}