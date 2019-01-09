//
//  UIImave.swift
//  Take
//
//  Created by Family on 5/18/18.
//  Copyright © 2018 N8. All rights reserved.
//

import Firebase
import Foundation
import UIKit

extension UIImage {

    convenience init?(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let theImage = image?.cgImage else { return nil }
        self.init(cgImage: theImage)
    }

    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func saveToFb(route: Route, completion: @escaping (_ url: URL?) -> Void) {
        guard let data = self.jpegData(compressionQuality: 0.1) else { return }
        let imageRef = Storage.storage().reference().child("Routes/\(route.id)")
        let imageId = UUID().uuidString
        _ = imageRef.child(imageId).putData(data, metadata: nil) { metadata, _ in
            guard metadata != nil else {
                return
            }
            imageRef.child(imageId).downloadURL { url, _ in
                completion(url)
            }

        }
    }

    func imageWithInsets(insetDimen: CGFloat) -> UIImage? {
        return imageWithInset(insets: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }

    private func imageWithInset(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width + insets.left + insets.right, height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }

    func mask(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
