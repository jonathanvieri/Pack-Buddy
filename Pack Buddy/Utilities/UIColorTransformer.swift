//
//  UIColorTransformer.swift
//  Pack Buddy
//
//  Created by Jonathan Vieri on 10/10/24.
//

import CoreData
import UIKit

@objc(UIColorTransformer)
class UIColorTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
            return true
        }

        override func transformedValue(_ value: Any?) -> Any? {
            guard let color = value as? UIColor else { return nil }
            return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
        }

        override func reverseTransformedValue(_ value: Any?) -> Any? {
            guard let data = value as? Data else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        }
}
