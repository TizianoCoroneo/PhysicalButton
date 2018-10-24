////
////  PhysicalButton.swift
////  PhysicalButton
////
////  Created by Tiziano Coroneo on 23/10/2018.
////
//
//import UIKit
//
//@IBDesignable
//open class PhysicalButton: ButtonDoneRight {
//
//    var intensity: CGFloat = (30/180) * (.pi / 2)
//
//    open override func awakeFromNib() {
//        super.awakeFromNib()
//        self.isUserInteractionEnabled = false
//    }
//
//    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        super.touchesBegan(touches, with: event)
//
//        guard event?.type == .touches,
//            let touch = event?.allTouches?.first
//            else { return }
//
//        self.layer.transform = transformFromTouch(touch)
//    }
//
//    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
////        super.touchesMoved(touches, with: event)
//
//        guard event?.type == .touches,
//            let touch = touches.first
//            else { return }
//
//        self.layer.transform = transformFromTouch(touch)
//    }
//
//    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
////        super.touchesEnded(touches, with: event)
//
//        self.layer.transform = CATransform3DIdentity
//    }
//
//
//    func transformFromTouch(_ touch: UITouch) -> CATransform3D {
//        let location = touch.location(in: self)
//
//        let distanceFromCenter = CGPoint(
//            x: center.x - location.x,
//            y: center.y - location.y)
//
//        let relativeDistanceFromCenter = CGPoint(
//            x: distanceFromCenter.x / (bounds.width/2),
//            y: distanceFromCenter.y / (bounds.height/2))
//
//        let relativeStrenght = pow(relativeDistanceFromCenter.x, 2) + pow(relativeDistanceFromCenter.y, 2)
//
//        let transform = CATransform3DMakeRotation(
//            relativeStrenght * intensity,
//            relativeDistanceFromCenter.x,
//            relativeDistanceFromCenter.y,
//            0)
//
//        return transform
//    }
//}
//
