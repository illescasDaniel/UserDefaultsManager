// UserDefaultsManager.swift
// by Daniel Illescas Romero
// Github: @illescasDaniel
// License: MIT

import Foundation

public protocol ValidDefaultsKeyProtocol {}
extension NSData: ValidDefaultsKeyProtocol {}
extension NSString: ValidDefaultsKeyProtocol {}
extension NSNumber: ValidDefaultsKeyProtocol {}
extension NSDate: ValidDefaultsKeyProtocol {}
extension NSArray: ValidDefaultsKeyProtocol {}
extension NSDictionary: ValidDefaultsKeyProtocol {}

extension Bool: ValidDefaultsKeyProtocol {}
extension Int: ValidDefaultsKeyProtocol {}
extension Double: ValidDefaultsKeyProtocol {}
extension Float: ValidDefaultsKeyProtocol {}
extension String: ValidDefaultsKeyProtocol {}
extension Array: ValidDefaultsKeyProtocol where Element: ValidDefaultsKeyProtocol {}
extension Dictionary: ValidDefaultsKeyProtocol where Key: ValidDefaultsKeyProtocol & Hashable, Value: ValidDefaultsKeyProtocol {}
extension Data: ValidDefaultsKeyProtocol {}
extension Date: ValidDefaultsKeyProtocol {}

fileprivate extension CaseIterable where Self: Equatable {
	var index: Self.AllCases.Index? {
		return Self.allCases.firstIndex { $0 == self }
	}
}

public protocol UserDefaultsKeyProtocol: CaseIterable, Hashable {
	associatedtype EnumType
	var defaultValue: EnumType { get }
	var rawValue: String { get }
}

public extension UserDefaultsKeyProtocol {
	var rawValue: String { 
		return "\(self)"
	}
}
//

public protocol StringUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == String { }
public protocol BoolUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Bool { }
public protocol IntUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Int { }
public protocol DoubleUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Double { }
public protocol FloatUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Float { }
public protocol DateUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Date { }
public protocol DataUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Data { }

public protocol ArrayUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Array<ValidDefaultsKeyProtocol> { }
public protocol DictionaryUserDefaultsKey: UserDefaultsKeyProtocol where Self.EnumType == Dictionary<DictKey, DictValue> {
	associatedtype DictKey: ValidDefaultsKeyProtocol & Hashable = String
	associatedtype DictValue: ValidDefaultsKeyProtocol = String 
}

public enum StringStub_: String, StringUserDefaultsKey {
	case none_s__
	public var defaultValue: String { return "" }
}
public enum BoolStub_: String, BoolUserDefaultsKey {
	case none_b__
	public var defaultValue: Bool { return false }
}
public enum IntStub_: String, IntUserDefaultsKey {
	case none_i__
	public var defaultValue: Int { return 0 }
}
public enum DoubleStub_: String, DoubleUserDefaultsKey {
	case none_d__
	public var defaultValue: Double { return 0.0 }
}
public enum FloatStub_: String, FloatUserDefaultsKey {
	case none_f__
	public var defaultValue: Float { return 0.0 }
}
public enum DateStub_: String, DateUserDefaultsKey {
	case none_da__
	public var defaultValue: Date { return Date() }
}
public enum DataStub_: String, DataUserDefaultsKey {
	case none_daa__
	public var defaultValue: Data { return Data() }
}
public enum ArrayStub_: String, ArrayUserDefaultsKey {
	case none_arr__
	public var defaultValue: EnumType { return [] }
}
public enum DictionaryStub_: String, DictionaryUserDefaultsKey {
	public typealias EnumType = [String: String]
	case none_dict__
	public var defaultValue: EnumType { return [:] }
}


public protocol UserDefaultsKey where Strings: StringUserDefaultsKey, 
												Bools: BoolUserDefaultsKey, 
												Ints: IntUserDefaultsKey,
												Doubles: DoubleUserDefaultsKey,
												Floats: FloatUserDefaultsKey,
												Dates: DateUserDefaultsKey,
												Datas: DataUserDefaultsKey,
												Arrays: ArrayUserDefaultsKey,
												Dictionaries: DictionaryUserDefaultsKey {
	
	associatedtype Strings = StringStub_
	static var strings: [Strings] { get }
	
	associatedtype Bools = BoolStub_
	static var bools: [Bools] { get }
	
	associatedtype Ints = IntStub_
	static var ints: [Ints] { get }
	
	associatedtype Doubles = DoubleStub_
	static var doubles: [Doubles] { get }
	
	associatedtype Floats = FloatStub_
	static var floats: [Floats] { get }
	
	associatedtype Dates = DateStub_
	static var dates: [Dates] { get }
	
	associatedtype Datas = DataStub_
	static var datas: [Datas] { get }
	
	associatedtype Arrays = ArrayStub_
	static var arrays: [Arrays] { get }
	
	associatedtype Dictionaries = DictionaryStub_
	static var dictionaries: [Dictionaries] { get }
}

public extension UserDefaultsKey {
	static var strings: [Strings] { return [] }
	static var bools: [Bools] { return [] }
	static var ints: [Ints] { return [] }
	static var doubles: [Doubles] { return [] }
	static var floats: [Floats] { return [] }
	static var dates: [Dates] { return [] }
	static var datas: [Datas] { return [] }
	static var arrays: [Arrays] { return [] }
	static var dictionaries: [Dictionaries] { return [] }	
}

//

public typealias DefaultsManager = UserDefaultsManager
public final class UserDefaultsManager<DefaultsKeyType: UserDefaultsKey> {
	
	private let defaults: UserDefaults
	
	/// Should NOT be used directly, since everytime is called, it will register all default keys (again) in the standard UserDefaults
	/// It should be used when creating an extension, for example
	public static var standardDefaults: UserDefaultsManager<DefaultsKeyType> {
		return UserDefaultsManager<DefaultsKeyType>(defaults: .standard)
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
	
	public subscript(key: DefaultsKeyType.Strings) -> DefaultsKeyType.Strings.EnumType {
		get {
			return self.defaults.string(forKey: key.rawValue) ?? key.defaultValue
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}
	
	public subscript(key: DefaultsKeyType.Bools) -> DefaultsKeyType.Bools.EnumType {
		get {
			return self.defaults.bool(forKey: key.rawValue)	
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}
	
	public subscript(key: DefaultsKeyType.Ints) -> DefaultsKeyType.Ints.EnumType {
		get {
			return self.defaults.integer(forKey: key.rawValue)
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}
	
	public subscript(key: DefaultsKeyType.Doubles) -> DefaultsKeyType.Doubles.EnumType {
		get {
			return self.defaults.double(forKey: key.rawValue)
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}
	
	public subscript(key: DefaultsKeyType.Floats) -> DefaultsKeyType.Floats.EnumType {
		get {
			return self.defaults.float(forKey: key.rawValue)
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}
	
	public subscript(key: DefaultsKeyType.Dates) -> DefaultsKeyType.Dates.EnumType {
		get {
			return (self.defaults.object(forKey: key.rawValue) as? Date) ?? key.defaultValue
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}

	public subscript(key: DefaultsKeyType.Datas) -> DefaultsKeyType.Datas.EnumType {
		get {
			return self.defaults.data(forKey: key.rawValue) ?? key.defaultValue
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}
	
	public subscript<ElementType: ValidDefaultsKeyProtocol>(key: DefaultsKeyType.Arrays) -> [ElementType] {
		get {
			return (self.defaults.array(forKey: key.rawValue) as? [ElementType]) ?? (key.defaultValue as? [ElementType]) ?? [ElementType]()
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}

	public subscript(key: DefaultsKeyType.Dictionaries) -> DefaultsKeyType.Dictionaries.EnumType {
		get {
			return (self.defaults.dictionary(forKey: key.rawValue) as? DefaultsKeyType.Dictionaries.EnumType) ?? key.defaultValue
		} set {
			self.defaults.set(newValue, forKey: key.rawValue)
		}
	}

	// Convenience
	
	private func registerKeyDefaults() {
		var allKeys: [(String, Any)] = keysFor(DefaultsKeyType.strings) + keysFor(DefaultsKeyType.bools) + keysFor(DefaultsKeyType.ints) + keysFor(DefaultsKeyType.doubles) 
			allKeys += keysFor(DefaultsKeyType.floats) + keysFor(DefaultsKeyType.dates) + keysFor(DefaultsKeyType.datas) + keysFor(DefaultsKeyType.arrays) + keysFor(DefaultsKeyType.dictionaries)	
		self.defaults.register(defaults: Dictionary(uniqueKeysWithValues: allKeys))
	}
	
	private func keysFor<T: UserDefaultsKeyProtocol>(_ keys: [T]) -> [(String, Any)]{
		return keys.map { ($0.rawValue, $0.defaultValue) }
	}
}


//

public struct DefaultsKey: UserDefaultsKey {
	public enum string: StringUserDefaultsKey {
		case hi
		case test
		public var defaultValue: String {
			switch self {
				case .hi: return "this"
				case .test: return "testaaa"
			}
		}
	}
	public enum bool: BoolUserDefaultsKey {
		case isOpen
		public var defaultValue: Bool {
			switch self {
				case .isOpen: return true
			}
		}
	}
	public enum int: IntUserDefaultsKey {
		case score
		case testtest
		public var defaultValue: Int {
			switch self {
				case .score: return 0
				case .testtest: return -1
			}
		}
	}
	public enum double: DoubleUserDefaultsKey {
		case height
		case hello
		public var defaultValue: Double {
			switch self {
				case .height: return 0.4
				case .hello: return 1.6
			}
		}
	}
	public enum float: FloatUserDefaultsKey {
		case width
		case ping
		public var defaultValue: Float {
			switch self {
				case .width: return 0.4
				case .ping: return 2
			}
		}
	}
	
	public enum date: DateUserDefaultsKey {
		case yesterday
		case tomorrow
		public var defaultValue: Date {
			switch self {
				case .yesterday: return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
				case .tomorrow: return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
			}
		}
	}
	
	public enum data: DataUserDefaultsKey {
		case dataTest
		public var defaultValue: Data {
			switch self {
				case .dataTest: return Data()
			}
		}
	}
	
	public enum array: ArrayUserDefaultsKey {
		case numbers
		case stringggg
		public var defaultValue: EnumType {
			switch self {
				case .numbers: return [0]
				case .stringggg: return [""] // yep, it seems that in the end array is just [Any]
			}
		}
	}
	
	public enum dictionary: DictionaryUserDefaultsKey {
		public typealias DictKey = String
		public typealias DictValue = Int
		case keyValues
		case keyStuff
		public var defaultValue: [DictKey: DictValue] {
			switch self {
				case .keyValues: return ["aaa": 10, "bb": 6]
				case .keyStuff: return ["ccc": 20]
			}
		}
	}
	
	public static var strings = string.allCases 
	public static var bools = bool.allCases
	public static var ints = int.allCases 
	public static var doubles = double.allCases 
	public static var floats = float.allCases 
	public static var dates = date.allCases 
	public static var datas = data.allCases 
	public static var arrays = array.allCases 
	public static var dictionaries = dictionary.allCases
}

public extension UserDefaultsManager where DefaultsKeyType == DefaultsKey {
	public static let appDefaults = UserDefaultsManager<DefaultsKey>(suiteName: "app-name_3")
}

public extension UserDefaultsManager where DefaultsKeyType == DefaultsKey {
	public static let standard = UserDefaultsManager<DefaultsKey>.standardDefaults
}

print(UserDefaultsManager.appDefaults[.hi])
UserDefaultsManager.appDefaults[.hi] = "lol"
print(UserDefaultsManager.appDefaults[.hi])
UserDefaultsManager.appDefaults[.score] = 105
print(UserDefaultsManager.appDefaults[.score])

UserDefaultsManager.appDefaults[.numbers] = [8,5,3]
print(UserDefaultsManager.appDefaults[.numbers] as [Int])

UserDefaultsManager.appDefaults[.keyValues] = [
	"test": 999,
	"what": 1234
]
print(UserDefaultsManager.appDefaults[.keyValues])


DefaultsManager.standard[.score] = 999
print(DefaultsManager.standard[.score])