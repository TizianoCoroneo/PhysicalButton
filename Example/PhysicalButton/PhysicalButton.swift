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
    var rotationIntensity: CGFloat = (90/180) * (.pi / 2)
    var translationIntensity: CGFloat = 150
    var scaleIntensity: CGFloat = 0.95

    private lazy var feedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
    private var isTouchActive: Bool = false

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard event?.type == .touches,
            let touch = event?.allTouches?.first,
            let transform = transformFromTouch(touch)
            else { return }

        isTouchActive = true
        feedbackGenerator.impactOccurred()

        layer.transform = transform
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
                releaseTransform()
                return
        }

        self.layer.transform = transform
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouchActive
            else { return }

        releaseTransform()
    }

    func transformFromTouch(_ touch: UITouch) -> CATransform3D? {
//        let superviewLocation = touch.preciseLocation(in: superview)
//
//        let location = CGPoint(
//            x: superviewLocation.x - frame.origin.x,
//            y: superviewLocation.y - frame.origin.y)

        let location = touch.preciseLocation(in: self)

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
            relativeStrenght * rotationIntensity,
            relativeDistanceFromCenter.y,
            relativeDistanceFromCenter.x,
            0)

        let translationFactor = (1 - cos(relativeStrenght * rotationIntensity)) * translationIntensity

        let translation = CATransform3DTranslate(
            rotation,
            relativeDistanceFromCenter.x * translationFactor,
            -relativeDistanceFromCenter.y * translationFactor,
            0)

        let scale = CATransform3DScale(translation, scaleIntensity, scaleIntensity, 1)

        return scale
    }

    func releaseTransform() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.layer.transform = CATransform3DIdentity
        }
    }
}

