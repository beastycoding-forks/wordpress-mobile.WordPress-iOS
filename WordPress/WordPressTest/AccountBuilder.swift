import Foundation

@testable import WordPress

/// Builds an Account for use with testing
///
@objc
class AccountBuilder: NSObject {
    private let context: NSManagedObjectContext
    private var account: WPAccount

    @objc
    init(_ context: NSManagedObjectContext) {
        self.context = context

        account = NSEntityDescription.insertNewObject(forEntityName: WPAccount.entityName(), into: context) as! WPAccount
        account.uuid = UUID().uuidString

        super.init()
    }

    @objc
    func with(id: Int64) -> AccountBuilder {
        account.userID = NSNumber(value: id)
        return self
    }

    func with(id: Int) -> AccountBuilder {
        return with(id: Int64(id))
    }

    @objc
    func with(uuid: String) -> AccountBuilder {
        account.uuid = uuid
        return self
    }

    @objc
    func with(username: String) -> AccountBuilder {
        account.username = username
        return self
    }

    @objc
    func with(email: String) -> AccountBuilder {
        account.email = email
        return self
    }

    @objc
    func with(blogs: [Blog]) -> AccountBuilder {
        account.blogs = Set(blogs)
        return self
    }

    @objc
    func with(authToken: String) -> AccountBuilder {
        account.authToken = authToken
        return self
    }

    @objc
    @discardableResult
    func build() -> WPAccount {
        account
    }
}
