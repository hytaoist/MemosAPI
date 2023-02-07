import Foundation

public enum MemosError: LocalizedError {
    case unknown
    case notLogin
    case invalidStatusCode(Int, String?)
    case invalidParams
    case invalidOpenAPI
    
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error."
        case .notLogin:
            return "You are logged out."
        case .invalidStatusCode(_, let message):
            if let message = message {
                return message
            }
            return "Network error."
        case .invalidParams:
            return "Please enter a valid input."
        case .invalidOpenAPI:
            return "The Open API URL is incorrect."
        }
    }
}
