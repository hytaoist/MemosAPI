import Foundation

public struct Multipart: Encodable {
    public let name: String
    public let filename: String
    public let contentType: String
    public let data: Data
    
    public init(name: String, filename: String, contentType: String, data: Data) {
        self.name = name
        self.filename = filename
        self.contentType = contentType
        self.data = data
    }
}

public func encodeFormData(multiparts: [Multipart], boundary: String) -> Data {
    var data = Data()
    
    for part in multiparts {
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(part.filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(part.contentType)\r\n".data(using: .utf8)!)
        data.append("\r\n".data(using: .utf8)!)
        data.append(part.data)
        data.append("\r\n".data(using: .utf8)!)
    }
    data.append("--\(boundary)--".data(using: .utf8)!)
    
    return data
}
