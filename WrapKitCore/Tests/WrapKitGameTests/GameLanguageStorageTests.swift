import Combine
import Foundation
import WrapKitGame
import XCTest

@MainActor
final class GameLanguageStorageTests: XCTestCase {
    func testAppOwnedLanguageOverrideDoesNotReadAnotherDefaultsDomain() throws {
        try withLanguageDefaults { defaults, appDomain in
            defaults.set(["fr", "ja"], forKey: "AppleLanguages")
            var arguments = defaults.volatileDomain(forName: UserDefaults.argumentDomain)
            arguments["AppleLanguages"] = ["de"]
            defaults.setVolatileDomain(arguments, forName: UserDefaults.argumentDomain)

            XCTAssertEqual(defaults.stringArray(forKey: "AppleLanguages"), ["de"])
            XCTAssertEqual(defaults.persistentDomain(forName: appDomain)?["AppleLanguages"] as? [String], ["fr", "ja"])
            XCTAssertEqual(GameStorages.shared.languageStorage.get(), ["fr", "ja"])
        }
    }

    func testWithoutAppOverrideUsesPreferredLanguages() throws {
        try withLanguageDefaults { defaults, appDomain in
            defaults.removeObject(forKey: "AppleLanguages")

            XCTAssertNil(defaults.persistentDomain(forName: appDomain)?["AppleLanguages"])
            XCTAssertEqual(GameStorages.shared.languageStorage.get(), Locale.preferredLanguages)
        }
    }

    func testWritingAndClearingLanguagesOnlyChangesTheAppOverride() throws {
        try withLanguageDefaults { defaults, appDomain in
            var arguments = defaults.volatileDomain(forName: UserDefaults.argumentDomain)
            arguments["AppleLanguages"] = ["de"]
            defaults.setVolatileDomain(arguments, forName: UserDefaults.argumentDomain)
            let storage = GameStorages.shared.languageStorage
            let saved = expectation(description: "App language override saved")
            let saveSubscription = storage.set(model: ["ko", "en"]).sink { success in
                XCTAssertTrue(success)
                saved.fulfill()
            }
            wait(for: [saved], timeout: 1)

            XCTAssertEqual(defaults.persistentDomain(forName: appDomain)?["AppleLanguages"] as? [String], ["ko", "en"])
            XCTAssertEqual(storage.get(), ["ko", "en"])
            XCTAssertTrue(NSDictionary(dictionary: defaults.volatileDomain(forName: UserDefaults.argumentDomain)).isEqual(to: arguments))

            let cleared = expectation(description: "App language override cleared")
            let clearSubscription = storage.clear().sink { success in
                XCTAssertTrue(success)
                cleared.fulfill()
            }
            wait(for: [cleared], timeout: 1)

            XCTAssertNil(defaults.persistentDomain(forName: appDomain)?["AppleLanguages"])
            XCTAssertEqual(storage.get(), Locale.preferredLanguages)
            XCTAssertTrue(NSDictionary(dictionary: defaults.volatileDomain(forName: UserDefaults.argumentDomain)).isEqual(to: arguments))
            withExtendedLifetime((saveSubscription, clearSubscription)) {}
        }
    }

    private func withLanguageDefaults(_ body: (UserDefaults, String) -> Void) throws {
        let appDomain = try XCTUnwrap(Bundle.main.bundleIdentifier)
        let defaults = UserDefaults.standard
        let originalLanguages = defaults.persistentDomain(forName: appDomain)?["AppleLanguages"]
        let originalArguments = defaults.volatileDomain(forName: UserDefaults.argumentDomain)
        defer {
            if let originalLanguages {
                defaults.set(originalLanguages, forKey: "AppleLanguages")
            } else {
                defaults.removeObject(forKey: "AppleLanguages")
            }
            defaults.setVolatileDomain(originalArguments, forName: UserDefaults.argumentDomain)
        }
        body(defaults, appDomain)
    }
}
