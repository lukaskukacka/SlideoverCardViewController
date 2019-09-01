//
//  NSLayoutConstraint+Extensions.swift
//  SlideoverCardViewController
//
//  Created by Lukas Kukacka on 31/08/2019.
//  Copyright © 2019 Lukas Kukacka. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {


    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
