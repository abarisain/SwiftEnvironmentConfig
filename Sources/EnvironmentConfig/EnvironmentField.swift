import Foundation

protocol AnyEnvField {
    func hasImplicitName() -> Bool
    func load(names: [String]) throws
}

@propertyWrapper
public class EnvField<T: EnvironmentValueInitializable>: AnyEnvField {
    private var initialized: Bool
    private var value: T!

    private static func fetch<T: EnvironmentValueInitializable>(names: [String], fallback: T?) -> T? {
        let env = ProcessInfo.processInfo.environment

        var allNameCases: [String] = []
        allNameCases.reserveCapacity(names.count * 3)
        for name in names {
            allNameCases.append(name)
            allNameCases.append(name.uppercased())
            allNameCases.append(name.lowercased())
        }

        var envValue: String?
        for name in allNameCases {
            envValue = env[name]
            if envValue != nil {
                break
            }
        }

        // A force cast is needed, because an optional can make a double optional
        // if T is an optional
        if let envValue = envValue, let parsedValue = T.from(envValue: envValue) as! T? {
            return parsedValue
        }
        return fallback
    }

    public init(defaultValue: T? = nil) {
        initialized = false
        // Use the backing value to store the fallback
        value = defaultValue
    }

    func load(names: [String]) throws {
        initialized = true
        guard let fetchedValue: T = EnvField<T>.fetch(names: names, fallback: value) else {
            throw EnvironmentConfigError.unparsableOrMissingValue(variableNames: names, type: String(describing: T.self))
        }
        value = fetchedValue
    }

    func hasImplicitName() -> Bool {
        initialized == false
    }

    public init(name: String, file: StaticString = #file, line: UInt = #line) {
        initialized = true
        // A non optional wrapped type without a fallback can crash by design
        guard let fetchedValue: T = EnvField<T>.fetch(names: [name], fallback: nil) else {
            fatalError("Environment variable '\(name)' is missing or could not be converted to the wanted type '\(T.self)'.", file: file, line: line)
        }
        value = fetchedValue
    }

    public init(name: String, defaultValue: T) {
        initialized = true
        value = EnvField<T>.fetch(names: [name], fallback: defaultValue)
    }

    public var wrappedValue: T {
        if !initialized {
            fatalError("Environment variables with no explicit name must be initialized using EnvironmentConfig.load() on their containing struct.")
        }
        return value
    }
}

extension EnvField where T: ExpressibleByNilLiteral {
    public convenience init(name: String, file _: StaticString = #file, line _: UInt = #line) {
        self.init(name: name, defaultValue: nil)
    }

    public convenience init(name: String, defaultValue: T = nil) {
        self.init(defaultValue: defaultValue)
        initialized = true
        value = EnvField<T>.fetch(names: [name], fallback: defaultValue)
    }
}

extension EnvField: CustomStringConvertible {
    public var description: String {
        get {
            if !initialized {
                return "EnvField: Uninitialized"
            }
            if let value = value {
                return "EnvField: " + String(describing: value)
            } else {
                return "EnvField: nil"
            }
        }
    }
}

extension Optional: EnvironmentValueInitializable where Wrapped: EnvironmentValueInitializable {
    public static func from(envValue: String) -> Any? {
        Wrapped.from(envValue: envValue) as? Wrapped
    }
}
