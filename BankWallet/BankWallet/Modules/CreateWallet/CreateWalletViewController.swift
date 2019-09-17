import UIKit
import SectionsTableView

class CreateWalletViewController: WalletViewController {
    private let delegate: ICreateWalletViewDelegate

    private let tableView = SectionsTableView(style: .grouped)
    private var viewItems = [CreateWalletViewItem]()

    init(delegate: ICreateWalletViewDelegate) {
        self.delegate = delegate

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "create_wallet.title".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "create_wallet.create_button".localized, style: .done, target: self, action: #selector(onTapCreate))

        tableView.registerCell(forClass: CreateWalletCell.self)
        tableView.registerHeaderFooter(forClass: TopDescriptionView.self)
        tableView.sectionDataSource = self

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        delegate.viewDidLoad()
        tableView.buildSections()
    }

    @objc func onTapCreate() {
        delegate.didTapCreateButton()
    }

}

extension CreateWalletViewController: SectionsDataSource {

    func buildSections() -> [SectionProtocol] {
        let descriptionText = "create_wallet.description".localized

        let headerState: ViewState<TopDescriptionView> = .cellType(hash: "top_description", binder: { view in
            view.bind(text: descriptionText)
        }, dynamicHeight: { [unowned self] _ in
            TopDescriptionView.height(containerWidth: self.tableView.bounds.width, text: descriptionText)
        })

        return [
            Section(
                    id: "coins",
                    headerState: headerState,
                    footerState: .margin(height: AppTheme.margin8x),
                    rows: viewItems.enumerated().map { (index, viewItem) in
                        Row<CreateWalletCell>(
                                id: "coin_\(viewItem.code)",
                                hash: "coin_\(viewItem.selected)",
                                height: AppTheme.heightDoubleLineCell,
                                autoDeselect: true,
                                bind: { [unowned self] cell, _ in
                                    cell.bind(viewItem: viewItem, last: index == self.viewItems.count - 1)
                                },
                                action: { [weak self] _ in
                                    self?.delegate.didTap(index: index)
                                }
                        )
                    }
            )
        ]
    }

}

extension CreateWalletViewController: ICreateWalletView {

    func set(viewItems: [CreateWalletViewItem]) {
        self.viewItems = viewItems
        tableView.reload(animated: true)
    }

    func show(error: Error) {
        HudHelper.instance.showError(title: error.localizedDescription)
    }

}
