//
//  UIApplication+.swift
//  FSNotes iOS
//
//  Created by Oleksandr Glushchenko on 6/18/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import UIKit

extension UIApplication {
    func getTopController() -> UIViewController? {
        let presented = UIApplication.shared.windows[0].rootViewController?.presentedViewController
        
        if let child = presented?.childViewControllers, child.count > 0 {
            return child.first
        }
        
        return presented
    }
}
