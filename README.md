UserDefaultsManager
-------

Load user preferences faster and/or safer with these 3 different ways:

### Dynamic
`UserDefaultsManager-dynamic.swift`
```swift
// Easily load default initial values - (do it in the app delegate)
UserDefaultsManager.standard.load(defaults: [
  \.isDarkThemeEnabled: false,
  \.isUserLogged: false,
  \.score: 0
])
// or:
UserDefaultsManager.standard.load(defaults: [
  "isDarkThemeEnabled": false,
  "isUserLogged": false,
  "score": 0
])
```
```swift
// Get saved stuff
if UserDefaultsManager.standard.isUserLogged == false {
  let score: Int? = UserDefaultsManager.standard.score
  print(score ?? 0)
}
```
```swift
// Save stuff
UserDefaultsManager.standard.isDarkThemeEnabled = true
print(UserDefaultsManager.standard.isDarkThemeEnabled ?? false)
```

### Soft-Dynamic
`UserDefaultsManager-soft-dynamic.swift`
```swift
// Create an enum conforming to `UserDefaultsEnumProtocol` for the keys and default values
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

public extension UserDefaultsManager where Key == UserDefaultsKey {
  //public static let standard = UserDefaultsManager<Key>.standardDefaults
  public static let custom = UserDefaultsManager<Key>(suiteName: "_swift-app-test__5")
}

print(UserDefaultsManager.custom[.score])
UserDefaultsManager.custom[.score] = 99
let score: Int? = UserDefaultsManager.custom[.score]
print(score ?? 10)
```

### Static
`UserDefaultsManager-static.swift`
```swift
// Create an enum conforming to `UserDefaultsKey` and others conforming to `StringUserDefaultsKey`, `BoolUserDefaultsKey`, (double, float, date, data, etc)
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
  public enum array: ArrayUserDefaultsKey {
    case numbers
    case stringggg
    public var defaultValue: EnumType {
      switch self {
        case .numbers: return [0]
        case .stringggg: return [""]
      }
    }
  }
  // TODO: this might need some tweaking to allow different Dictionary types
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
  public static var arrays = array.allCases
  public static var dictionaries = dictionary.allCases
}

public extension UserDefaultsManager where DefaultsKeyType == DefaultsKey {
  public static let appDefaults = UserDefaultsManager<DefaultsKey>(suiteName: "app-name_3")
}

// Completely type safe retrieval and assignment
print(UserDefaultsManager.appDefaults[.hi])
UserDefaultsManager.appDefaults[.hi] = "lol"

UserDefaultsManager.appDefaults[.numbers] = [8,5,3]
print(UserDefaultsManager.appDefaults[.numbers] as [Int])

UserDefaultsManager.appDefaults[.keyValues] = [
  "test": 999,
  "what": 1234
]
```
