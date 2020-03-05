import XCTest
@testable import EnvironmentConfig

#if os(Linux)
import CwlPosixPreconditionTesting
#else
import CwlPreconditionTesting
#endif

final class EnvironmentConfigTests: XCTestCase {
    
    override func setUp() {
        setupEnv()
    }
    
    func setupEnv() {
        setenv("envconfig_string", "foo", 1)
        setenv("ENVCONFIG_STRING_UPPERCASE", "bar", 1)
        setenv("envconfig_integer", "2", 1)
    }
    
    func clearEnv() {
        unsetenv("envconfig_string")
        unsetenv("envconfig_integer")
        unsetenv("envconfig_missing")
    }
    
    func testReadEnv() {
        struct Test {
            @EnvField(name: "envconfig_string", defaultValue: "foobar")
            public var string: String
            
            @EnvField(name: "ENVCONFIG_STRING_UPPERCASE", defaultValue: "foobar")
            public var uppercaseString: String
            
            @EnvField(name: "envconfig_integer", defaultValue: 2)
            public var integer: Int
            
            @EnvField(name: "envconfig_missing", defaultValue: 3)
            public var fallback: Int
            
            @EnvField(name: "envconfig_missing", defaultValue: "foobar")
            public var strFallback: String
        }
        
        let test = Test()
        XCTAssertEqual("foo", test.string)
        XCTAssertEqual("bar", test.uppercaseString)
        XCTAssertEqual(2, test.integer)
        XCTAssertEqual(3, test.fallback)
        XCTAssertEqual("foobar", test.strFallback)
        
        let mirror = Mirror(reflecting: test)
        for child in mirror.children {
            print(child.label!)
        }
    }
    
    func testFatalMissing() {
        struct Test {
            @EnvField(name: "envconfig_missing")
            public var missing: Int
        }
        
        XCTAssertNotNil(catchBadInstruction {
            let _ = Test()
        })
    }
    
    func testOptionals() {
        struct Test {
            @EnvField(name: "envconfig_string", defaultValue: "foobar")
            public var string: String?
            
            @EnvField(name: "envconfig_integer", defaultValue: 2)
            public var integer: Int?
            
            @EnvField(name: "envconfig_missing", defaultValue: 3)
            public var fallback: Int?
            
            @EnvField(name: "envconfig_missing")
            public var missing: Int?
        }
        
        let test = Test()
        XCTAssertEqual("foo", test.string)
        XCTAssertEqual(2, test.integer)
        XCTAssertEqual(3, test.fallback)
        XCTAssertNil(test.missing)
    }
    
    func testImplicitKeys() throws {
        setenv("teststring", "test", 1)
        setenv("camel_case", "bar", 1)
        setenv("snake_case", "baz", 1)
        
        struct Test {
            @EnvField(name: "envconfig_integer", defaultValue: 3)
            public var integer: Int? // Test mixing up implicit and explicit names
            
            @EnvField()
            public var teststring: String?
            
            @EnvField()
            public var camelCase: String
            
            @EnvField()
            public var snake_case: String
            
            @EnvField(defaultValue: 3)
            public var envconfig_integer: Int?
            
            @EnvField(defaultValue: 3)
            public var missing: Int?
        }
        
        let test = Test()
        try EnvironmentConfig.load(test)
        XCTAssertEqual(2, test.integer)
        XCTAssertEqual("test", test.teststring)
        XCTAssertEqual("bar", test.camelCase)
        XCTAssertEqual("baz", test.snake_case)
        XCTAssertEqual(2, test.envconfig_integer)
        XCTAssertEqual(3, test.missing)
        
        unsetenv("teststring")
        unsetenv("camel_case")
        unsetenv("snake_case")
        
        struct PrefixTest {
            @EnvField()
            public var string: String
        }
        
        var prefixTest = PrefixTest()
        XCTAssertThrowsError(try EnvironmentConfig.load(prefixTest))
        try EnvironmentConfig.load(prefixTest, prefix: "envconfig")
        XCTAssertEqual("foo", prefixTest.string)
        
        // Test that a trailing _ in the prefix is ignored
        prefixTest = PrefixTest()
        try EnvironmentConfig.load(prefixTest, prefix: "envconfig_")
        XCTAssertEqual("foo", prefixTest.string)
    }
}
