import Foundation

public enum EnvironmentConfigError: Error {
    /// The environment variable is missing or could not be parsed in the wanted type
    case unparsableOrMissingValue(variableNames: [String], type: String)
}

extension EnvironmentConfigError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case let .unparsableOrMissingValue(variableNames, type):
                return "Missing or unparsable environment variable. Attempted names: [\(variableNames.joined(separator: ","))]. Wanted type: \(type)."
        }
    }
}

public struct EnvironmentConfig {
    private static func possibleEnvironmentKeys(forLabel label: String, prefix: String? = nil) -> [String] {
        // No need to upper/lower case, EnvField will do it.
        var keys: [String] = []
        let base: String
        if let prefix = prefix {
            // Automatically correct the prefix if it ends by _
            if prefix.hasSuffix("_") {
                base = prefix
            } else {
                base = prefix + "_"
            }
        } else {
            base = ""
        }

        keys.append(base + label)

        let snakeCaseLabel = label.convertToSnakeCase()
        if snakeCaseLabel != label {
            keys.append(base + snakeCaseLabel)
        }

        return keys
    }

    public static func load(_ target: Any, prefix: String? = nil) throws {
        let mirror = Mirror(reflecting: target)
        for child in mirror.children {
            if let label = child.label, let autoField = child.value as? AnyEnvField {
                if label.count <= 1 || !label.hasPrefix("_") {
                    // Invalid state: value cannot be a AnyEnvField as it is a property wrapper
                    // and wrapper properties are prefixed by _
                    // Note that I could not find any Swift documentation specifying this
                    // so it may be relying on an implementation detail
                    continue
                }
                var cleanLabel = label
                cleanLabel.removeFirst()
                try autoField.load(names: possibleEnvironmentKeys(forLabel: cleanLabel, prefix: prefix))
            }
        }
    }
}
