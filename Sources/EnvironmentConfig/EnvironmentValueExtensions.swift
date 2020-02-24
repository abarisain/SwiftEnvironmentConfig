// Stdlib and Foundation extensions, allowing a couple of types to be
// initializable from string environment variables

extension String: EnvironmentValueInitializable {
    public static func from(envValue: String) -> Any? {
        envValue
    }
}

extension Bool: EnvironmentValueInitializable {
    public static func from(envValue: String) -> Any? {
        if envValue == "1" || envValue.caseInsensitiveCompare("true") == .orderedSame {
            return true
        }
        if envValue == "0" || envValue.caseInsensitiveCompare("false") == .orderedSame {
            return false
        }
        return nil
    }
}

extension FixedWidthInteger where Self: EnvironmentValueInitializable {
    public static func from(envValue: String) -> Target? {
        Self(envValue) as? Target
    }
}

// Can't "extension FixedWidthInteger: EnvironmentValueInitializable {}" for some reason

extension Int: EnvironmentValueInitializable { public typealias Target = Int }
extension Int8: EnvironmentValueInitializable { public typealias Target = Int8 }
extension Int16: EnvironmentValueInitializable { public typealias Target = Int16 }
extension Int32: EnvironmentValueInitializable { public typealias Target = Int32 }
extension Int64: EnvironmentValueInitializable { public typealias Target = Int64 }

extension UInt: EnvironmentValueInitializable { public typealias Target = UInt }
extension UInt8: EnvironmentValueInitializable { public typealias Target = UInt8 }
extension UInt16: EnvironmentValueInitializable { public typealias Target = UInt16 }
extension UInt32: EnvironmentValueInitializable { public typealias Target = UInt32 }
extension UInt64: EnvironmentValueInitializable { public typealias Target = UInt64 }
