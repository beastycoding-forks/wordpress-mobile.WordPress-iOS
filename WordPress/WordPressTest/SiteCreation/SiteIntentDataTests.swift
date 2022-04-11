import XCTest
@testable import WordPress

class SiteIntentDataTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Tests that a single vertical is returned when there's an exact match
    func testExactFiltering() throws {
        // given
        let foodSearchTerm = "food"
        let expectedFoodVertical = SiteIntentVertical(
            slug: "food",
            localizedTitle: "Food",
            emoji: "🍔",
            isDefault: true,
            isCustom: false
        )

        // when
        let foodSearchResult = SiteIntentData.filterVerticals(with: foodSearchTerm)

        // expect
        XCTAssertEqual(foodSearchResult.count, 1)
        XCTAssertEqual(foodSearchResult[0], expectedFoodVertical)
    }

    /// Tests that a custom vertical is inserted when there isn't an exact match
    func testCustomFiltering() throws {
        // given
        let fooSearchTerm = "foo"
        let expectedCustomResult = SiteIntentVertical(
            slug: "foo",
            localizedTitle: "foo",
            emoji: "＋",
            isDefault: false,
            isCustom: true
        )
        let expectedFoodVertical = SiteIntentVertical(
            slug: "food",
            localizedTitle: "Food",
            emoji: "🍔",
            isDefault: true,
            isCustom: false
        )

        // when
        let fooSearchResult = SiteIntentData.filterVerticals(with: fooSearchTerm)

        // expect
        XCTAssertEqual(fooSearchResult.count, 2)
        XCTAssertEqual(fooSearchResult[0], expectedCustomResult)
        XCTAssertEqual(fooSearchResult[1], expectedFoodVertical)
    }


    /// Tests that the output isn't changed when whitespace is searched
    func testWhiteSpaceFiltering() throws {
        // given
        let whitespaceSearchTerm = " "

        // when
        let emptyStringResult = SiteIntentData.filterVerticals(with: "")
        let whitespaceSearchResult = SiteIntentData.filterVerticals(with: whitespaceSearchTerm)

        // expect
        XCTAssertEqual(whitespaceSearchResult, emptyStringResult)
    }

    /// Tests that default verticals are on top of the non-default verticals as this affects output ordering
    func testDefaultsOnTop() throws {
        // given
        let defaultVerticals = SiteIntentData.allVerticals.filter { $0.isDefault == true }
        let nonDefaultVerticals = SiteIntentData.allVerticals.filter { $0.isDefault == false }

        // when
        let allVerticals = (defaultVerticals + nonDefaultVerticals)

        // expect
        XCTAssertEqual(allVerticals, SiteIntentData.allVerticals)
    }

    /// Tests that the defaultVerticals properties returns default verticals
    func testDefaultVerticals() throws {
        // given
        let defaultVerticals = SiteIntentData.defaultVerticals

        // when
        let nilNonDefault = defaultVerticals.first(where: { $0.isDefault == false })

        // expect
        XCTAssertNil(nilNonDefault)
    }

}
