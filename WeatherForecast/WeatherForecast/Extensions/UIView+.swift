//
//  UIView+.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/15.
//

import UIKit

extension UIView {
    func addSubViews(_ views: UIView..., autoResizing: Bool = false) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = autoResizing
            self.addSubview(view)
        }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: UIView..., autoResizing: Bool = false) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = autoResizing
            self.addArrangedSubview(view)
        }
    }
}
