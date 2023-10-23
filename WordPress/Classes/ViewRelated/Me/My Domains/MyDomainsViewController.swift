import UIKit
import Combine

final class MyDomainsViewController: UIViewController {
    enum Action: String {
        case addToSite
        case purchase
        case transfer

        var title: String {
            switch self {
            case .addToSite:
                return NSLocalizedString(
                    "domain.management.fab.add.domain.title",
                    value: "Add domain to site",
                    comment: "Domain Management FAB Add Domain title"
                )
            case .purchase:
                return NSLocalizedString(
                    "domain.management.fab.purchase.domain.title",
                    value: "Purchase domain only",
                    comment: "Domain Management FAB Purchase Domain title"
                )
            case .transfer:
                return NSLocalizedString(
                    "domain.management.fab.transfer.domain.title",
                    value: "Transfer domain(s)",
                    comment: "Domain Management FAB Transfer Domain title"
                )
            }
        }
    }

    // MARK: - Dependencies

    private let viewModel: ViewModel

    // MARK: - Views

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Observation

    private var cancellable = Set<AnyCancellable>()

    // MARK: - Init

    init(viewModel: ViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.title

        WPStyleGuide.configureColors(view: view, tableView: nil)
        navigationItem.rightBarButtonItem = .init(systemItem: .add)
        let addToSiteAction = menuAction(withTitle: Action.addToSite.title) { action in
            print("add to site")
        }
        let purchaseAction = menuAction(withTitle: Action.purchase.title) { action in
            print("purchase")
        }
        let transferAction = menuAction(withTitle: Action.transfer.title) { action in
            print("transfer")
        }

        let actions = [addToSiteAction, purchaseAction, transferAction]
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
        navigationItem.rightBarButtonItem?.menu = menu

        self.setupSubviews()
        self.observeState()
        self.viewModel.loadData()
    }

    private func setupSubviews() {
        // Setup search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = Strings.searchBar
        self.navigationItem.searchController = searchController

        // Setup tableView
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset.top = Layout.interRowSpacing
        self.tableView.sectionHeaderHeight = Layout.interRowSpacing / 2
        self.tableView.sectionFooterHeight = tableView.sectionHeaderHeight
        self.tableView.register(MyDomainsTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.myDomain)
        self.view.addSubview(tableView)
        self.view.pinSubviewToAllEdges(tableView)
    }

    private func observeState() {
        self.viewModel.$state.sink { [weak self] state in
            guard let self else {
                return
            }
            switch state {
            case .normal, .loading:
                self.tableView.reloadData()
            case .error:
                break
            case .empty:
                break
            }
        }.store(in: &cancellable)
    }

    private func menuAction(withTitle title: String, handler: UIActionHandler) -> UIAction {
        .init(
            title: title,
            image: nil,
            identifier: nil,
            discoverabilityTitle: nil,
            attributes: .init(),
            state: .off,
            handler: { (action) in
            // Perform action
        })
    }

    // MARK: - Types

    private enum Layout {
        static let interRowSpacing = Length.Padding.double
    }

    private enum CellIdentifiers {
        static let myDomain = String(describing: MyDomainsTableViewCell.self)
    }

    typealias ViewModel = MyDomainsViewModel<DomainListCard.ViewModel>
}

// MARK: - UITableViewDataSource

extension MyDomainsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfDomains
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let domain = viewModel.domain(atIndex: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.myDomain, for: indexPath) as! MyDomainsTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.update(with: domain, parent: self)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchControllerDelegate & UISearchBarDelegate

extension MyDomainsViewController: UISearchControllerDelegate, UISearchBarDelegate {

}
