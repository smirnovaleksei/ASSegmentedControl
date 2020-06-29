//
//  ViewController.swift
//  ASSegmentedControl
//
//  Created by Aleksei Smirnov on 26.06.2020.
//  Copyright © 2020 Aleksei Smirnov. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Private Properties

    private let segmentedControl = ASSegmentedControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 44))

    private let leftItem: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = "Text 1"
        label.textAlignment = .center
        return label
    }()

    private lazy var rightItem: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView(), takeAwayLabel, distanceLabel, UIView()])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.clipsToBounds = true
        return stackView
    }()

    private let takeAwayLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = "Навынос"
        label.textAlignment = .center
        return label
    }()

    private let distanceLabel: HidingLabel = {
        let label = HidingLabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "700000 m"
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray

        segmentedControl.center = view.center
        view.addSubview(segmentedControl)

        segmentedControl.configure(model: .init(items: [leftItem, rightItem]))
        segmentedControl.addTarget(self, action: #selector(didValueChanged(_:)), for: .valueChanged)
    }

    // MARK: - Private Methods

    @objc private func didValueChanged(_ control: ASSegmentedControl) {

        let currentIndex = control.selectedSegmentIndex

        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: [], animations: {
            self.distanceLabel.isHidden = currentIndex == 1
            self.rightItem.layoutIfNeeded()
        }, completion: nil)
    }

}

final fileprivate class HidingLabel: UILabel {

    override func layoutSubviews() {
        super.layoutSubviews()
        isHidden = bounds.size.width < intrinsicContentSize.width
    }
}
