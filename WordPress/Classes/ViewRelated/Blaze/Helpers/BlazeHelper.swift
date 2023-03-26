import Foundation

@objcMembers final class BlazeHelper: NSObject {

    static func isBlazeFlagEnabled() -> Bool {
        guard AppConfiguration.isJetpack else {
            return false
        }
        return RemoteFeatureFlag.blaze.enabled()
    }

    static func shouldShowCard(for blog: Blog) -> Bool {
        guard isBlazeFlagEnabled() && blog.isBlazeApproved else {
            return false
        }

        guard let siteID = blog.dotComID?.stringValue else {
            return false
        }

        initializeBlazeCardSettingsIfNecessary(siteID: siteID)

        return UserPersistentStoreFactory.instance().blazeCardEnabledSettings[siteID] ?? false
    }

    static func hideBlazeCard(for blog: Blog?) {
        guard let blog,
              let siteID = blog.dotComID?.stringValue else {
            DDLogError("Blaze: error hiding blaze card.")
            return
        }
        let repository = UserPersistentStoreFactory.instance()
        var blazeCardEnabledSettings = repository.blazeCardEnabledSettings
        blazeCardEnabledSettings[siteID] = false
        repository.blazeCardEnabledSettings = blazeCardEnabledSettings
    }

    static func initializeBlazeCardSettingsIfNecessary(siteID: String) {
        let repository = UserPersistentStoreFactory.instance()
        var blazeCardEnabledSettings = repository.blazeCardEnabledSettings
        if blazeCardEnabledSettings[siteID] == nil {
            blazeCardEnabledSettings[siteID] = true
            repository.blazeCardEnabledSettings = blazeCardEnabledSettings
        }
    }
}
