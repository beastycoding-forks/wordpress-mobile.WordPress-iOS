import UIKit

final class IntentCell: UITableViewCell, ModelSettableCell {
    var borders = [UIView]()
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var emojiContainer: UIView!
    @IBOutlet weak var emoji: UILabel!

    var model: SiteIntentVertical? {
        didSet {
            title.text = model?.localizedTitle
            emoji.text = model?.emoji
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        selectedBackgroundView?.backgroundColor = .clear

        accessibilityTraits = .button
        accessibilityHint = NSLocalizedString("Selects this topic as the intent for your site.",
                                              comment: "Accessibility hint for a topic in the Site Creation intents view.")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryType = .disclosureIndicator
        emojiContainer.layer.cornerRadius = emojiContainer.layer.frame.width / 2
    }

    override func prepareForReuse() {
        title.text = nil
        emoji.text = nil
    }
}
