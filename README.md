UserDefaultsManager
-------

Load user preferences in a more simple and dynamic way.

### Examples:
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
