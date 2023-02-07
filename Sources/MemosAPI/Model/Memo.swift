import Foundation

public enum MemosVisibility: String, Decodable, Encodable {
    case `public` = "PUBLIC"
    case `protected` = "PROTECTED"
    case `private` = "PRIVATE"
}

public enum MemosRowStatus: String, Decodable, Encodable {
    case normal = "NORMAL"
    case archived = "ARCHIVED"
}

public struct Memo: Decodable, Equatable {
    public let id: Int
    public let createdTs: Date
    public let creatorId: Int
    public var content: String
    public var pinned: Bool
    public let rowStatus: MemosRowStatus
    public let updatedTs: Date
    public let visibility: MemosVisibility
    public let resourceList: [Resource]?
}

public struct Tag: Identifiable, Hashable {
    public let name: String
    
    public var id: String { name }
}
