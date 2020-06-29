//
//  ASSegmentedControl.swift
//  ASSegmentedControl
//
//  Created by Aleksei Smirnov on 26.06.2020.
//  Copyright © 2020 Aleksei Smirnov. All rights reserved.
//

import UIKit

struct ASSegmentedControlViewModel: ViewModelProtocol {
    let items: [UIView]
}

@IBDesignable
final class ASSegmentedControl: UIControl {

    // MARK: - Public Properties

    public var thumbColor = UIColor(red: 227/255, green: 228/255, blue: 230/255, alpha: 1.0)
    public var thumbInset: CGFloat = 2.0
    public var cornerRadius: CGFloat = 10

    // MARK: - Private Properties

    private var items: [UIView] = [] {
        didSet {
            layoutItemViews()
            selectedSegmentIndex = 0
            thumbView.frame = frameForSegmentAtIndex(selectedSegmentIndex)
        }
    }

    private(set) var selectedSegmentIndex = 0 {
        willSet { assert(newValue >= 0) }
    }

    public var numberOfSegments: Int {
        return items.count
    }

    private var segmentWidth: CGFloat {
        (bounds.size.width - CGFloat(numberOfSegments)*thumbInset) / CGFloat(numberOfSegments)
    }

    private var isDraggingThumbView = false
    private var focusedIndex: Int = -1
    private let trackView = UIView()
    private let thumbView = UIView()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        trackView.frame = bounds
        trackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        trackView.layer.masksToBounds = true
        trackView.isUserInteractionEnabled = false
        trackView.backgroundColor = .white
        trackView.layer.cornerRadius = cornerRadius
        trackView.clipsToBounds = true
        if #available(iOS 13.0, *) {
            trackView.layer.cornerCurve = .continuous
        }
        addSubview(trackView)

        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = cornerRadius
        if #available(iOS 13.0, *) {
            thumbView.layer.cornerCurve = .continuous
        }
        trackView.addSubview(thumbView)

        addTarget(self, action: #selector(didTapDown(_:event:)), for: .touchDown)
        addTarget(self, action: #selector(didDragTap(_:event:)), for: .touchDragInside)
        addTarget(self, action: #selector(didDragTap(_:event:)), for: .touchDragOutside)
        addTarget(self, action: #selector(didExitTapBounds(_:event:)), for: .touchDragExit)
        addTarget(self, action: #selector(didEnterTapBounds(_:event:)), for: .touchDragEnter)
        addTarget(self, action: #selector(didEndTap(_:event:)), for: .touchUpInside)
        addTarget(self, action: #selector(didEndTap(_:event:)), for: .touchUpOutside)
        addTarget(self, action: #selector(didEndTap(_:event:)), for: .touchCancel)

    }

    // MARK: - Private Methods

    @objc private func didTapDown(_ control: UIControl, event: UIEvent) {
        guard let tapPoint = event.allTouches?.first?.location(in: self) else { return }
        let tappedIndex = segmentedIndexFor(point: tapPoint)

        isDraggingThumbView = tappedIndex == selectedSegmentIndex
        focusedIndex = tappedIndex

        if !isDraggingThumbView {
            UIView.animate(withDuration: 0.35, animations: {
                self.setItem(at: tappedIndex, isFaded: true)
            })
        }
    }

    @objc private func didDragTap(_ control: UIControl, event: UIEvent) {

        guard let tapPoint = event.allTouches?.first?.location(in: self) else { return }

        let tappedIndex = segmentedIndexFor(point: tapPoint)

        if tappedIndex == focusedIndex { return }

        if !isDraggingThumbView {

            if focusedIndex < 0 { return }

            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                self.setItem(at: self.focusedIndex, isFaded: false)
                if tappedIndex != self.selectedSegmentIndex {
                    self.setItem(at: tappedIndex, isFaded: true)
                }
            }, completion: nil)

            focusedIndex = tappedIndex
            return
        }

        selectSegment(at: tappedIndex, animated: true)

        focusedIndex = tappedIndex
    }

    @objc private func didEnterTapBounds(_ control: UIControl, event: UIEvent) {

        guard
            !isDraggingThumbView,
            let tapPoint = event.allTouches?.first?.location(in: self)
        else { return }

        focusedIndex = segmentedIndexFor(point: tapPoint)

        UIView.animate(withDuration: 0.45, delay: 0, options: .beginFromCurrentState, animations: {
            self.setItem(at: self.focusedIndex, isFaded: true)
        }, completion: nil)
    }

    @objc private func didExitTapBounds(_ control: UIControl, event: UIEvent) {

        guard isDraggingThumbView else { return }

        UIView.animate(withDuration: 0.45, delay: 0, options: .beginFromCurrentState, animations: {
            self.setItem(at: self.focusedIndex, isFaded: false)
        }, completion: nil)

        focusedIndex = -1
    }

    @objc private func didEndTap(_ control: UIControl, event: UIEvent) {

        guard let touch = event.allTouches?.first else { return }
        let isCancelled = touch.phase == .cancelled

        let tapPoint = touch.location(in: self)
        let tappedIndex = segmentedIndexFor(point: tapPoint)

        if !isDraggingThumbView {

            if !isCancelled {
                selectSegment(at: tappedIndex, animated: true)
            } else {
                didExitTapBounds(self, event: event)
            }

            focusedIndex = -1
            return
        }

        if selectedSegmentIndex != tappedIndex {
            selectedSegmentIndex = tappedIndex
            sendIndexChangedEventActions()
        }

        focusedIndex = -1
    }

    private func set(items: [UIView]) {
        self.items = items
    }

    private func layoutItemViews() {
        for (index, itemView) in items.enumerated() {
            trackView.addSubview(itemView)
            itemView.frame = frameForSegmentAtIndex(index)

            if index == items.startIndex {
                itemView.roundCorners(corners: [.bottomLeft, .topLeft], radius: cornerRadius)
            }

            if index == items.endIndex - 1 {
                itemView.roundCorners(corners: [.bottomRight, .topRight], radius: cornerRadius)
            }

            itemView.clipsToBounds = true
        }
    }

    private func frameForSegmentAtIndex(_ index: Int) -> CGRect {
        let extra = index == items.startIndex ? thumbInset : 0
        let frame = CGRect(x: extra + (segmentWidth + thumbInset) * CGFloat(index),
                           y: thumbInset, width: segmentWidth,
                           height: bounds.height - thumbInset * 2)
        return frame
    }

    private func setItem(at index: Int, isFaded: Bool) {
        let view = items[index]
        view.alpha = isFaded ? 0.3 : 1
    }

    private func selectSegment(at index: Int, animated: Bool) {

        guard selectedSegmentIndex != index else { return }

        selectedSegmentIndex = index

        if selectedSegmentIndex >= 0 && selectedSegmentIndex < items.endIndex {
            sendIndexChangedEventActions()
        }

        if !animated {
            setNeedsLayout()
            return
        }

        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 2,
                       options: .beginFromCurrentState,
                       animations: {

                        for (index, _) in self.items.enumerated() {
                            self.setItem(at: index, isFaded: false)
                        }

                        self.thumbView.frame = self.frameForSegmentAtIndex(self.selectedSegmentIndex)

        }, completion: nil)
    }

    private func sendIndexChangedEventActions() {
        sendActions(for: .valueChanged)
    }

    private func segmentedIndexFor(point: CGPoint) -> Int {
        var segment = Int(point.x / segmentWidth)
        segment = min(max(segment, 0), numberOfSegments - 1)
        return segment
    }
}

extension ASSegmentedControl: Configurable {

    typealias ViewModel = ASSegmentedControlViewModel

    func configure(model: ASSegmentedControlViewModel) {
        assert(!model.items.isEmpty)
        set(items: model.items)
    }

}
