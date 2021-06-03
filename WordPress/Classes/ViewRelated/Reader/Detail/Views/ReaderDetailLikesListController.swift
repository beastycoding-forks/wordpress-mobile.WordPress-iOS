import Foundation

class ReaderDetailLikesListController: UITableViewController, NoResultsViewHost {

    // MARK: - Properties
    private let post: ReaderPost
    private var likesListController: LikesListController?
    private var totalLikes = 0

    // MARK: - Init
    init(post: ReaderPost, totalLikes: Int) {
        self.post = post
        self.totalLikes = totalLikes
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View
    override func viewDidLoad() {
        configureViewTitle()
        configureTable()
        WPAnalytics.track(.likeListOpened, properties: ["list_type": "post", "source": "like_reader_list"])
    }

}

private extension ReaderDetailLikesListController {

    func configureViewTitle() {
        let titleFormat = totalLikes == 1 ? TitleFormats.singular : TitleFormats.plural
        navigationItem.title = String(format: titleFormat, totalLikes)
    }

    func configureTable() {
        tableView.register(LikeUserTableViewCell.defaultNib,
                           forCellReuseIdentifier: LikeUserTableViewCell.defaultReuseID)

        likesListController = LikesListController(tableView: tableView, post: post, delegate: self)
        tableView.delegate = likesListController
        tableView.dataSource = likesListController

        // Call refresh to ensure that the controller fetches the data.
        likesListController?.refresh()
    }

    func displayUserProfile(_ user: LikeUser, from indexPath: IndexPath) {
        let userProfileVC = UserProfileSheetViewController(user: user)
        userProfileVC.blogUrlPreviewedSource = "reader_like_list_user_profile"
        let bottomSheet = BottomSheetViewController(childViewController: userProfileVC)
        let sourceView = tableView.cellForRow(at: indexPath) ?? view
        bottomSheet.show(from: self, sourceView: sourceView)
        WPAnalytics.track(.userProfileSheetShown, properties: ["source": "like_reader_list"])
    }

    struct TitleFormats {
        static let singular = NSLocalizedString("%1$d Like",
                                                comment: "Singular format string for view title displaying the number of post likes. %1$d is the number of likes.")
        static let plural = NSLocalizedString("%1$d Likes",
                                              comment: "Plural format string for view title displaying the number of post likes. %1$d is the number of likes.")
    }

    struct NoResultsText {
        static let errorTitle = NSLocalizedString("Oops", comment: "Title for the view when there's an error loading notification likes.")
        static let errorSubtitle = NSLocalizedString("There was an error loading likes", comment: "Text displayed when there is a failure loading notification likes.")
    }
}

// MARK: - LikesListController Delegate
//
extension ReaderDetailLikesListController: LikesListControllerDelegate {

    func didSelectUser(_ user: LikeUser, at indexPath: IndexPath) {
        displayUserProfile(user, from: indexPath)
    }

    func showErrorView() {
        configureAndDisplayNoResults(on: tableView,
                                     title: NoResultsText.errorTitle,
                                     subtitle: NoResultsText.errorSubtitle,
                                     image: "wp-illustration-reader-empty")
    }

    func updatedTotalLikes(_ totalLikes: Int) {
        self.totalLikes = totalLikes
        configureViewTitle()
    }
}
