import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "Wrapkit",
    projects: [
        swiftUIApp.path,
        wrapKit.path,
        wrapKitGame.path,
        gameApp.path
    ]
)
