import XCTest
import Foundation
import WrapKit
import WrapKitTestUtils

final class CardViewOutputHashableTests: XCTestCase {
    
    // MARK: Struct Tests
    func test_CardViewPresentableModel_textStyled_attributes() {
        let attr1 = TextAttributes(
            text: "text",
            color: .brown, // NurAssets.Colors.Text.primary.color,
            font: .systemFont(ofSize: 22),
            textAlignment: .center,
            leadingImage: Image.strokedCheckmark, // NurAssets.Images.MyO.icDone.image,
            leadingImageBounds: CGRect(x: .zero, y: -3, width: 16, height: 16)
        )
        let data1 = CardViewPresentableModel(
            id: "tariffAutopayment",
            style: .common(
                hStacklayoutMargins: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 8),
                subTitleTextColor: .tertiaryLabel,
                hStackViewSpacing: 12,
                trailingImageLeadingSpacing: 0,
                secondaryTrailingImageLeadingSpacing: 0
            ),
            title: .text("title"),
            leadingImage: ImageViewPresentableModel.init(
                size: CGSize(width: 32, height: 32),
                image: .url(URL(string: "https://example.com"), URL(string: "https://example.com"))
            ),
            trailingImage: .init(image: .asset(.add)),
            subTitle: .textStyled(
                text: .attributes([attr1]),
                cornerStyle: .automatic,
                insets: .init(top: 2, leading: 8, bottom: 4, trailing: 8),
                backgroundColor: .secondarySystemBackground
            ),
            isGradientBorderEnabled: true
        )
        let attr2 = TextAttributes(
            text: "text",
            color: .brown, // NurAssets.Colors.Text.primary.color,
            font: .systemFont(ofSize: 22),
            textAlignment: .center,
            leadingImage: Image.strokedCheckmark, // NurAssets.Images.MyO.icDone.image,
            leadingImageBounds: CGRect(x: .zero, y: -3, width: 16, height: 16)
        )
        let data2 = CardViewPresentableModel(
            id: "tariffAutopayment",
            style: .common(
                hStacklayoutMargins: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 8),
                subTitleTextColor: .tertiaryLabel,
                hStackViewSpacing: 12,
                trailingImageLeadingSpacing: 0,
                secondaryTrailingImageLeadingSpacing: 0
            ),
            title: .text("title"),
            leadingImage: ImageViewPresentableModel.init(
                size: CGSize(width: 32, height: 32),
                image: .url(URL(string: "https://example.com"), URL(string: "https://example.com"))
            ),
            trailingImage: .init(image: .asset(.add)),
            subTitle: .textStyled(
                text: .attributes([attr2]),
                cornerStyle: .automatic,
                insets: .init(top: 2, leading: 8, bottom: 4, trailing: 8),
                backgroundColor: .secondarySystemBackground
            ),
            isGradientBorderEnabled: true
        )
        XCTAssertEqual(data1, data2)
    }
    
    func test_TextAttributes() {
        let attr1 = TextAttributes(
            text: "text",
            color: .brown, // NurAssets.Colors.Text.primary.color,
            font: .systemFont(ofSize: 22),
            textAlignment: .center,
            leadingImage: Image.strokedCheckmark, // NurAssets.Images.MyO.icDone.image,
            leadingImageBounds: CGRect(x: .zero, y: -3, width: 16, height: 16)
        )
        let attr2 = TextAttributes(
            text: "text",
            color: .brown, // NurAssets.Colors.Text.primary.color,
            font: .systemFont(ofSize: 22),
            textAlignment: .center,
            leadingImage: Image.strokedCheckmark, // NurAssets.Images.MyO.icDone.image,
            leadingImageBounds: CGRect(x: .zero, y: -3, width: 16, height: 16)
        )
        XCTAssertEqual(attr1, attr2)
        XCTAssertEqual([attr1], [attr2])
    }
}

fileprivate extension CardViewPresentableModel.Style {
    static func common(
        backgroundColor: Color = .systemBackground,
        vStacklayoutMargins: WrapKit.EdgeInsets = .zero,
        hStacklayoutMargins: WrapKit.EdgeInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12),
        cornerRadius: CGFloat = 12,
        roundedCorners: CACornerMask = .allCorners,
        titleKeyLabelFont: Font = .systemFont(ofSize: 3),
        titleKeyTextColor: Color = .darkText,
        titleValueLabelFont: Font = .systemFont(ofSize: 5),
        titleValueTextColor: Color = .lightText,
        subTitleTextColor: Color = .placeholderText,
        subtitleLabelNumberOfLines: Int = 1,
        hStackViewSpacing: CGFloat = 14,
        stackSpace: CGFloat = 4,
        titleKeyNumberOfLines: Int = 0,
        titleValueNumberOfLines: Int = 0,
        gradientBorderColors: [Color] = [.blue, .red, .green],
        trailingImageLeadingSpacing: CGFloat? = nil,
        secondaryTrailingImageLeadingSpacing: CGFloat? = nil
    ) -> CardViewPresentableModel.Style {
        .init(
            backgroundColor: backgroundColor,
            vStacklayoutMargins: vStacklayoutMargins,
            hStacklayoutMargins: hStacklayoutMargins,
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: .cyan,
            titleKeyTextColor: titleKeyTextColor,
            trailingTitleKeyTextColor: .green,
            titleValueTextColor: titleValueTextColor,
            subTitleTextColor: subTitleTextColor,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 3),
            titleKeyLabelFont: titleKeyLabelFont,
            trailingTitleKeyLabelFont: .systemFont(ofSize: 3),
            titleValueLabelFont: titleValueLabelFont,
            subTitleLabelFont: .systemFont(ofSize: 3),
            subtitleNumberOfLines: subtitleLabelNumberOfLines,
            cornerRadius: cornerRadius,
            roundedCorners: roundedCorners,
            stackSpace: stackSpace,
            hStackViewSpacing: hStackViewSpacing,
            titleKeyNumberOfLines: titleKeyNumberOfLines,
            titleValueNumberOfLines: titleValueNumberOfLines,
            gradientBorderColors: gradientBorderColors,
            trailingImageLeadingSpacing: trailingImageLeadingSpacing,
            secondaryTrailingImageLeadingSpacing: secondaryTrailingImageLeadingSpacing
        )
    }
}
