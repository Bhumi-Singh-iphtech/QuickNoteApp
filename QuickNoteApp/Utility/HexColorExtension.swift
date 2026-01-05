//
//  HexColorExtension.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 05/01/26.
//

import UIKit

extension UIColor {

    /// Create UIColor from HEX string (e.g. "#36373F" or "36373F")
    convenience init(hex: String, alpha: CGFloat = 1.0) {

        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        guard hexString.count == 6,
              let hexValue = Int(hexString, radix: 16) else {
            self.init(white: 0.0, alpha: alpha) // fallback: black
            return
        }

        let red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
        let green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hexValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
