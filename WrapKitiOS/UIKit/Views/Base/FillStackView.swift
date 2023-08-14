//
//  FillStackView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class FillStackView: UIView {
    private var arrangedSubviews: [UIView] = []
    private var observations: [NSKeyValueObservation] = []
    private var customSpacings: [UIView: CGFloat] = [:]
    private var heights: [UIView: NSLayoutConstraint] = [:]
    private var dictionary: [UIView: (constraints: AnchoredConstraints?, spacing: CGFloat)] = [:]

    public var axis: NSLayoutConstraint.Axis = .vertical {
        didSet {
            layoutArrangedSubviews()
        }
    }

    public var spacing: CGFloat = 0 {
        didSet {
            layoutArrangedSubviews()
        }
    }

    public init(axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) {
        self.axis = axis
        self.spacing = spacing
        super.init(frame: .zero)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        observations.forEach { $0.invalidate() }
    }

    public func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
        customSpacings[view] = spacing
        layoutArrangedSubviews()
    }

    private func observeHiddenProperty(views: [UIView]) {
        for view in views {
            let observation = view.observe(\.isHidden, options: [.new]) { [weak self, weak view] (_, change) in
                guard let self = self, let view = view else { return }
                if view.isHidden {
                    arrangedSubviews.withPreviousAndNext.forEach { (prev, current, next) in
                        if current === view, let prev = prev, let next = next {
                            self.dictionary[next]?.constraints?.top?.isActive = false
                            next.anchor(
                                .top(prev.bottomAnchor)
                            )
                        }
                        
                    }
                    UIView.animate(withDuration: 5) {
                        self.layoutIfNeeded()
                    }
                } else {
                    self.layoutArrangedSubviews()
                    UIView.animate(withDuration: 5) {
                        self.layoutIfNeeded()
                    }
                }
            }
            observations.append(observation)
        }
    }
    
    public func addArrangedSubview(_ view: UIView) {
        observations.forEach { $0.invalidate() }
        arrangedSubviews.append(view)
        observeHiddenProperty(views: arrangedSubviews)
        layoutArrangedSubviews()
    }
    
    private func layoutArrangedSubviews() {
        arrangedSubviews.forEach {
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
        dictionary.removeAll()
        for (previousView, view, nextView) in arrangedSubviews.withPreviousAndNext {
            addSubview(view)

            var anchors = [Anchor]()
            if axis == .horizontal {
                anchors.append(Anchor.top(topAnchor))
                anchors.append(Anchor.bottom(bottomAnchor))
            } else {
                anchors.append(Anchor.leading(leadingAnchor))
                anchors.append(Anchor.trailing(trailingAnchor))
            }

            if let previousView = previousView {
                let spacing = customSpacings[previousView] ?? spacing
                if axis == .horizontal {
                    anchors.append(Anchor.leading(previousView.trailingAnchor, constant: spacing))
                } else {
                    anchors.append(Anchor.top(previousView.bottomAnchor, constant: spacing))
                }
            } else {
                if axis == .horizontal {
                    anchors.append(Anchor.leading(leadingAnchor))
                } else {
                    anchors.append(Anchor.top(topAnchor))
                }
            }
            
            if nextView == nil {
                if axis == .horizontal {
                    anchors.append(Anchor.trailing(trailingAnchor))
                } else {
                    anchors.append(Anchor.bottom(bottomAnchor))
                }
            }
            dictionary[view] = (constraints: view.anchor(anchors: anchors), spacing: spacing)
        }
    }
}

extension UIView {
    func heightConstraint() -> NSLayoutConstraint? {
        return constraints.first(where: { $0.firstAttribute == .height && $0.secondItem == nil })
    }
}
#endif
