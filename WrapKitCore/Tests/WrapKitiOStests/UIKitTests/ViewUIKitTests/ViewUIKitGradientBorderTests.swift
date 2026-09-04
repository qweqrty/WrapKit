import UIKit
import WrapKit
import XCTest

final class ViewUIKitGradientBorderTests: XCTestCase {
    func test_applyCornerStyle_doesNotInvalidateLayoutWhenStyleIsUnchanged() {
        let sut = LayoutTrackingView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

        sut.applyCornerStyle(.fixed(8))
        sut.setNeedsLayoutCallCount = 0
        sut.applyCornerStyle(.fixed(8))

        XCTAssertEqual(sut.setNeedsLayoutCallCount, 0)
    }

    func test_gradientBorder_maskIsOpaqueAndKeepsConfiguredCorners() throws {
        let sut = ViewUIKit(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        defer { sut.animations = [] }

        sut.applyCornerStyle(.corners(.init(topLeft: 8)))
        sut.animations = [.gradientBorder([.systemRed, .systemBlue])]
        sut.layoutIfNeeded()

        let gradient = try gradientBorderLayer(in: sut)
        let mask = try XCTUnwrap(gradient.mask)

        XCTAssertEqual(mask.borderColor?.alpha, 1)
        XCTAssertEqual(mask.maskedCorners, [.layerMinXMinYCorner])
    }

    func test_gradientBorder_afterNoneDoesNotReusePreviousCorners() throws {
        let sut = ViewUIKit(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        defer { sut.animations = [] }

        sut.applyCornerStyle(.fixed(8))
        sut.gradientBackgroundColor(width: 2, colors: [.systemRed, .systemBlue])
        XCTAssertEqual(sut.layer.cornerRadius, 8)
        sut.applyCornerStyle(.none)
        sut.animations = [.gradientBorder([.systemRed, .systemBlue])]
        sut.layoutIfNeeded()

        let gradient = try gradientBorderLayer(in: sut)
        let mask = try XCTUnwrap(gradient.mask)

        XCTAssertEqual(sut.cornerRadiusValue(), .zero)
        XCTAssertEqual(sut.maskedCornersValue(), [])
        XCTAssertEqual(mask.cornerRadius, .zero)
    }

    func test_gradientBorder_updatesMaskAfterCornerStyleChanges() throws {
        let sut = ViewUIKit(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        defer { sut.animations = [] }

        sut.animations = [.gradientBorder([.systemRed, .systemBlue])]
        sut.layoutIfNeeded()

        sut.applyCornerStyle(.fixed(8))
        sut.layoutIfNeeded()
        let roundedMask = try XCTUnwrap(gradientBorderLayer(in: sut).mask)
        XCTAssertEqual(roundedMask.cornerRadius, 8)

        sut.applyCornerStyle(.none)
        sut.layoutIfNeeded()
        let squareMask = try XCTUnwrap(gradientBorderLayer(in: sut).mask)
        XCTAssertEqual(squareMask.cornerRadius, .zero)
        XCTAssertEqual(squareMask.maskedCorners, [])
    }

    func test_gradientBorder_preservesDifferentCornerRadiiOnIOS26() throws {
        guard #available(iOS 26.0, *) else { return }
        let sut = ViewUIKit(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        defer { sut.animations = [] }
        sut.bounds.origin = CGPoint(x: 17, y: 11)

        sut.layer.cornerRadius = 8
        sut.layer.maskedCorners = [.layerMaxXMaxYCorner]
        sut.applyCornerStyle(.corners(.init(topLeft: 4, topRight: 12)))
        sut.animations = [.gradientBorder([.systemRed, .systemBlue])]
        sut.layoutIfNeeded()

        let gradient = try gradientBorderLayer(in: sut)
        let mask = try XCTUnwrap(gradient.mask as? CAShapeLayer)
        let pathPoints = try XCTUnwrap(mask.path).elementEndPoints
        guard pathPoints.count >= 2 else {
            return XCTFail("Expected the mask path to contain its initial edge")
        }

        XCTAssertEqual(sut.layer.cornerRadius, .zero)
        XCTAssertEqual(sut.layer.maskedCorners, .allCorners)
        XCTAssertEqual(gradient.frame, sut.bounds)
        XCTAssertEqual(mask.frame, gradient.bounds)
        XCTAssertEqual(pathPoints[0].x, 4, accuracy: 0.001)
        XCTAssertEqual(pathPoints[0].y, 1, accuracy: 0.001)
        XCTAssertEqual(pathPoints[1].x, 88, accuracy: 0.001)
        XCTAssertEqual(pathPoints[1].y, 1, accuracy: 0.001)
    }

    func test_gradientBorder_fixedZeroClearsLegacyCornerRadiusOnIOS26() throws {
        guard #available(iOS 26.0, *) else { return }
        let sut = ViewUIKit(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        defer { sut.animations = [] }

        sut.layer.cornerRadius = 8
        sut.layer.maskedCorners = [.layerMinXMinYCorner]
        sut.applyCornerStyle(.fixed(.zero))
        sut.animations = [.gradientBorder([.systemRed, .systemBlue])]
        sut.layoutIfNeeded()

        let gradient = try gradientBorderLayer(in: sut)
        let mask = try XCTUnwrap(gradient.mask)

        XCTAssertEqual(sut.layer.cornerRadius, .zero)
        XCTAssertEqual(sut.cornerRadiusValue(), .zero)
        XCTAssertEqual(sut.maskedCornersValue(), [])
        XCTAssertEqual(mask.cornerRadius, .zero)
    }

    private func gradientBorderLayer(in view: UIView) throws -> CAGradientLayer {
        try XCTUnwrap(
            view.layer.sublayers?
                .compactMap { $0 as? CAGradientLayer }
                .first { $0.type == .conic }
        )
    }
}

private final class LayoutTrackingView: UIView {
    var setNeedsLayoutCallCount = 0

    override func setNeedsLayout() {
        setNeedsLayoutCallCount += 1
        super.setNeedsLayout()
    }
}

private extension CGPath {
    var elementEndPoints: [CGPoint] {
        var result: [CGPoint] = []
        applyWithBlock { elementPointer in
            let element = elementPointer.pointee
            switch element.type {
            case .moveToPoint, .addLineToPoint:
                result.append(element.points[0])
            case .addQuadCurveToPoint:
                result.append(element.points[1])
            case .addCurveToPoint:
                result.append(element.points[2])
            case .closeSubpath:
                break
            @unknown default:
                break
            }
        }
        return result
    }
}
