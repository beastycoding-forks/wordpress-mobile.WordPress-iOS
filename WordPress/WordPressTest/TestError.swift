// There must be a way to make this as an Error extension.
// However, when I try to do so I get the following errors.
//
// Usage: .testError()
// Error: Contextual member reference to static method 'testError(description:domain:code:)' requires 'Self' constraint in the protocol extension
//
// Usage: Error.testError()
// Error: Static member 'testError' cannot be used on protocol metatype '(any Error).Type'
//
// In the meantime, we can call this via NSError.testInstance() in the tests.
extension Error {

    static func testError(
        description: String = "A test error",
        domain: String = "org.wordpress.unit-tests",
        code: Int = 1
    ) -> Self {
        // This would be discouraged if it wasn't for the facts that we know that NSError converts to Error.
        NSError.testInstance(description: description, domain: domain, code: code) as! Self
    }
}

extension NSError {

    static func testInstance(
        description: String = "A test error",
        domain: String = "org.wordpress.unit-tests",
        code: Int = 1
    ) -> NSError {
        .init(code: code, domain: domain, description: description)
    }
}

extension NSError {

    convenience init(
        code: Int,
        domain: String,
        description: String
    ) {
        self.init(
            domain: domain,
            code: code,
            userInfo: [
                NSLocalizedDescriptionKey: description
            ]
        )
    }
}
