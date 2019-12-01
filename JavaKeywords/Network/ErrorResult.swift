import Foundation

enum ErrorResult: Error {
    case network(string: String)
    case decode(string: String)
    case custom(string: String)
}
