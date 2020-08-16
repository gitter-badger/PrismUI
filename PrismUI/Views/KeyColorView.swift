//
//  KeyView.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

class KeyColorView: ColorView {

    var prismKey = PrismKey() {
        didSet {
            color = prismKey.mainColor.nsColor
        }
    }

    var text: NSString = NSString()

    let textStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()

    convenience init(text: String) {
        self.init()
        self.text = text as NSString
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let textColor: NSColor = color.scaledBrightness < 0.5 ? .white : .black
        let attributes = [NSAttributedString.Key.paragraphStyle: textStyle,
                          NSAttributedString.Key.foregroundColor: textColor]
        text.drawVerticallyCentered(in: dirtyRect,
                                    withAttributes: attributes)
    }
}

/// From https://stackoverflow.com/a/46691271
extension NSString {
    func drawVerticallyCentered(in rect: CGRect, withAttributes attributes: [NSAttributedString.Key: Any]? = nil) {
        let size = self.size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.origin.x,
                                  y: rect.origin.y + (rect.size.height-size.height)/2.0,
                                  width: rect.size.width,
                                  height: size.height)
        self.draw(in: centeredRect, withAttributes: attributes)
    }
}
