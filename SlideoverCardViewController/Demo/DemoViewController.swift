//
//  FirstViewController.swift
//  SlideoverCardViewController
//
//  Created by Lukas Kukacka on 31/08/2019.
//  Copyright © 2019 Lukas Kukacka. All rights reserved.
//

import UIKit

class DemoViewController: SlideoverCardViewController {

    let headerViewController = TopViewController()
    let overlayViewController = BottomViewController()

    private var didAppearBefore: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Slideover card demo"
        self.tabBarItem.title = "Demo"

        self.topViewController = self.headerViewController
        self.bottomViewController = self.overlayViewController
        self.dragHandleView = self.overlayViewController.dragHandle

        self.view.backgroundColor = self.headerViewController.view.backgroundColor

        let topTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(topTapped))
        self.headerViewController.view.addGestureRecognizer(topTapRecognizer)

        let bottomTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(bottomTapped))
        self.overlayViewController.view.addGestureRecognizer(bottomTapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !self.didAppearBefore {
            self.expandTop(animated: false)
            self.didAppearBefore = true
        }
    }

    @objc
    func topTapped() {
        self.expandTop(animated: true)
    }

    @objc
    func bottomTapped() {
        self.expandBottom(animated: true)
    }
}

