//
//  ButtonDoneRight.swift
//  Jobbird
//
//  Created by Tiziano Coroneo on 29/05/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

@IBDesignable
open class ButtonDoneRight: UIButton {
    
    /// Color of the background of the button when it is enabled.
    @IBInspectable open var fillColor: UIColor = .white {
        didSet {
            if self.isEnabled {
                shapeLayer.fillColor = fillColor.cgColor
            }
        }
    }

    /// Color of the background of the button when it is NOT enabled.
    @IBInspectable open var inactiveFillColor: UIColor = .lightGray {
        didSet {
            if !self.isEnabled {
                shapeLayer.fillColor = fillColor.cgColor
            }
        }
    }

    @IBInspectable open var fillImage: UIImage? {
        didSet {
            self.imageLayer.contents = self.fillImage?.cgImage
        }
    }

    @IBInspectable open var numberOfLines: Int = 0 {
        didSet {
            titleLabel?.numberOfLines = numberOfLines
        }
    }

    /// Color of the title of the button when it is NOT enabled.
    @IBInspectable open var inactiveTextColor: UIColor = .darkGray {
        didSet {
            self.setTitleColor(inactiveTextColor, for: .disabled)
        }
    }
    
    @IBInspectable open var minimumLeftMargin: CGFloat = 10 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var minimumRightMargin: CGFloat = 10 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var minimumTopMargin: CGFloat = 5 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var minimumBottomMargin: CGFloat = 5 {
        didSet { setNeedsLayout() }
    }

    /// Corner radius of the button, using `UIBezierPath` to get a smoother curvature.
    @IBInspectable open var cornerRadius: CGFloat = 15 {
        didSet { setNeedsLayout() }
    }

    /// Color of the border of the button.
    @IBInspectable open var borderColor: UIColor = .clear {
        didSet { shapeLayer.strokeColor = borderColor.cgColor }
    }

    /// Width of the border of the button.
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet { shapeLayer.lineWidth = borderWidth }
    }

    /// Extra translation of the shadow of the button on the X axis.
    @IBInspectable open var shadowOffsetX: CGFloat = 0 {
        didSet { shapeLayer.shadowOffset = shadowOffset }
    }

    /// Extra translation of the shadow of the button on the Y axis.
    @IBInspectable open var shadowOffsetY: CGFloat = 5 {
        didSet { shapeLayer.shadowOffset = shadowOffset }
    }

    /// Opacity of the shadow of the button. 0 is transparent, 1 is opaque.
    @IBInspectable open var shadowOpacity: Float = 0.15 {
        didSet { shapeLayer.shadowOpacity = shadowOpacity }
    }

    /// Radius of the shadow for the button.
    @IBInspectable open var shadowRadius: CGFloat = 5 {
        didSet { shapeLayer.shadowRadius = shadowRadius }
    }

    /// Internal utility to construct the shadow offset from the `IBInspectable` properties.
    private var shadowOffset: CGSize {
        return CGSize(width: self.shadowOffsetX, height: self.shadowOffsetY) }

    /// Sets the background image's content mode. Defaults to `.scaleAspectFill` and has effect only if a `fillImage` is set.
    open var imageContentMode: UIView.ContentMode = .scaleAspectFit {
        didSet {
            imageLayer.contentsGravity = CALayerContentsGravity(rawValue: contentMode.gravity)
        }
    }

    open override var isEnabled: Bool {
        didSet {
            self.shapeLayer.fillColor = self.isEnabled
                ? self.fillColor.cgColor
                : self.inactiveFillColor.cgColor
        }
    }

    open var roundedPath: UIBezierPath {
        // Update the shape of the button and of the shadow.
        return UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        )
    }

    /// The class of the base layer inside the button's view.
    open override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    /// Internal utility to retrieve the base layer as a shape layer without casting it everytime.
    open var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }

    /// A `CALayer` that manages the background image of the button, allowing it to be masked but whithout disrupting the shadow layer.
    private lazy var imageLayer: CALayer = {
        let layer = CALayer()
        layer.frame = self.bounds
        layer.contents = fillImage?.cgImage
        layer.contentsGravity = CALayerContentsGravity(rawValue: contentMode.gravity)
        layer.mask = imageMaskLayer
        return layer
    }()

    /// A `CALayer` that masks the background image of the button, to give it the same curvature as the button itself.
    /// The `path` property of this layer is set in `layoutSubviews`.
    private lazy var imageMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    /// Base setup. Assigning the values from the `IBInspectable`s.
    private func setup() {
        self.shapeLayer.fillColor = self.isEnabled
            ? self.fillColor.cgColor
            : self.inactiveFillColor.cgColor

        self.shapeLayer.strokeColor = self.borderColor.cgColor
        self.shapeLayer.lineWidth = borderWidth

        self.shapeLayer.shadowOffset = shadowOffset
        self.shapeLayer.shadowOpacity = shadowOpacity
        self.shapeLayer.shadowRadius = shadowRadius

        self.shapeLayer.backgroundColor = UIColor.clear.cgColor
        self.shapeLayer.shadowColor = UIColor.black.cgColor

        layer.addSublayer(self.imageLayer)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        self.shapeLayer.path = self.roundedPath.cgPath
        self.shapeLayer.shadowPath = self.roundedPath.cgPath
        self.imageMaskLayer.path = self.roundedPath.cgPath

        self.imageLayer.frame = self.bounds
    }
    
    override open var intrinsicContentSize: CGSize {
        let result = super.intrinsicContentSize
        return CGSize(
            width: result.width + minimumLeftMargin + minimumRightMargin,
            height: result.height + minimumTopMargin + minimumBottomMargin)
    }
    
}

extension UIView.ContentMode {
    public var gravity: String {
        switch self {
        case .bottom: return CALayerContentsGravity.bottom.rawValue
        case .bottomLeft: return CALayerContentsGravity.bottomLeft.rawValue
        case .bottomRight: return CALayerContentsGravity.bottomRight.rawValue

        case .top: return CALayerContentsGravity.top.rawValue
        case .topLeft: return CALayerContentsGravity.topLeft.rawValue
        case .topRight: return CALayerContentsGravity.topRight.rawValue

        case .left: return CALayerContentsGravity.left.rawValue
        case .right: return CALayerContentsGravity.right.rawValue

        case .center: return CALayerContentsGravity.center.rawValue

        case .scaleToFill: return CALayerContentsGravity.resize.rawValue
        case .scaleAspectFit: return CALayerContentsGravity.resizeAspect.rawValue
        case .scaleAspectFill: return CALayerContentsGravity.resizeAspectFill.rawValue
        case .redraw: return CALayerContentsGravity.center.rawValue
        }
    }
}
