//
//  UserDefault.swift
//
//  Created by Daniel Illescas Romero on 16/03/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

public protocol PropertyListValue {}
extension NSData: PropertyListValue {}
extension NSString: PropertyListValue {}
extension NSNumber: PropertyListValue {}
extension NSDate: PropertyListValue {}
extension NSArray: PropertyListValue {}
extension NSDictionary: PropertyListValue {}

extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
extension String: PropertyListValue {}
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key: PropertyListValue & Hashable, Value: PropertyListValue {}
extension Data: PropertyListValue {}
extension Date: PropertyListValue {}

public extension UserDefaults {
	static var appSpecific: UserDefaults? {
		let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
		return UserDefaults.init(suiteName: appName)
	}
}

public struct UserDefault<Value: PropertyListValue> {
	public typealias Key = String
	
	private let key: Key
	private let defaultValue: Value
	private let userDefaults: UserDefaults
	
	public init(key: Key, defaultValue: Value, userDefaults: UserDefaults = .appSpecific ?? .standard) {
		self.key = key
		self.defaultValue = defaultValue
		self.userDefaults = userDefaults
	}
	public init<KeyType: RawRepresentable>(key: KeyType, defaultValue: Value, userDefaults: UserDefaults = .appSpecific ?? .standard) where KeyType.RawValue == String {
		self.init(key: key.rawValue, defaultValue: defaultValue, userDefaults: userDefaults)
	}
	
	public var value: Value {
		get {
			return self[key]
		} set {
			self[key] = newValue
		}
	}
	
	private subscript(key: Key) -> Value {
		get {
			return (Resource.SavedData.LocalConfig.appUserDefaults.value(forKey: key) as? Value) ?? self.defaultValue
		} set {
			Resource.SavedData.LocalConfig.appUserDefaults.set(newValue, forKey: key)
		}
	}
}
