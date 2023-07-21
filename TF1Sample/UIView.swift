//
//  UIView+Constraints.swift
//  LiveLikeSDK
//
//  Created by Heinrich Dahms on 2019-01-21.
//

import UIKit

extension UIView {
    func constraintsFill(to parentView: UIView, offset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            parentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: offset),
            parentView.topAnchor.constraint(equalTo: topAnchor, constant: -offset),
            parentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: offset),
            parentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -offset)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func fillConstraints(to view: UIView, offset: CGFloat = 0) -> [NSLayoutConstraint] {
        return [
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: offset),
            view.topAnchor.constraint(equalTo: topAnchor, constant: -offset),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: offset),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -offset)
        ]
    }
}
