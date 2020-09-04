//
//  ModesViewController.swift
//  PrismUI
//
//  Created by Erik Bautista on 7/13/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import Cocoa

class ModesViewController: BaseViewController {

    // MARK: Selector array

    static let selectorArray = NSMutableArray()

    // MARK: Common initialization

    let presetsButton: NSButton = {
        let image = NSImage(named: "NSSidebarTemplate")!
        let button = NSButton(image: image,
                              target: nil,
                              action: #selector(onButtonClicked(_:update:)))
        button.bezelStyle = .rounded
        button.identifier = .presets
        return button
    }()

    let modesLabel: NSTextField = {
        let label = NSTextField(labelWithString: "EFFECT")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        return label
    }()

    let modesPopUp: NSPopUpButton = {
        let popup = NSPopUpButton()
        popup.addItem(withTitle: PrismKeyModes.steady.rawValue)
        popup.addItem(withTitle: PrismKeyModes.colorShift.rawValue)
        popup.addItem(withTitle: PrismKeyModes.breathing.rawValue)
        popup.addItem(withTitle: PrismKeyModes.reactive.rawValue)
        popup.addItem(withTitle: PrismKeyModes.disabled.rawValue)
        popup.addItem(withTitle: "Mixed")
        popup.item(withTitle: "Mixed")?.isHidden = true
        popup.action = #selector(didPopupChanged(_:))
        return popup
    }()

    let colorPicker: PrismColorPicker = PrismColorPicker()

    let speedLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Speed")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    let speedSlider: NSSlider = {
       let slider = NSSlider(value: 300,
                             minValue: 100,
                             maxValue: 1000,
                             target: nil,
                             action: #selector(onSliderChanged(_:update:)))
        slider.isHidden = true
        slider.identifier = .speed
        return slider
    }()

    let speedValue: NSTextField = {
        let label = NSTextField(labelWithString: "3s")
        label.isHidden = true
        return label
    }()

    // MARK: ColorShift and Breathing

    let multiSlider: PrismMultiSliderView = {
        let slider = PrismMultiSliderView()
        slider.isHidden = true
        return slider
    }()

    // MARK: ColorShift items

    let waveToggle: NSButton = {
        let check = NSButton(checkboxWithTitle: "Wave Mode",
                             target: nil,
                             action: #selector(onButtonClicked(_:update:)))
        check.state = .on
        check.identifier = .waveToggle
        check.isHidden = true
        return check
    }()

    let originButton: NSButton = {
        let button = NSButton(title: "Origin",
                              target: nil,
                              action: #selector(onButtonClicked(_:update:)))
        button.isHidden = true
        button.identifier = .origin
        return button
    }()

    let waveDirectionControl: NSSegmentedControl = {
        let segmented = NSSegmentedControl(labels: ["XY", "X", "Y"],
                                           trackingMode: .selectOne,
                                           target: nil,
                                           action: #selector(onButtonClicked(_:update:)))
        segmented.selectedSegment = 0
        segmented.identifier = .xyDirection
        segmented.isHidden = true
        return segmented
    }()

    let waveInwardOutwardControl: NSSegmentedControl = {
        let segmented = NSSegmentedControl(labels: ["Out", "In"],
                                           trackingMode: .selectOne,
                                           target: nil,
                                           action: #selector(onButtonClicked(_:update:)))
        segmented.selectedSegment = 0
        segmented.identifier = .inwardOutward
        segmented.isHidden = true
        return segmented
    }()

    let pulseLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Pulse")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    let pulseSlider: NSSlider = {
        let slider = NSSlider(value: 100,
                              minValue: 30,
                              maxValue: 1000,
                              target: nil,
                              action: #selector(onSliderChanged(_:update:)))
        slider.isHidden = true
        slider.identifier = .pulse
        return slider
    }()

    let pulseValue: NSTextField = {
        let label = NSTextField(labelWithString: "10")
        label.isHidden = true
        return label
    }()

    // MARK: Reactive initialization

    let reactActiveText: NSTextField = {
        let label = NSTextField(labelWithString: "Active")
        label.setupLabel()
        label.isHidden = true
        return label
    }()

    let reactActiveColor: ColorView = {
       let view = ColorView()
        view.isHidden = true
        view.color = PrismRGB(red: 1.0, green: 0.0, blue: 0.0).nsColor
        return view
    }()

    let reactRestText: NSTextField = {
        let label = NSTextField(labelWithString: "Rest")
        label.setupLabel()
        label.isHidden = true
        return label
    }()

    let reactRestColor: ColorView = {
       let view = ColorView()
        view.isHidden = true
        view.color = PrismRGB(red: 0.0, green: 0.0, blue: 0.0).nsColor
        return view
    }()

    weak var delegate: ModesViewControllerDelegate?

    private var selectorDragging = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainView = view as? NSVisualEffectView {
            mainView.material = .windowBackground
            if let colorPickerView = colorPicker.view as? NSVisualEffectView {
                colorPickerView.material = mainView.material
            }
        }

        presetsButton.target = self
        modesPopUp.target = self
        speedSlider.target = self
        waveToggle.target = self
        pulseSlider.target = self
        originButton.target = self
        waveDirectionControl.target = self
        waveInwardOutwardControl.target = self
        colorPicker.delegate = self
        reactActiveColor.delegate = self
        reactRestColor.delegate = self
        multiSlider.delegate = self
        view.addSubview(presetsButton)
        view.addSubview(modesLabel)
        view.addSubview(modesPopUp)
        view.addSubview(multiSlider)
        view.addSubview(speedLabel)
        view.addSubview(speedSlider)
        view.addSubview(speedValue)
        view.addSubview(waveToggle)
        view.addSubview(originButton)
        view.addSubview(waveDirectionControl)
        view.addSubview(waveInwardOutwardControl)
        view.addSubview(pulseLabel)
        view.addSubview(pulseSlider)
        view.addSubview(pulseValue)
        view.addSubview(reactActiveText)
        view.addSubview(reactActiveColor)
        view.addSubview(reactRestText)
        view.addSubview(reactRestColor)

        addChild(colorPicker)
        view.addSubview(colorPicker.view)
        setupConstraints()
    }

    private func setupConstraints() {
        view.subviews.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        let edgeMargin: CGFloat = 18

        presetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeMargin).isActive = true
        presetsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true

        modesLabel.leadingAnchor.constraint(equalTo: presetsButton.leadingAnchor).isActive = true
        modesLabel.topAnchor.constraint(equalTo: presetsButton.bottomAnchor, constant: 20).isActive = true

        modesPopUp.leadingAnchor.constraint(equalTo: modesLabel.leadingAnchor).isActive = true
        modesPopUp.topAnchor.constraint(equalTo: modesLabel.bottomAnchor, constant: 4).isActive = true

        colorPicker.view.leadingAnchor.constraint(equalTo: modesPopUp.leadingAnchor).isActive = true
        colorPicker.view.topAnchor.constraint(equalTo: modesPopUp.bottomAnchor, constant: 20).isActive = true
        colorPicker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeMargin).isActive = true
        colorPicker.view.heightAnchor.constraint(equalToConstant: 180).isActive = true

        // Reactive Constraints
        let heightView: CGFloat = 40

        reactActiveColor.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        reactActiveColor.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor).isActive = true
        reactActiveColor.widthAnchor.constraint(equalToConstant: heightView - 8).isActive = true
        reactActiveColor.heightAnchor.constraint(equalToConstant: heightView - 8).isActive = true

        reactActiveText.leadingAnchor.constraint(equalTo: reactActiveColor.trailingAnchor, constant: 10).isActive = true
        reactActiveText.centerYAnchor.constraint(equalTo: reactActiveColor.centerYAnchor).isActive = true

        reactRestColor.leadingAnchor.constraint(equalTo: reactActiveText.trailingAnchor, constant: 20).isActive = true
        reactRestColor.topAnchor.constraint(equalTo: reactActiveColor.topAnchor).isActive = true
        reactRestColor.widthAnchor.constraint(equalTo: reactActiveColor.widthAnchor).isActive = true
        reactRestColor.heightAnchor.constraint(equalTo: reactActiveColor.heightAnchor).isActive = true

        reactRestText.leadingAnchor.constraint(equalTo: reactRestColor.trailingAnchor, constant: 10).isActive = true
        reactRestText.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        reactRestText.centerYAnchor.constraint(equalTo: reactRestColor.centerYAnchor).isActive = true

        // ColorShift / Breathing cconstraints

        multiSlider.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        multiSlider.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        multiSlider.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor).isActive = true
        multiSlider.heightAnchor.constraint(equalToConstant: heightView).isActive = true

        speedLabel.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        speedLabel.topAnchor.constraint(equalTo: colorPicker.view.bottomAnchor,
                                        constant: heightView + 8).isActive = true
        speedLabel.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true

        speedSlider.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        speedSlider.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 4).isActive = true
        speedSlider.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor, constant: -28).isActive = true

        speedValue.leadingAnchor.constraint(equalTo: speedSlider.trailingAnchor, constant: 8).isActive = true
        speedValue.topAnchor.constraint(equalTo: speedSlider.topAnchor).isActive = true
        speedValue.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true

        waveToggle.topAnchor.constraint(equalTo: speedSlider.bottomAnchor, constant: 12).isActive = true
        waveToggle.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true

        originButton.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
        originButton.centerYAnchor.constraint(equalTo: waveToggle.centerYAnchor).isActive = true

        waveDirectionControl.topAnchor.constraint(equalTo: waveToggle.bottomAnchor, constant: 12).isActive = true
        waveDirectionControl.leadingAnchor.constraint(equalTo: waveToggle.leadingAnchor).isActive = true

        waveInwardOutwardControl.centerYAnchor.constraint(equalTo: waveDirectionControl.centerYAnchor).isActive = true
        waveInwardOutwardControl.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true

        pulseLabel.topAnchor.constraint(equalTo: waveDirectionControl.bottomAnchor, constant: 12).isActive = true
        pulseLabel.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true

        pulseSlider.leadingAnchor.constraint(equalTo: colorPicker.view.leadingAnchor).isActive = true
        pulseSlider.topAnchor.constraint(equalTo: pulseLabel.bottomAnchor, constant: 4).isActive = true
        pulseSlider.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor, constant: -28).isActive = true

        pulseValue.leadingAnchor.constraint(equalTo: pulseSlider.trailingAnchor, constant: 8).isActive = true
        pulseValue.topAnchor.constraint(equalTo: pulseSlider.topAnchor).isActive = true
        pulseValue.trailingAnchor.constraint(equalTo: colorPicker.view.trailingAnchor).isActive = true
    }
}

// MARK: Actions

extension ModesViewController {

    @objc func onSliderChanged(_ sender: NSSlider, update: Bool = true) {
        guard let identifierr = sender.identifier else { return }
        switch identifierr {
        case .speed:
            speedValue.stringValue = "\(sender.intValue.description.dropLast(2))s"
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let prismKey = ($0 as? KeyColorView)?.prismKey else { return }
                prismKey.duration = UInt16(sender.intValue)
            }
        case .pulse:
            pulseValue.stringValue = "\(sender.intValue.description.dropLast(1))"
        default:
            Log.debug("Slider not implemented \(String(describing: sender.identifier))")
            return
        }

        let event = NSApplication.shared.currentEvent
        if event?.type == NSEvent.EventType.leftMouseUp && update {
            didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
        }
    }

    @objc func onButtonClicked(_ sender: NSButton, update: Bool = true) {
        guard let identifier = sender.identifier else { return }
        Log.debug("Button pressed \(identifier)")
        switch identifier {
        case .presets:
            delegate?.didClickOnPresetsButton()
            return
        case .origin,
             .xyDirection,
             .inwardOutward:
            break
        case .waveToggle:
            let enabled = sender.state == .on
            originButton.isEnabled = enabled
            waveDirectionControl.isEnabled = enabled
            waveInwardOutwardControl.isEnabled = enabled
            pulseSlider.isEnabled = enabled
        default:
            Log.debug("Unkown button pressed \(identifier)")
            return
        }

        didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: update)
    }

    @objc func didPopupChanged(_ sender: NSPopUpButton) {
        Log.debug("sender: \(String(describing: sender.titleOfSelectedItem))")
        switch sender.titleOfSelectedItem {
        case PrismKeyModes.steady.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
        case PrismKeyModes.reactive.rawValue:
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showReactiveMode()
        case PrismKeyModes.colorShift.rawValue:
            showReactiveMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
            showColorShiftMode()
        case PrismKeyModes.breathing.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode()
        case PrismKeyModes.disabled.rawValue:
            showReactiveMode(shouldShow: false)
            showColorShiftMode(shouldShow: false)
            showBreadingMode(shouldShow: false)
        default:
            Log.error("Mode Unavalilable")
            return
        }
        colorPicker.setColor(newColor: PrismRGB(red: 1.0, green: 0, blue: 0))
        didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
    }
}

// MARK: PerKey Modes state

extension ModesViewController {

    private func showReactiveMode(shouldShow: Bool = true) {
        ModesViewController.selectorArray.filter { ($0 as? ColorView) != nil }.forEach {
            guard let selector = $0 as? ColorView else { return }
            selector.selected = false
        }
        ModesViewController.selectorArray.removeAllObjects()
        reactActiveText.isHidden = !shouldShow
        reactActiveColor.isHidden = !shouldShow
        reactRestText.isHidden = !shouldShow
        reactRestColor.isHidden = !shouldShow
        speedLabel.isHidden = !shouldShow
        speedSlider.isHidden = !shouldShow
        speedValue.isHidden = !shouldShow

        if shouldShow {
            speedSlider.minValue = 100
            speedSlider.maxValue = 1000
            speedSlider.intValue = 300
            reactActiveColor.color = PrismRGB(red: 0xff, green: 0x0, blue: 0x0).nsColor
            reactRestColor.color = PrismRGB(red: 0x0, green: 0x0, blue: 0x0).nsColor
            onSliderChanged(speedSlider, update: false)
        }
    }

    private func showColorShiftMode(shouldShow: Bool = true) {
        ModesViewController.selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
            guard let selector = $0 as? PrismSelector else { return }
            selector.selected = false
        }
        ModesViewController.selectorArray.removeAllObjects()
        multiSlider.isHidden = !shouldShow
        speedLabel.isHidden = !shouldShow
        speedSlider.isHidden = !shouldShow
        speedValue.isHidden = !shouldShow
        waveToggle.isHidden = !shouldShow
        originButton.isHidden = !shouldShow
        waveDirectionControl.isHidden = !shouldShow
        waveInwardOutwardControl.isHidden = !shouldShow
        pulseLabel.isHidden = !shouldShow
        pulseSlider.isHidden = !shouldShow
        pulseValue.isHidden = !shouldShow

        if shouldShow {
            multiSlider.mode = .colorShift
            speedSlider.minValue = 100
            speedSlider.maxValue = 3000
            speedSlider.intValue = 300
            pulseSlider.intValue = 100
            waveToggle.state = .off
            waveInwardOutwardControl.selectedSegment = 1
            waveDirectionControl.selectedSegment = 0
            onButtonClicked(waveToggle, update: false)
            onSliderChanged(speedSlider, update: false)
            onSliderChanged(pulseSlider, update: false)
        }
    }

    private func showBreadingMode(shouldShow: Bool = true) {
        ModesViewController.selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
            guard let selector = $0 as? PrismSelector else { return }
            selector.selected = false
        }
        ModesViewController.selectorArray.removeAllObjects()
        multiSlider.isHidden = !shouldShow
        speedLabel.isHidden = !shouldShow
        speedSlider.isHidden = !shouldShow
        speedValue.isHidden = !shouldShow

        if shouldShow {
            multiSlider.mode = .breathing
            speedSlider.minValue = 200
            speedSlider.maxValue = 3000
            speedSlider.intValue = 400
            onSliderChanged(speedSlider, update: false)
        }
    }
}

// MARK: Color Picker delegate

extension ModesViewController: PrismColorPickerDelegate {

    func didColorChange(newColor: PrismRGB, finishedChanging: Bool) {
        guard let device = PrismDriver.shared.currentDevice else {
            return
        }

        if device.isKeyboardDevice && device.model != .threeRegion {
            updatePerKeyColors(newColor: newColor, finished: finishedChanging)
        } else if device.isKeyboardDevice && device.model == .threeRegion {
            // TODO: Update three region keyboard viw
        }
    }
}

// MARK: device settings
extension ModesViewController {

    func updatePerKeyColors(newColor: PrismRGB, finished: Bool) {
        guard modesPopUp.titleOfSelectedItem != nil else { return }
        guard let mode = PrismKeyModes(rawValue: modesPopUp.titleOfSelectedItem!) else { return }
        var needsUpdate = false
        switch mode {
        case PrismKeyModes.steady:
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                prismKey.mode = .steady
                prismKey.main = newColor
                colorView.prismKey = prismKey
                needsUpdate = true
            }
        case PrismKeyModes.colorShift,
             PrismKeyModes.breathing:
            ModesViewController.selectorArray.filter { ($0 as? PrismSelector) != nil }.forEach {
                guard let selector = $0 as? PrismSelector else { return }
                selector.color = newColor.hsb
            }

            // Create effect once it's finished updating color
            guard let effect = getKeyEffect(mode: mode) else {
                Log.error("Cannot create effect package due to error in transitions.")
                return
            }
            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                prismKey.mode = mode
                prismKey.effect = effect
                colorView.prismKey = prismKey
                needsUpdate = true
            }
        case PrismKeyModes.reactive:
            ModesViewController.selectorArray.filter { ($0 as? ColorView) != nil }.forEach {
                guard let colorView = $0 as? ColorView else { return }
                colorView.color = newColor.nsColor
            }

            PrismKeyboard.keysSelected.filter { ($0 as? KeyColorView) != nil }.forEach {
                guard let colorView = $0 as? KeyColorView else { return }
                guard let prismKey = colorView.prismKey else { return }
                prismKey.mode = .reactive
                prismKey.active = reactActiveColor.color.prismRGB
                prismKey.main = reactRestColor.color.prismRGB
                colorView.prismKey = prismKey
                needsUpdate = true
            }

        case PrismKeyModes.disabled:
            break
        }

        removeUnusedEffecs()

        if finished && needsUpdate {
            updateDevice()
        }
    }

    private func getKeyEffect(mode: PrismKeyModes) -> PrismEffect? {
        var identifier: UInt8 = 0
        let usedEffectId: [UInt8] = PrismKeyboard.keys.compactMap { ($0 as? PrismKey)?.effect?.identifier }
        for unusedId in 1...0xff {
            let containsId = usedEffectId.contains(UInt8(unusedId))
            if !containsId {
                identifier = UInt8(unusedId)
                break
            }
        }

        var transitions: [PrismTransition]
        if mode == .colorShift {
            transitions = multiSlider.colorShiftTransitions(speed: CGFloat(speedSlider.floatValue))
        } else {
            transitions = multiSlider.breathingTransitions(speed: CGFloat(speedSlider.floatValue))
        }

        guard transitions.count > 0 else {
            return nil
        }

        let effect = PrismEffect(identifier: identifier, transitions: transitions)

        if mode == .colorShift {
            effect.waveActive = waveToggle.state == .on
            if waveToggle.state == .on {
                effect.origin = PrismPoint(xAxis: 0, yAxis: 0)
                effect.waveLength = UInt16(pulseValue.integerValue)
                effect.direction = PrismDirection(rawValue: UInt8(waveDirectionControl.selectedSegment)) ?? .xyAxis
                effect.control = PrismControl(rawValue: UInt8(waveInwardOutwardControl.selectedSegment)) ?? .inward
            }
        }

        for element in PrismKeyboard.effects.compactMap({ $0 as? PrismEffect }) where element == effect {
                return element
        }

        PrismKeyboard.effects.add(effect)
        return effect
    }

    private func removeUnusedEffecs() {
        let usedEffectId: [UInt8] = PrismKeyboard.keys.compactMap { ($0 as? PrismKey)?.effect?.identifier }
        for effect in PrismKeyboard.effects.compactMap({$0 as? PrismEffect}) {
            let contains = usedEffectId.contains(effect.identifier)
            if !contains {
                PrismKeyboard.effects.remove(effect)
                removeUnusedEffecs()
                break
            }
        }
    }

    func updateDevice(forced: Bool = false) {
        if PrismKeyboard.keysSelected.count > 0 || forced {
            guard let device = PrismDriver.shared.currentDevice, device.model != .threeRegion else {
                return
            }
            device.update()
        }
    }
}

// MARK: MultiSlider Selector delegate

extension ModesViewController: PrismMultiSliderDelegate {

    func added(_ sender: PrismSelector) {
        didColorChange(newColor: sender.color.rgb, finishedChanging: true)
    }

    func event(_ sender: PrismSelector, _ event: NSEvent) {
        switch event.type {
        case .leftMouseDragged:
            selectorDragging = true
            didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: false)
        case .leftMouseUp:
            if !selectorDragging {
                if ModesViewController.selectorArray.count == 1 {
                    colorPicker.setColor(newColor: sender.color.rgb)
                }
            } else {
                didColorChange(newColor: colorPicker.colorGraphView.color.rgb, finishedChanging: true)
                selectorDragging = false
            }
        default:
            Log.debug("Event not valid: \(event.type.rawValue)")
        }
    }

    func didSelect(_ sender: PrismSelector) {
        ModesViewController.selectorArray.add(sender)
    }

    func didDeselect(_ sender: PrismSelector) {
        ModesViewController.selectorArray.remove(sender)
    }
}

// MARK: Reactive delegate

extension ModesViewController: ColorViewDelegate {
    func didSelect(_ sender: ColorView) {
        ModesViewController.selectorArray.add(sender)
    }

    func didDeselect(_ sender: ColorView) {
        ModesViewController.selectorArray.remove(sender)
    }
}

// MARK: Button sidebar delegate

protocol ModesViewControllerDelegate: AnyObject {
    func didClickOnPresetsButton()
}

// MARK: Identifiers

private extension NSUserInterfaceItemIdentifier {
    static let speed = NSUserInterfaceItemIdentifier(rawValue: "speed-slider")
    static let pulse = NSUserInterfaceItemIdentifier(rawValue: "pulse-slider")
    static let waveToggle = NSUserInterfaceItemIdentifier(rawValue: "wave")
    static let origin = NSUserInterfaceItemIdentifier(rawValue: "origin")
    static let xyDirection = NSUserInterfaceItemIdentifier(rawValue: "xy-direction")
    static let inwardOutward = NSUserInterfaceItemIdentifier(rawValue: "inward-outward")
    static let presets = NSUserInterfaceItemIdentifier(rawValue: "presets")
}
