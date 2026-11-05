import Foundation
import WrapKit

public class GameStorages {
    public static let shared = GameStorages()
    
    private init() {}
    
    private let keychain = KeychainSwift()
    
    public lazy var languageStorage = UserDefaultsStorage<[String]>(
        key: "AppleLanguages",
        getLogic: { userDefaults in
            if let appDomain = Bundle.main.bundleIdentifier,
               let languages = userDefaults.persistentDomain(forName: appDomain)?["AppleLanguages"] as? [String] {
                return languages
            }
            return Locale.preferredLanguages
        },
        setLogic: { userDefaults, model in
            userDefaults.setValue(model, forKey: "AppleLanguages")
        }
    )
    
    public lazy var isVibrationEnabledStorage = UserDefaultsStorage<Bool>(
        key: "isVibrationEnabled",
        getLogic: { userDefaults in
            return userDefaults.bool(forKey: "isVibrationEnabled")
        },
        setLogic: { userDefaults, model in
            userDefaults.set(model, forKey: "isVibrationEnabled")
        }
    )
    
    public lazy var accelerationStorage = UserDefaultsStorage<Int>(
        key: "acceleration",
        getLogic: { userDefaults in
            return userDefaults.integer(forKey: "acceleration")
        },
        setLogic: { userDefaults, model in
            userDefaults.set(model, forKey: "acceleration")
        }
    )
    
    public lazy var isBackgroundMusicEnabledStorage = UserDefaultsStorage<Bool>(
        key: "isBackgroundMusicEnabled",
        getLogic: { userDefaults in
            return userDefaults.bool(forKey: "isBackgroundMusicEnabled")
        },
        setLogic: { userDefaults, model in
            userDefaults.set(model, forKey: "isBackgroundMusicEnabled")
        }
    )
    
    public lazy var isSoundEffectsEnabledStorage = UserDefaultsStorage<Bool>(
        key: "isSoundEffectsEnabled",
        getLogic: { userDefaults in
            return userDefaults.bool(forKey: "isSoundEffectsEnabled")
        },
        setLogic: { userDefaults, model in
            userDefaults.set(model, forKey: "isSoundEffectsEnabled")
        }
    )
    
    public lazy var scoreStorage = InMemoryStorage<Double>()
}
