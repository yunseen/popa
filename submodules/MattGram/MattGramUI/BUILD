load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "MattGramUI",
    module_name = "MattGramUI",
    srcs = glob(["Sources/**/*.swift"]),
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/AsyncDisplayKit:AsyncDisplayKit",
        "//submodules/Display:Display",
        "//submodules/TelegramCore:TelegramCore",
        "//submodules/TelegramPresentationData:TelegramPresentationData",
        "//submodules/AccountContext:AccountContext",
        "//submodules/ItemListUI:ItemListUI",
        "//submodules/PresentationDataUtils:PresentationDataUtils",
        "//submodules/MattGram/MGSettings:MGSettings",
    ],
    visibility = ["//visibility:public"],
)
