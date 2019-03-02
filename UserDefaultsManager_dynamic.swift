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

@dynamicMemberLookup
public final class UserDefaultsManager {
	
	public static let standard = UserDefaultsManager()
	private let defaults: UserDefaults
	
	/// If the UserDefaults created from `suiteName` is nil, the class will use `UserDefaults.standard`
	public convenience init(suiteName: String) {
		self.init(defaults: UserDefaults(suiteName: suiteName))
	}
		
	fileprivate init(defaults: UserDefaults? = .standard) {
		self.defaults = defaults ?? .standard
	}
	
	//
	
	public subscript<T>(dynamicMember member: String) -> T? {
		get {
			return try? self.object(forKey: member) as T
		} set {
			try? self.set(value: newValue, forKey: member)
		}
	}
	
	public subscript<T>(key: String, default default: T) -> T {
		return self[dynamicMember: key] ?? `default`
	}
	
	public func object<T>(forKey key: String) throws -> T {
		if let retrievedValue = self.defaults.object(forKey: key) {
			if let value = retrievedValue as? T {
				return value
			} else {
				throw Errors.RetrieveError.couldNotCast(value: retrievedValue, type: "\(T.self)")
			}
		} else {
			throw Errors.RetrieveError.keyNotFound(key)
		}
	}
	
	public func set<T>(value: T, forKey key: String) throws {
		if self.isPropertyListObject(value) {
			self.defaults.set(value, forKey: key)
		} else {
			throw Errors.SetError.notAPropertyListObject(type: "\(T.self)")
		}
	}
	
	public func load<T>(defaultValue: T, forKey key: String) {
		do {
			let _: T = try self.object(forKey: key)
		} catch Errors.RetrieveError.keyNotFound(_) {
			self[dynamicMember: key] = defaultValue
		} catch { }
	}
	
	public func register(defaults dictionary: [String: Any]) {
		self.defaults.register(defaults: dictionary)
	}
	
	public func load(defaults dictionary: [KeyPath<UserDefaultsManager.MemberStub, UserDefaultsManager.MemberStub>: Any]) {
		let stub = MemberStub()
		for (key, value) in dictionary {
			let member = stub[keyPath: key]
			self.load(defaultValue: value, forKey: member.key)
		}
	}
	
	// Convenience
	
	private func isPropertyListObject<T>(_ object: T) -> Bool {
		switch object {
		case is NSData, is NSString, is NSNumber, is NSDate, is NSArray, is NSDictionary:
			return true
		default:
			return false
		}
	}
}

public extension UserDefaultsManager {
	public enum Errors {
		public enum SetError: Error {
			case notAPropertyListObject(type: String)
		}
		public enum RetrieveError: Error {
			case keyNotFound(_: String)
			case couldNotCast(value: Any, type: String)
		}
	}
}

extension UserDefaultsManager.Errors.SetError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .notAPropertyListObject(let type):
			return String(format: "UserDefaultsManager - \"%@\" is not a valid properyty list object type", "\(type)")
		}
	}
}

extension UserDefaultsManager.Errors.RetrieveError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .keyNotFound(let key):
			return String(format: "UserDefaultsManager - Key \"%@\" was not found", key)
		case .couldNotCast(let value, let type):
			return String(format: "UserDefaultsManager - Could not cast retrieved value (%@) to \"%@\"", "\(value)", type)
		}
	}
}

public extension UserDefaultsManager {
	@dynamicMemberLookup
	public class MemberStub {
		var key: String
		init(key: String = "") {
			self.key = key
		}
		public subscript(dynamicMember member: String) -> UserDefaultsManager.MemberStub {
			get {
				return UserDefaultsManager.MemberStub(key: member)
			} set {
				self.key = newValue.key
			}
		}
	}
}

// in app-delegate:

UserDefaultsManager.standard.load(defaults: [
	\.isDarkThemeEnabled: false,
	\.isUserLogged: false,
	\.score: 0,
	\.thingsHere: 5,
	\.test_test: 22
])
print(UserDefaultsManager.standard.thingsHere ?? 0)

if UserDefaultsManager.standard.isUserLogged == false {
	let score: Int? = UserDefaultsManager.standard.score
	print(score ?? 0)
}

UserDefaultsManager.standard.isDarkThemeEnabled = true
print(UserDefaultsManager.standard.isDarkThemeEnabled ?? false)

print(UserDefaultsManager.standard.test_test ?? 0)



