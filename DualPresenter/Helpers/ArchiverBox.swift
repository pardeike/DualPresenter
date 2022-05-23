import Foundation

public struct ArchiverBox<T: NSObject>: Codable where T: NSCoding {
	public let value: T
	
	public init(_ value: T) {
		self.value = value
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let data = try container.decode(Data.self)
		
		guard let castedValue = try? NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Couldn't unarchive object")
		}
		self.value = castedValue
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		if let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false) {
			try container.encode(data)
		}
	}
}
