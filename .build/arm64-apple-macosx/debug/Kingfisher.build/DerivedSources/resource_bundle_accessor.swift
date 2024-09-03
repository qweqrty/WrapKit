import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("Kingfisher_Kingfisher.bundle").path
        let buildPath = "/Users/stanislavli/Work/WrapKit/.build/arm64-apple-macosx/debug/Kingfisher_Kingfisher.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}