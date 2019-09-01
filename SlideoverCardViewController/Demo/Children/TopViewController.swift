//
//  TopViewController.swift
//  SlideoverCardViewController
//
//  Created by Lukas Kukacka on 31/08/2019.
//  Copyright © 2019 Lukas Kukacka. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.9, alpha: 1)

        let label = UILabel()
        label.text = "Slideover Card like in Stocks"
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)

        self.view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        let guide = self.view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: guide.topAnchor),
            label.leftAnchor.constraint(equalTo: guide.leftAnchor),
            label.rightAnchor.constraint(equalTo: guide.rightAnchor),
            label.bottomAnchor.constraint(greaterThanOrEqualTo: guide.bottomAnchor).withPriority(.defaultHigh),
            label.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0).withPriority(.defaultLow)
            ])
    }

}

extension TopViewController: SlideoverCardViewControllerChild {

    var collapsedHeight: CGFloat {
        return 100 + self.view.safeAreaInsets.top
    }
}
