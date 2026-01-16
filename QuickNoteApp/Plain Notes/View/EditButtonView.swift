



import UIKit

protocol EditButtonViewDelegate: AnyObject {
    func didTapEditButton()
}

final class EditButtonView: UIView {

    @IBOutlet private weak var editButton: UIButton!

    weak var delegate: EditButtonViewDelegate?

    private(set) var isExpanded = false

    private let themeColor = UIColor(hex: "#A6ABFF")

    override func awakeFromNib() {
        super.awakeFromNib()

        applyFilledStyle()
    }


    @IBAction func editButtonTapped(_ sender: UIButton) {
        delegate?.didTapEditButton()
    }

    func toggle() {
        isExpanded.toggle()
        isExpanded ? applyOutlinedStyle() : applyFilledStyle()
    }

    func reset() {
        isExpanded = false
        applyFilledStyle()
    }

    // MARK: - Styles

    private func applyFilledStyle() {
        backgroundColor = themeColor
        layer.borderWidth = 0
        editButton.tintColor = .black
    }

    private func applyOutlinedStyle() {
        backgroundColor = .white
        layer.borderWidth = 2
        layer.borderColor = themeColor.cgColor
        editButton.tintColor = .black
    }
}
