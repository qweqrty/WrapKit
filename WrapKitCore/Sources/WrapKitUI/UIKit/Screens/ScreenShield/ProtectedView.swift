
import UIKit

open class ProtectedView: UIView {
    public let protectedContentView = UIView()

    private let secureTextField = UITextField()
    private var isInstallingInternalViews = false
    private var didSetupHierarchy = false

    private var willResignActiveObserver: NSObjectProtocol?
    private var didEnterBackgroundObserver: NSObjectProtocol?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit { stopObserving() }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        window != nil ? startObserving() : stopObserving()
    }

    open override func addSubview(_ view: UIView) {
        guard didSetupHierarchy, !isInstallingInternalViews,
              view !== secureTextField, view !== protectedContentView else {
            super.addSubview(view); return
        }
        protectedContentView.addSubview(view)
    }

    open override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if subview === protectedContentView { installProtectedHierarchyIfNeeded() }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let converted = protectedContentView.convert(point, from: self)
        return protectedContentView.hitTest(converted, with: event) ?? super.hitTest(point, with: event)
    }

    private func commonInit() {
        backgroundColor = .clear
        installProtectedHierarchyIfNeeded()
    }

    private func installProtectedHierarchyIfNeeded() {
        guard !didSetupHierarchy else { return }

        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        secureTextField.backgroundColor = .clear
        secureTextField.textColor = .clear
        secureTextField.tintColor = .clear
        secureTextField.isSecureTextEntry = true
        secureTextField.isUserInteractionEnabled = false
        secureTextField.clipsToBounds = true

        protectedContentView.translatesAutoresizingMaskIntoConstraints = false
        protectedContentView.backgroundColor = .clear
        protectedContentView.clipsToBounds = true

        isInstallingInternalViews = true
        super.addSubview(secureTextField)
        isInstallingInternalViews = false

        NSLayoutConstraint.activate([
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        guard let secureContainer = resolveSecureContainer(in: secureTextField) else {
            isInstallingInternalViews = true
            super.addSubview(protectedContentView)
            isInstallingInternalViews = false
            NSLayoutConstraint.activate([
                protectedContentView.topAnchor.constraint(equalTo: topAnchor),
                protectedContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                protectedContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                protectedContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            didSetupHierarchy = true
            return
        }

        secureContainer.isUserInteractionEnabled = true
        secureContainer.backgroundColor = .clear

        secureContainer.addSubview(protectedContentView)
        NSLayoutConstraint.activate([
            protectedContentView.topAnchor.constraint(equalTo: secureContainer.topAnchor),
            protectedContentView.leadingAnchor.constraint(equalTo: secureContainer.leadingAnchor),
            protectedContentView.trailingAnchor.constraint(equalTo: secureContainer.trailingAnchor),
            protectedContentView.bottomAnchor.constraint(equalTo: secureContainer.bottomAnchor)
        ])

        didSetupHierarchy = true
    }

    private func resolveSecureContainer(in textField: UITextField) -> UIView? {
        if let canvas = textField.subviews.first(where: { String(describing: type(of: $0)).contains("LayoutCanvasView") }) {
            return canvas
        }
        for subview in textField.subviews {
            if let nested = subview.subviews.first(where: { String(describing: type(of: $0)).contains("LayoutCanvasView") }) {
                return nested
            }
        }
        return textField.subviews.first
    }

    private func startObserving() {
        guard willResignActiveObserver == nil else { return }

        willResignActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.setNeedsLayout() }

        didEnterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.setNeedsLayout() }
    }

    private func stopObserving() {
        let center = NotificationCenter.default
        if let willResignActiveObserver { center.removeObserver(willResignActiveObserver) }
        if let didEnterBackgroundObserver { center.removeObserver(didEnterBackgroundObserver) }
        willResignActiveObserver = nil
        didEnterBackgroundObserver = nil
    }
}
