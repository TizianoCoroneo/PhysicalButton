//
//  PhysicalButton.swift
//  PhysicalButton_Example
//
//  Created by Tiziano Coroneo on 23/10/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import PhysicalButton

@IBDesignable
open class PhysicalButton: ButtonDoneRight {

    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .heavy
    var rotationIntensity: CGFloat = (45/180) * (.pi / 2)
    var translationIntensity: CGFloat = 75
    var scaleIntensity: CGFloat = 0.05

    var pressedShadowScale: CGFloat = 0.9

    var normalShadowRadius: CGFloat = 10
    var pressedShadowRadius: CGFloat = 4

    var defaultTouchRelativeForce: CGFloat = 0.7

    var minimumForceFactor: CGFloat = 0.5
    var maximumForceFactor: CGFloat = 5

    private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
    private var isTouchActive: Bool = false

    var isForceTouchEnabled: Bool {
        return traitCollection.forceTouchCapability == .available
    }

    lazy var shadowLayer3D: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.shadowPath = self.roundedPath.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
        layer.zPosition = -200
        return layer
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {

        layer.insertSublayer(shadowLayer3D, at: 0)

        imageLayer.zPosition = -100
        shapeLayer.zPosition = -200
        shadowLayer3D.zPosition = -300
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard event?.type == .touches,
            let touch = event?.allTouches?.first,
            let transform = transformFromTouch(touch)
            else { return }

        isTouchActive = true
        feedbackGenerator.impactOccurred()
        shadowLayer3D.shadowRadius = pressedShadowRadius

        apply(transform: transform)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard event?.type == .touches,
            let touch = touches.first,
            isTouchActive
            else { return }

        guard let transform = transformFromTouch(touch)
            else {
                isTouchActive = false
                feedbackGenerator.impactOccurred()
                shadowLayer3D.shadowRadius = normalShadowRadius
                releaseTransform()
                return
        }

        apply(transform: transform)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouchActive
            else { return }

        shadowLayer3D.shadowRadius = normalShadowRadius
        releaseTransform()
    }

    func transformFromTouch(_ touch: UITouch) -> CATransform3D? {

        let location = touch.preciseLocation(in: self)

        let force: CGFloat
        if isForceTouchEnabled {
            force = max(min(sqrt(touch.force), maximumForceFactor), minimumForceFactor)
        } else {
            force = defaultTouchRelativeForce
        }

        guard
            self.bounds.contains(location)
            else { return nil }

        let distanceFromCenter = CGPoint(
            x: bounds.midX - location.x,
            y: bounds.midY - location.y)

        let relativeDistanceFromCenter = CGPoint(
            x: -distanceFromCenter.x / (bounds.width/2),
            y: distanceFromCenter.y / (bounds.height/2))

        assert(relativeDistanceFromCenter.x <= 1.0)
        assert(relativeDistanceFromCenter.x >= -1.0)
        assert(relativeDistanceFromCenter.y <= 1.0)
        assert(relativeDistanceFromCenter.y >= -1.0)

        print("Relative distance = \(relativeDistanceFromCenter)")

        let relativeStrenght = sqrt((pow(relativeDistanceFromCenter.x, 2) + pow(relativeDistanceFromCenter.y, 2)) / 2)

        assert(relativeStrenght <= 2.0)
        assert(relativeStrenght >= 0)

        let rotation = CATransform3DMakeRotation(
            relativeStrenght * rotationIntensity * force,
            relativeDistanceFromCenter.y,
            relativeDistanceFromCenter.x,
            0)

        let translationFactor = (1 - cos(relativeStrenght * rotationIntensity * force)) * translationIntensity

        let translation = CATransform3DTranslate(
            rotation,
            relativeDistanceFromCenter.x * translationFactor,
            -relativeDistanceFromCenter.y * translationFactor,
            0)

        let scaleFactor = 1 - (scaleIntensity * relativeStrenght * force)

        let scale = CATransform3DScale(
            translation,
            scaleFactor,
            scaleFactor,
            1)

        return scale
    }

    func apply(transform: CATransform3D) {
        CATransaction.begin()
        layer.sublayers?.forEach { layer in
            layer.transform = transform
            layer.removeAllAnimations()
        }

        shadowLayer3D.transform = CATransform3DScale(
            CATransform3DInvert(transform),
            pressedShadowScale,
            pressedShadowScale,
            1)
        shadowLayer3D.removeAllAnimations()

        CATransaction.commit()
    }

    func releaseTransform() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.layer.sublayers?.forEach { layer in
                layer.transform = CATransform3DIdentity
            }
            self?.layer.transform = CATransform3DIdentity
        }
    }
}

