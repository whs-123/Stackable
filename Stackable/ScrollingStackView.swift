//
//  ScrollingStackView.swift
//  Stackable
//
//  Created by Jason Clark on 8/5/20.
//  Copyright © 2020 Rightpoint. All rights reserved.
//

import UIKit

/// A `UIStackView` in a `UIScrollView`, whose stackView height will prefer to be at least the size of the frame of the scrollview.
/// If content grows beyond the frame, will allow for scrolling.
open class ScrollingStackView: UIScrollView {

    open override var layoutMargins: UIEdgeInsets {
        set { contentView.layoutMargins = newValue }
        get { return contentView.layoutMargins }
    }

    /// All subviews should be added to `stackView` directly.
    public let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    override open func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl
            && !(view is UITextInput)
            && !(view is UISlider)
            && !(view is UISwitch) {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }
    
    @available(iOS 11.0, *)
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        topSafeAreaConstraint?.constant = safeAreaInsets.top
        bottomSafeAreaConstraint?.constant = safeAreaInsets.bottom
    }

    var topSafeAreaConstraint: NSLayoutConstraint?
    var bottomSafeAreaConstraint: NSLayoutConstraint?

    /// A container used to enforce that the stack content stays at least the height of the frame.
    private let contentView = UIView()
    
    public init() {
        super.init(frame: .zero)

        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        } else {
            
        }

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = false

        let margins: UIEdgeInsets
        if #available(iOS 11.0, *) {
            margins = safeAreaInsets
        } else {
            margins = layoutMargins
        }
        topSafeAreaConstraint = contentView.topAnchor.constraint(equalTo: topAnchor, constant: margins.top)
        topSafeAreaConstraint?.isActive = true

        bottomSafeAreaConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margins.bottom)
        bottomSafeAreaConstraint?.isActive = true

        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

                contentView.heightAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.heightAnchor),
                contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor),
                contentView.widthAnchor.constraint(equalTo: widthAnchor)
            ])
        }

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Stackable Convenience Accessors
public extension ScrollingStackView {
    
    /**
     Adds a `Stackable` item to the stackView.

     - Parameters:
        - stackable: Any object conforming to `Stackable`
     
     ```
     let stackView = ScrollingStackView()
     stackView.add("Hello World!")
     stackView.add(20)
     stackView.add(UIStackView.stackable.hairline)
     stackView.add(UIStackView.stackable.flexibleSpace)
     ```
     */
    func add(_ stackable: Stackable) {
        stackView.stackable.add(stackable)
    }
    
    /**
     Adds `Stackable` items to the stackView.

     - Parameters:
        - stackables: An array of `Stackable` elements. Does not need to be homogenous.
     
     ```
     let stackView = ScrollingStackView()
     let cells: [UIView] = ...
     stackView.add([
        "Hello World!",
        20,
        UIStackView.stackable.hairline,
        cells,
        UIStackView.stackable.flexibleSpace,
     ])
     ```
     */
    func add(_ stackables: [Stackable]) {
        stackView.stackable.add(stackables)
    }
    
}
