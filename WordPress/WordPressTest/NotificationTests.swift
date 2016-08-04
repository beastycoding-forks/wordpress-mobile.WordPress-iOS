import Foundation
import XCTest
@testable import WordPress



/// Notifications Tests
///
class NotificationTests : XCTestCase {

    var contextManager: TestContextManager!

    override func setUp() {
        super.setUp()
        contextManager = TestContextManager()
    }

    override func tearDown() {
        super.tearDown()

        // Note: We'll force TestContextManager override reset, since, for (unknown reasons) the TestContextManager
        // might be retained more than expected, and it may break other core data based tests.
        ContextManager.overrideSharedInstance(nil)
    }
}


/// Tests
///
extension NotificationTests
{
    func testBadgeNotificationHasBadgeFlagSetToTrue() {
        let note = loadBadgeNotification()
        XCTAssertTrue(note.isBadge)
    }

    func testBadgeNotificationHasRegularFieldsSet() {
        let note = loadBadgeNotification()
        XCTAssertNotNil(note.type)
        XCTAssertNotNil(note.noticon)
        XCTAssertNotNil(note.timestampAsDate)
        XCTAssertNotNil(note.icon)
        XCTAssertNotNil(note.url)
    }

    func testBadgeNotificationContainsOneSubjectBlock() {
        let note = loadBadgeNotification()
        XCTAssertNotNil(note.subjectBlock)
        XCTAssertNotNil(note.subjectBlock!.text)
    }

    func testBadgeNotificationContainsOneImageBlockGroup() {
        let note = loadBadgeNotification()
        let group = note.blockGroupOfKind(.Image)
        XCTAssertNotNil(group)

        let imageBlock = group!.blocks.first
        XCTAssertNotNil(imageBlock)

        let media = imageBlock!.media.first
        XCTAssertNotNil(media)
        XCTAssertNotNil(media!.mediaURL)
    }

    func testLikeNotificationContainsOneSubjectBlock() {
        let note = loadLikeNotification()
        XCTAssertNotNil(note.subjectBlock)
        XCTAssertNotNil(note.subjectBlock!.text)
    }

    func testLikeNotificationContainsHeader() {
        let note = loadLikeNotification()
        let header = note.headerBlockGroup
        XCTAssertNotNil(header)

        let gravatarBlock = header!.blockOfType(.Image)
        XCTAssertNotNil(gravatarBlock!.text)

        let media = gravatarBlock!.media.first
        XCTAssertNotNil(media!.mediaURL)

        let snippetBlock = header!.blockOfType(.Text)
        XCTAssertNotNil(snippetBlock!.text)
    }

    func testLikeNotificationContainsUserBlocksInTheBody() {
        let note = loadLikeNotification()
        for group in note.bodyBlockGroups {
            XCTAssertTrue(group.type == .User)
        }
    }

    func testLikeNotificationContainsPostAndSiteID() {
        let note = loadLikeNotification()
        XCTAssertNotNil(note.metaSiteID)
        XCTAssertNotNil(note.metaPostID)
    }

    func testFollowerNotificationHasFollowFlagSetToTrue() {
        let note = loadFollowerNotification()
        XCTAssertTrue(note.isFollow)
    }

    func testFollowerNotificationContainsOneSubjectBlock() {
        let note = loadFollowerNotification()
        XCTAssertNotNil(note.subjectBlock)
        XCTAssertNotNil(note.subjectBlock!.text)
    }

    func testFollowerNotificationContainsSiteID() {
        let note = loadFollowerNotification()
        XCTAssertNotNil(note.metaSiteID)
    }

    func testFollowerNotificationContainsUserAndFooterBlocksInTheBody() {
        let note = loadFollowerNotification()

        // Note: Account for 'View All Followers'
        for group in note.bodyBlockGroups {
            XCTAssertTrue(group.type == .User || group.type == .Footer)
        }
    }

    func testFollowerNotificationContainsFooterBlockWithFollowRangeAtTheEnd() {
        let note = loadFollowerNotification()

        let lastGroup = note.bodyBlockGroups.last
        XCTAssertNotNil(lastGroup)
        XCTAssertTrue(lastGroup!.type == .Footer)

        let block = lastGroup!.blocks.first
        XCTAssertNotNil(block)
        XCTAssertNotNil(block!.text)
        XCTAssertNotNil(block!.ranges)

        let range = block!.ranges.first
        XCTAssertNotNil(range)
        XCTAssertEqual(range!.type, NoteRangeType.Follow)
    }

    func testCommentNotificationHasCommentFlagSetToTrue() {
        let note = loadCommentNotification()
        XCTAssertTrue(note.isComment)
    }

    func testCommentNotificationContainsSubjectWithSnippet() {
        let note = loadCommentNotification()

        XCTAssertNotNil(note.subjectBlock)
        XCTAssertNotNil(note.snippetBlock)
        XCTAssertNotNil(note.subjectBlock!.text)
        XCTAssertNotNil(note.snippetBlock!.text)
    }

    func testCommentNotificationContainsHeader() {
        let note = loadCommentNotification()

        let header = note.headerBlockGroup
        XCTAssertNotNil(header)

        let gravatarBlock = header!.blockOfType(.Image)
        XCTAssertNotNil(gravatarBlock)
        XCTAssertNotNil(gravatarBlock!.text)

        let media = gravatarBlock!.media.first
        XCTAssertNotNil(media)
        XCTAssertNotNil(media!.mediaURL)

        let snippetBlock = header!.blockOfType(.Text)
        XCTAssertNotNil(snippetBlock)
        XCTAssertNotNil(snippetBlock!.text)
    }

    func testCommentNotificationContainsCommentAndSiteID() {
        let note = loadCommentNotification()
        XCTAssertNotNil(note.metaSiteID)
        XCTAssertNotNil(note.metaCommentID)
    }

    func testFindingNotificationRangeSearchingByReplyCommentID() {
        let note = loadCommentNotification()
        XCTAssertNotNil(note.metaReplyID)

        let textBlock = note.blockGroupOfKind(.Footer)?.blockOfType(.Text)
        XCTAssertNotNil(textBlock)

        let replyID = note.metaReplyID
        XCTAssertNotNil(replyID)

        let replyRange = textBlock!.notificationRangeWithCommentId(replyID!)
        XCTAssertNotNil(replyRange)
    }
}



/// Helpers
///
extension NotificationTests
{
    var entityName: String {
        return Notification.classNameWithoutNamespaces()
    }

    func loadBadgeNotification() -> Notification {
        return contextManager.loadEntityNamed(entityName, withContentsOfFile: "notifications-badge.json") as! Notification
    }

    func loadLikeNotification() -> Notification {
        return contextManager.loadEntityNamed(entityName, withContentsOfFile: "notifications-like.json") as! Notification
    }

    func loadFollowerNotification() -> Notification {
        return contextManager.loadEntityNamed(entityName, withContentsOfFile: "notifications-new-follower.json") as! Notification
    }

    func loadCommentNotification() -> Notification {
        return contextManager.loadEntityNamed(entityName, withContentsOfFile: "notifications-replied-comment.json") as! Notification
    }
}
