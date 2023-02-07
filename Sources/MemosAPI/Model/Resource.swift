import Foundation

public struct Resource: Decodable, Identifiable, Equatable {
    public let id: Int
    public let createdTs: Date
    public let creatorId: Int
    public let filename: String
    public let size: Int
    public let type: String
    public let updatedTs: Date
    
    public func path() -> String {
        return "/o/r/\(id)/\(filename)"
    }
}
