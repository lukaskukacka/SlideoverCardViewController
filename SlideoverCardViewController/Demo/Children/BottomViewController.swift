//
//  BottomViewController.swift
//  SlideoverCardViewController
//
//  Created by Lukas Kukacka on 31/08/2019.
//  Copyright © 2019 Lukas Kukacka. All rights reserved.
//

import UIKit

class BottomViewController: UIViewController {

    private struct Layout {
        static let dragHandleHeight: CGFloat = 30
        static let minHeight: CGFloat = 100
        static let maxHeight: CGFloat = 250
    }

    let dragHandle: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        let handle = UIView()
        handle.backgroundColor = UIColor(white: 0.8, alpha: 1)
        handle.layer.cornerRadius = 2
        view.addSubview(handle)

        handle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            handle.widthAnchor.constraint(equalToConstant: 40),
            handle.heightAnchor.constraint(equalToConstant: 4),
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])

        return view
    }()

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let heightSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = Float(Layout.minHeight)
        slider.maximumValue = Float(Layout.maxHeight)
        slider.value = slider.minimumValue
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 10
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layer.masksToBounds = true

        // Drag handle
        self.dragHandle.translatesAutoresizingMaskIntoConstraints = false
        self.dragHandle.setContentCompressionResistancePriority(.required, for: .vertical)
        self.view.addSubview(self.dragHandle)
        NSLayoutConstraint.activate([
            self.dragHandle.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.dragHandle.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.dragHandle.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.dragHandle.heightAnchor.constraint(equalToConstant: Layout.dragHandleHeight)
            ])

        // Container (from drag to bottom
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        self.view.addSubview(self.containerView)
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.dragHandle.bottomAnchor),
            self.containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).withPriority(.defaultHigh)
            ])


        // Bottom stack with title and slider for min height
        let titleLabel = UILabel()
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.text = "Bottom View Controller"

        self.heightSlider.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let minHeightStackView = UIStackView(arrangedSubviews: [
            self.makeHuggedLabel(text: "Collapsed Height"),
            self.makeHuggedLabel(text: "\(Int(self.heightSlider.minimumValue))"),
            self.heightSlider,
            self.makeHuggedLabel(text: "\(Int(self.heightSlider.maximumValue))")])
        minHeightStackView.axis = .horizontal
        minHeightStackView.spacing = 8
        minHeightStackView.setCustomSpacing(16, after: minHeightStackView.arrangedSubviews[0])

        let stackView = UIStackView(arrangedSubviews: [titleLabel, minHeightStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        self.containerView.addSubview(stackView)

        let guide = self.containerView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: guide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: guide.rightAnchor),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: guide.bottomAnchor)
            ])
    }

    private func makeHuggedLabel(text: String) -> UILabel {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.text = text
        return label
    }
}

extension BottomViewController: SlideoverCardViewControllerChild {

    var collapsedHeight: CGFloat {
        return CGFloat(self.heightSlider.value) + self.view.safeAreaInsets.bottom
    }
}
