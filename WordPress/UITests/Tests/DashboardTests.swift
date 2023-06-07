import UITestsFoundation
import XCTest

// These tests are Jetpack only.
class DashboardTests: XCTestCase {
    override func setUpWithError() throws {
        setUpTestSuite()

        try LoginFlow.login(
            siteUrl: WPUITestCredentials.testWPcomSiteAddress,
            email: WPUITestCredentials.testWPcomUserEmail,
            password: WPUITestCredentials.testWPcomPassword
        )
    }

    override func tearDownWithError() throws {
        takeScreenshotOfFailedTest()
        removeApp()
    }

    func testFreeToPaidCardNavigation() throws {
        try MySiteScreen()
            .scrollToFreeToPaidPlansCard()
            .verifyFreeToPaidPlansCard()
            .tapFreeToPaidPlansCard()
            .verifyDomainsSuggestionsScreenLoaded()
            .selectDomain()
            .goToPlanSelection()
            .verifyPlanSelectionScreenLoaded()
            .selectPlan()
            .purchase()
            .verifyDomainResultScreenLoaded()
            .dismissResultScreen()
    }

    func testPagesCardHeaderNavigation() throws {
        try MySiteScreen()
            .scrollToPagesCard()
            .verifyPagesCard()
            .verifyPagesCard(hasPage: "Blog")
            .verifyPagesCard(hasPage: "Shop")
            .verifyPagesCard(hasPage: "Cart")
            .tapPagesCardHeader()
            .verifyPagesScreenLoaded()
            .verifyPagesScreen(hasPage: "Blog")
            .verifyPagesScreen(hasPage: "Shop")
            .verifyPagesScreen(hasPage: "Cart")
    }

    func testActivityLogCardHeaderNavigation() throws {
        try MySiteScreen()
            .scrollToActivityLogCard()
            .verifyActivityLogCard()
            .verifyActivityLogCard(hasActivityPartial: "Enabled Jetpack Social")
            .verifyActivityLogCard(hasActivityPartial: "The Jetpack connection")
            .verifyActivityLogCard(hasActivityPartial: "This site is connected to")
            .tapActivityLogCardHeader()
            .verifyActivityLogScreenLoaded()
            .verifyActivityLogScreen(hasActivityPartial: "Enabled Jetpack Social")
            .verifyActivityLogScreen(hasActivityPartial: "The Jetpack connection")
            .verifyActivityLogScreen(hasActivityPartial: "This site is connected to")
    }
}
