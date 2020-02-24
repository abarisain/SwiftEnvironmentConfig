/// A type that can be initialized from an environment string
public protocol EnvironmentValueInitializable {
    associatedtype Target
    /// Create an instance of this value using the given environment value
    /// - Parameter envValue environment variable value
    static func from(envValue: String) -> Target?
}
