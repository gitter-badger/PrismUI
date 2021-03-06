//
//  PrismMultiSliderView.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/14/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Cocoa

public class PrismMultiSliderView: NSView {

    var maxSize = 14
    private let selectorSize: NSSize = NSSize(width: 24, height: 24)
    private let colorSpace = NSColorSpace.deviceRGB
    private var gradient: NSGradient!
    var currentSelector: PrismSelector?
    var outsideBounds: Bool = false
    var firstMouseDown: NSPoint = .zero
    var mode: PrismKeyModes = .colorShift {
        didSet {
            if mode == .colorShift {
                createDefaultColorShift()
            } else if mode == .breathing {
                createDefaultBreathing()
            }
            needsDisplay = true
        }
    }

    weak var delegate: PrismMultiSliderDelegate?

    convenience init (delegate: PrismMultiSliderDelegate? = nil) {
        self.init(frame: NSRect.zero)
        self.delegate = delegate
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        createDefaultColorShift()
    }

    func getSubviewsInOrder() -> [PrismSelector] {
        let subviewsInOrder = subviews.sorted { (slider1, slider2) -> Bool in
            return slider1.frame.origin.x < slider2.frame.origin.x
        }
        return (subviewsInOrder as? [PrismSelector]) ?? []
    }
}

// MARK: Drawing functions

extension PrismMultiSliderView {
    public override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let clipRect = bounds.insetBy(dx: selectorSize.width/2, dy: selectorSize.height/2)
        let path = CGPath(roundedRect: clipRect,
                          cornerWidth: clipRect.height/2,
                          cornerHeight: clipRect.height/2,
                          transform: nil)
        context.beginPath()
        context.addPath(path)
        context.closePath()
        context.clip()

        drawGradient()
    }

    private func drawGradient() {
        let rectBounds = getDrawBounds()
        var colorArr: [NSColor] = []
        var location: [CGFloat] = []
        let selectorArray = getSubviewsInOrder()
        let rectWidth = (rectBounds.width - selectorSize.width/2)

        if mode == .colorShift {
            selectorArray.forEach {
                let selector = $0
                colorArr.append(selector.color.nsColor)
                let point = selector.frame.origin.x / rectWidth
                location.append(point)
            }
        } else if mode == .breathing {
            for inx in 0..<selectorArray.count {
                let firstSelector = selectorArray[inx]
                var halfDistance: CGFloat
                if (inx + 1) < selectorArray.count {
                    let secondSelector = selectorArray[inx + 1]
                    halfDistance = ((secondSelector.frame.origin.x + firstSelector.frame.origin.x) / 2) / rectWidth
                } else {
                    halfDistance = ((rectWidth + firstSelector.frame.origin.x) / 2) / rectWidth
                }
                colorArr.append(selectorArray[inx].color.nsColor)
                colorArr.append(NSColor.black)
                let point = firstSelector.frame.origin.x / rectWidth
                location.append(point)
                location.append(halfDistance)
            }
        } else { return }

        colorArr.append(colorArr[0])
        location.append(1.0)

        gradient = NSGradient(colors: colorArr, atLocations: &location, colorSpace: colorSpace)
        if let gradient = gradient {
            gradient.draw(from: rectBounds.origin, to: CGPoint(x: rectBounds.width, y: 0), options: [])
        }
    }

    private func getDrawBounds() -> NSRect {
        var drawBounds = bounds
        drawBounds.size.width -= selectorSize.width/2
        drawBounds.origin.x = selectorSize.width/2
        return drawBounds
    }

}

// MARK: PrismKeyboard mode functions

extension PrismMultiSliderView {
    private func createDefaultColorShift() {
        maxSize = 14
        subviews.forEach { $0.removeFromSuperview() }
        let centerView = (frame.size.height - selectorSize.height) / 2

        let thumbOne = PrismSelector(frame: NSRect(origin: CGPoint(x: 0, y: centerView), size: selectorSize))
        let thumbTwo = PrismSelector(frame: NSRect(origin: CGPoint(x: 76, y: centerView), size: selectorSize))
        let thumbThree = PrismSelector(frame: NSRect(origin: CGPoint(x: 152, y: centerView), size: selectorSize))

        thumbOne.allowsSelection = true
        thumbTwo.allowsSelection = true
        thumbThree.allowsSelection = true
        thumbOne.delegate = self
        thumbTwo.delegate = self
        thumbThree.delegate = self
        thumbOne.color = PrismRGB(red: 1.0, green: 0.0, blue: 0.88).hsb
        thumbTwo.color = PrismRGB(red: 1.0, green: 0xea/0xff, blue: 0.0).hsb
        thumbThree.color = PrismRGB(red: 0.0, green: 0xcc/0xff, blue: 1.0).hsb
        addSubview(thumbOne)
        addSubview(thumbTwo)
        addSubview(thumbThree)
    }

    private func createDefaultBreathing() {
        maxSize = 4
        subviews.forEach { $0.removeFromSuperview() }
        let centerView = (frame.size.height - selectorSize.height) / 2
        let selector = PrismSelector(frame: NSRect(origin: CGPoint(x: 0, y: centerView), size: selectorSize))
        selector.allowsSelection = true
        selector.color = PrismRGB(red: 1.0, green: 0.0, blue: 0.0).hsb
        selector.delegate = self
        addSubview(selector)
    }

    public func colorShiftTransitions(speed: CGFloat) -> [PrismTransition] {
        return calculateTransitions(speed: speed)
    }

    public func breathingTransitions(speed: CGFloat) -> [PrismTransition] {
        var newTransitions: [PrismTransition] = []
        let transitions = calculateTransitions(speed: speed)

        for index in 0..<transitions.count {
            let transition = transitions[index]
            let newDuration = transition.duration / 2
            transition.duration = newDuration
            newTransitions.append(transition)
            let newTrans = PrismTransition(color: PrismRGB(), duration: newDuration)
            newTransitions.append(newTrans)
        }

        return newTransitions
    }

    private func calculateTransitions(speed: CGFloat) -> [PrismTransition] {
        var transitions: [PrismTransition] = []
        let selectors = getSubviewsInOrder()
        let width = getDrawBounds().size.width
        for index in 0..<selectors.count {
            let selector = selectors[index]
            let distance: CGFloat
            if (index + 1) < selectors.count {
                let nextSelector = selectors[index + 1]
                distance = (nextSelector.frame.origin.x - selector.frame.origin.x) / width
            } else {
                let firstSelector = selectors[0]
                distance = ((width - selector.frame.origin.x) + firstSelector.frame.origin.x) / width
            }
            let transition = PrismTransition(color: selector.color.rgb, duration: UInt16(speed * distance))
            transitions.append(transition)
        }

        return transitions
    }
}

// MARK: Action functions

extension PrismMultiSliderView {

    private func updateSelectorFromPoint(selector: PrismSelector, newPoint: NSPoint, animate: Bool = false) {
        let centerView = (frame.size.height - selectorSize.height) / 2
        let rect = getDrawBounds()
        let width = rect.size.width - selectorSize.width/2
        var xAxis = newPoint.x - selectorSize.width/2
        var yAxis = newPoint.y - selectorSize.height/2
        xAxis = min(max(xAxis, 0), width)
        yAxis = min(50 + yAxis, centerView)
        if yAxis != centerView {
            yAxis = newPoint.y - selectorSize.height/2
            outsideBounds = true
        } else {
            outsideBounds = false
        }

        if animate {
            selector.animator().frame.origin = CGPoint(x: xAxis, y: yAxis)
        } else {
            selector.frame.origin = CGPoint(x: xAxis, y: yAxis)
        }
        needsDisplay = true
    }

    private func updateSelectorDragFromPoint(selector: PrismSelector, newPoint: NSPoint) {
        let deltaX = newPoint.x - firstMouseDown.x
        let centerView = (frame.size.height - selectorSize.height) / 2
        let rect = getDrawBounds()
        let width = rect.size.width - selectorSize.width/2
        var xAxis = selector.frame.origin.x + deltaX
        var yAxis = newPoint.y - selectorSize.height/2
        xAxis = min(max(xAxis, 0), width)
        yAxis = min(50 + yAxis, centerView)

        if yAxis != centerView {
            yAxis = newPoint.y - selectorSize.height/2
            outsideBounds = true
        } else {
            outsideBounds = false
        }

        selector.frame.origin = CGPoint(x: xAxis, y: yAxis)
        firstMouseDown = newPoint
        needsDisplay = true
    }

    public override func mouseDown(with event: NSEvent) {
        guard let newPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }

        for view in subviews {
            if let selector = view as? PrismSelector, selector.frame.contains(newPoint) {
                currentSelector = selector
                firstMouseDown = newPoint
                return super.mouseDown(with: event)
            }
        }

        // create new selector at a given point
        if subviews.count < maxSize, let gradient = gradient {
            let rect = getDrawBounds()
            let selector = PrismSelector(frame: NSRect(origin: newPoint, size: selectorSize))
            selector.allowsSelection = true
            selector.delegate = self
            updateSelectorFromPoint(selector: selector, newPoint: newPoint)
            selector.color = gradient.interpolatedColor(atLocation: newPoint.x/rect.width).prismHSB
            addSubview(selector)
            needsDisplay = true
            delegate?.added(selector)
        }
    }

    public override func mouseDragged(with event: NSEvent) {
        guard let newPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }

        guard let selector = currentSelector else { return }
        updateSelectorDragFromPoint(selector: selector, newPoint: newPoint)
    }

    public override func mouseUp(with event: NSEvent) {
        guard let newPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            print("Could not convert window point to local point")
            return
        }

        guard let selector = currentSelector else { return }
        if outsideBounds && subviews.count > 1 {
            selector.animator().removeFromSuperview()
        } else if outsideBounds {
            updateSelectorFromPoint(selector: selector, newPoint: NSPoint(x: newPoint.x, y: 0), animate: true)
        }

        outsideBounds = false
        currentSelector = nil
        needsDisplay = true
    }
}

extension PrismMultiSliderView: PrismSelectorDelegate {
    func didSelect(_ sender: PrismSelector) {
        delegate?.didSelect(sender)
    }

    func didDeselect(_ sender: PrismSelector) {
        delegate?.didDeselect(sender)
    }

    func event(_ sender: PrismSelector, _ event: NSEvent) {
        delegate?.event(sender, event)
    }
}

protocol PrismMultiSliderDelegate: AnyObject {
    func didSelect(_ sender: PrismSelector)
    func didDeselect(_ sender: PrismSelector)
    func event(_ sender: PrismSelector, _ event: NSEvent)
    func added(_ sender: PrismSelector)
}
