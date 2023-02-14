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
    
    public init(id: Int, createdTs: Date, creatorId: Int, filename: String, size: Int, type: String, updatedTs: Date) {
        self.id = id
        self.createdTs = createdTs
        self.creatorId = creatorId
        self.filename = filename
        self.size = size
        self.type = type
        self.updatedTs = updatedTs
    }
}
