import Foundation
import UIKit

enum OnboardingOption: String {
    case stats
    case writing
    case notifications
    case reader
    case showMeAround = "show_me_around"
    case skip
}

extension NSNotification.Name {
    static let onboardingPromptWasDismissed = NSNotification.Name(rawValue: "OnboardingPromptWasDismissed")
}

class OnboardingQuestionsCoordinator {
    weak var navigationController: UINavigationController?
    var onDismiss: ((_ selection: OnboardingOption) -> Void)?

    func dismiss(selection: OnboardingOption) {
        onDismiss?(selection)
    }

    func track(_ event: WPAnalyticsEvent, option: OnboardingOption? = nil) {
        guard let option = option else {
            WPAnalytics.track(event)
            return
        }

        let properties = ["item": option.rawValue]
        WPAnalytics.track(event, properties: properties)
    }
}

// MARK: - Questions View Handling
extension OnboardingQuestionsCoordinator {
    func questionsDisplayed() {
        track(.onboardingQuestionsDisplayed)
    }

    func questionsSkipped(option: OnboardingOption) {
        dismiss(selection: option)
        track(.onboardingQuestionsSkipped)
    }

    func didSelect(option: OnboardingOption) {
        guard option != .skip else {
            questionsSkipped(option: option)
            return
        }

        track(.onboardingQuestionsItemSelected, option: option)
        UserPersistentStoreFactory.instance().onboardingQuestionSelected = option

        // Check if notification's are already enabled
        // If they are just dismiss, if not then prompt
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] settings in
            DispatchQueue.main.async {
                guard settings.authorizationStatus == .notDetermined, let self = self else {
                    self?.dismiss(selection: option)
                    return
                }

                let controller = OnboardingEnableNotificationsViewController(with: self, option: option)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
    }
}

// MARK: - Notifications Handling
extension OnboardingQuestionsCoordinator {
    func notificationsDisplayed(option: OnboardingOption) {
        track(.onboardingEnableNotificationsDisplayed, option: option)
        UserPersistentStoreFactory.instance().onboardingNotificationsPromptDisplayed = true
    }

    func notificationsEnabledTapped(selection: OnboardingOption) {
        track(.onboardingEnableNotificationsEnableTapped, option: selection)

        InteractiveNotificationsManager.shared.requestAuthorization { authorized in
            DispatchQueue.main.async {
                self.dismiss(selection: selection)
            }
        }
    }

    func notificationsSkipped(selection: OnboardingOption) {
        track(.onboardingEnableNotificationsSkipped, option: selection)
        dismiss(selection: selection)
    }
}
