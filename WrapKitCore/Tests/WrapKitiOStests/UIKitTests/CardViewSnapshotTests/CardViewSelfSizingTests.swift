import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

extension CardViewSnapshotTests {
    func test_selfSizingRows_keepMultilineTitlesVisibleWithoutStretchingShortRow() {
        for priority in [UILayoutPriority(751), .required] {
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 370, height: 800))
            let stack = StackView(axis: .vertical, spacing: 0)
            container.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: container.topAnchor),
                stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])

            let models = [
                ("Абоненттик төлөм", "550 с/ай"),
                ("KG аймагы боюнча ылдамдык", "300 чейин Мбит/с"),
                ("ДҮЙНӨ аймагы боюнча ылдамдык", "300 чейин Мбит/с")
            ]
            let cards = models.map { title, subtitle in
                let card = CardView()
                card.display(model: .init(
                    style: makeDefaultStyle(
                        backgroundColor: .white,
                        vStacklayoutMargins: .zero,
                        hStacklayoutMargins: .init(top: 8, leading: 12, bottom: 8, trailing: 12),
                        hStackViewDistribution: .fill,
                        titleKeyTextColor: .black,
                        titleKeyLabelFont: .systemFont(ofSize: 18),
                        subTitleLabelFont: .systemFont(ofSize: 18),
                        cornerRadius: 0,
                        stackSpace: 0,
                        hStackViewSpacing: 14,
                        titleKeyNumberOfLines: 0,
                        borderColor: .clear,
                        borderWidth: 0
                    ),
                    title: .text(title),
                    leadingImage: .init(layout: .fixed(.init(width: 32, height: 32)), image: .asset(Image(systemName: "star.fill"))),
                    subTitle: .text(subtitle)
                ))
                card.subtitleLabel.setContentCompressionResistancePriority(priority, for: .horizontal)
                stack.addArrangedSubview(card)
                return card
            }

            container.layoutIfNeeded()
            container.layoutIfNeeded()
            let attachment = XCTAttachment(image: container.snapshot(for: .iPhone(style: .light)))
            attachment.name = "self_sizing_rows_priority_\(Int(priority.rawValue))"
            attachment.lifetime = .keepAlways
            add(attachment)

            for card in cards {
                let label = card.titleViews.keyLabel
                let expectedHeight = label.sizeThatFits(.init(width: label.bounds.width, height: .greatestFiniteMagnitude)).height
                XCTAssertGreaterThan(label.bounds.width, 0)
                XCTAssertGreaterThanOrEqual(label.bounds.height + 1, expectedHeight,
                    "\(label.text ?? ""): frame \(label.frame), needs \(expectedHeight), preferred width \(label.preferredMaxLayoutWidth), intrinsic \(label.intrinsicContentSize), card \(card.frame), priority \(priority.rawValue)")
            }
            XCTAssertLessThanOrEqual(cards[0].bounds.height, 49,
                "A short row should only need its 32-point icon and vertical insets; priority \(priority.rawValue)")
        }
    }

    func test_tableRows_keepAttributedTitlesAndDescriptionsInsideCell() {
        let content = [
            ("Роуминг", "Будьте на связи за границей с вашим номером – интернет, звонки и сообщения.", "Подключить"),
            ("Бесплатная регистрация в роуминге", "", "Подключить"),
            ("Пополни мой баланс в роуминге", "Попросите своих родных и знакомых пополнить ваш счёт", "Запросить"),
            ("SMS уведомления в роуминге", "Отправьте бесплатное SMS домой, находясь за рубежом!", "Подробнее")
        ]
        let models = content.map { title, description, action in
            CardViewPresentableModel(
                style: makeDefaultStyle(
                    backgroundColor: .white,
                    vStacklayoutMargins: .zero,
                    hStacklayoutMargins: .init(top: 12, leading: 12, bottom: 12, trailing: 12),
                    hStackViewDistribution: .fill,
                    titleKeyTextColor: .black,
                    titleValueTextColor: .darkGray,
                    subTitleTextColor: .systemBlue,
                    titleKeyLabelFont: .systemFont(ofSize: 18),
                    titleValueLabelFont: .systemFont(ofSize: 14),
                    subTitleLabelFont: .systemFont(ofSize: 18),
                    subtitleNumberOfLines: 1,
                    cornerRadius: 0,
                    stackSpace: 4,
                    hStackViewSpacing: 14,
                    borderColor: .clear,
                    borderWidth: 0
                ),
                title: .attributes([.init(text: title)]),
                subTitle: .attributes([.init(text: action, onTap: {})]),
                valueTitle: .attributes([.init(text: description)])
            )
        }
        let table = UITableView(frame: .init(x: 0, y: 0, width: 402, height: 900), style: .plain)
        let window = UIWindow(frame: table.frame)
        let controller = UIViewController()
        window.rootViewController = controller
        controller.view.addSubview(table)
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 44
        table.register(TableViewCell<CardView>.self, forCellReuseIdentifier: "card")
        let dataSource = SelfSizingCardDataSource(models: models)
        table.dataSource = dataSource
        table.reloadData()
        table.layoutIfNeeded()
        _ = table.snapshot(for: .iPhone(style: .light))
        let placeholderCells = Set(table.visibleCells.map(ObjectIdentifier.init))
        dataSource.isPlaceholder = false
        table.reloadData()
        table.layoutIfNeeded()

        let attachment = XCTAttachment(image: table.snapshot(for: .iPhone(style: .light)))
        attachment.name = "self_sizing_attributed_service_rows"
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertEqual(table.visibleCells.count, models.count)
        XCTAssertFalse(placeholderCells.isDisjoint(with: Set(table.visibleCells.map(ObjectIdentifier.init))),
            "The real models must exercise cells reused after the placeholder layout")
        for case let cell as TableViewCell<CardView> in table.visibleCells {
            let card = cell.mainContentView
            for label in [card.titleViews.keyLabel, card.titleViews.valueLabel] where !(label.text ?? "").isEmpty {
                let expectedHeight = label.sizeThatFits(.init(width: label.bounds.width, height: .greatestFiniteMagnitude)).height
                XCTAssertGreaterThanOrEqual(label.bounds.height + 1, expectedHeight,
                    "\(label.text ?? ""): frame \(label.frame), needs \(expectedHeight), preferred width \(label.preferredMaxLayoutWidth), cell \(cell.frame)")
                let frame = label.convert(label.bounds, to: card)
                XCTAssertGreaterThanOrEqual(frame.minY + 1, 12, "Title must stay inside the top row inset")
                XCTAssertLessThanOrEqual(frame.maxY, card.bounds.height - 11, "Description must stay inside the bottom row inset")
            }
        }
    }

}

private final class SelfSizingCardDataSource: NSObject, UITableViewDataSource {
    let models: [CardViewPresentableModel]
    var isPlaceholder = true

    init(models: [CardViewPresentableModel]) {
        self.models = models
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { models.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as? TableViewCell<CardView> else {
            XCTFail("Expected a registered CardView cell")
            return UITableViewCell()
        }
        cell.mainContentViewConstraints?.leading?.constant = 16
        cell.mainContentViewConstraints?.trailing?.constant = -16
        if isPlaceholder {
            cell.mainContentView.display(model: .init(
                style: models[indexPath.row].style,
                title: .text("                 "),
                valueTitle: .text(" ")
            ))
        } else {
            cell.mainContentView.display(model: models[indexPath.row])
        }
        return cell
    }
}
