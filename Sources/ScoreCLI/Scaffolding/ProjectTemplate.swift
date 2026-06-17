import ArgumentParser

// MARK: - ProjectTemplate

enum ProjectTemplate: String, ExpressibleByArgument, CaseIterable {
    case `default`
    case `static`
    case kitchenSink = "kitchen-sink"
}
