// UserDefaultsManager.swift
// by Daniel Illescas Romero
// Github: @illescasDaniel
// License: MIT

import class Foundation.UserDefaults
import protocol Foundation.LocalizedError
import class Foundation.NSData
import class Foundation.NSString
import class Foundation.NSNumber
import class Foundation.NSDate
import class Foundation.NSArray
import class Foundation.NSDictionary
import struct Foundation.Date
import struct Foundation.Data

public protocol UserDefaultsKeyProtocol {
	// var string: String? { get }
	// ...
}
extension NSData: UserDefaultsKeyProtocol {}
extension NSString: UserDefaultsKeyProtocol {}
extension NSNumber: UserDefaultsKeyProtocol {}
extension NSDate: UserDefaultsKeyProtocol {}
extension NSArray: UserDefaultsKeyProtocol {}
extension NSDictionary: UserDefaultsKeyProtocol {}

extension Bool: UserDefaultsKeyProtocol {}
extension Int: UserDefaultsKeyProtocol {}
extension Double: UserDefaultsKeyProtocol {}
extension Float: UserDefaultsKeyProtocol {}
extension String: UserDefaultsKeyProtocol {}
extension Array: UserDefaultsKeyProtocol where Element: UserDefaultsKeyProtocol {}
extension Dictionary: UserDefaultsKeyProtocol where Key: UserDefaultsKeyProtocol, Value: UserDefaultsKeyProtocol {}
extension Data: UserDefaultsKeyProtocol {}
extension Date: UserDefaultsKeyProtocol {}

public protocol RawEnumProtocol: RawRepresentable {}
public protocol RawStringEnumProtocol: RawEnumProtocol where Self.RawValue == String {}
public protocol UserDefaultsEnumProtocol: RawStringEnumProtocol, CaseIterable { 
	var `default`: UserDefaultsKeyProtocol { get }
}

public final class UserDefaultsManager<Key: UserDefaultsEnumProtocol> {
	
	private let defaults: UserDefaults
	
	/// Should NOT be used directly, since everytime is called, it will register all default keys (again) in the standard UserDefaults
	/// It should be used when creating an extension, for example
	public static var standardDefaults: UserDefaultsManager<Key> {
		return UserDefaultsManager<Key>(defaults: .standard)
	}
	
	/// If the UserDefaults created from `suiteName` is nil, the class will use `UserDefaults.standard`
	public convenience init(suiteName: String) {
		self.init(defaults: UserDefaults(suiteName: suiteName))
	}
	
	fileprivate init(defaults: UserDefaults? = .standard) {
		self.defaults = defaults ?? .standard
		self.registerKeyDefaults()
	}
	
	//
	
	public subscript(key: Key) -> Any {
		get {
			return self.defaults.object(forKey: key.rawValue) ?? key.default
		} set {
			self.set(newValue, forKey: key)
		}
	}
	
	public subscript<T>(key: Key) -> T? {
		get {
			return (self[key] as Any) as? T
		} set {
			self.set(newValue, forKey: key)
		}
	}
	
	// Convenience
	
	private func registerKeyDefaults() {
		let mappedDefaults = Dictionary(uniqueKeysWithValues: Key.allCases.map { ($0.rawValue, $0.default) })
		self.defaults.register(defaults: mappedDefaults)
	}
	
	private func set(_ value: Any?, forKey key: Key) {
		self.defaults.set(value, forKey: key.rawValue)
	}
}

//

public enum UserDefaultsKey: String, UserDefaultsEnumProtocol {
	
	case isDarkTheme
	case isBlack
	case score
	case today
	
	public var `default`: UserDefaultsKeyProtocol {
		switch self {
		case .isDarkTheme: return false
		case .isBlack: return true
		case .score: return 20.1
		case .today: return Date()
		}
	}
}

// in app-delegate:

public extension UserDefaultsManager where Key == UserDefaultsKey {
	//public static let standard = UserDefaultsManager<Key>.standardDefaults
	public static let custom = UserDefaultsManager<Key>(suiteName: "_swift-app-test__5")
}

print(UserDefaultsManager.custom[.score])
UserDefaultsManager.custom[.score] = 99
let score: Int? = UserDefaultsManager.custom[.score]
print(score ?? 10)


print(UserDefaultsManager.custom[.today])
let today: Date? = UserDefaultsManager.custom[.today]
print(today)
