//
//  EmojiSlider.swift
//  nthLink
//
//  Created for VPN connection quality indicator
//

import UIKit

class EmojiSlider: UIView {

    // MARK: - Properties
    private let gradientLayer = CAGradientLayer()
    private let sliderTrack = UIView()
    private let borderView = UIView()
    private let selectionIndicator = UIView()
    private let metallicGradientLayer = CAGradientLayer()
    private var emojiLabels: [UILabel] = []

    // Slider configuration
    private let trackHeight: CGFloat = 36
    private let sliderBorderWidth: CGFloat = 3
    private let selectionIndicatorWidth: CGFloat = 40
    private let selectionIndicatorHeight: CGFloat = 50
    private let selectionIndicatorCornerRadius: CGFloat = 9
    private let horizontalPadding: CGFloat = 20
    private let emojiInset: CGFloat = 40

    // Emojis for each step
    private let emojis = ["😡", "☹️", "😐", "🙂", "😊"]

    // Current value (0-4 representing the 5 steps)
    var currentStep: Int = 2 {
        didSet {
            updateSelectionIndicator()
        }
    }

    // Interaction enabled/disabled
    var isInteractionEnabled: Bool = true

    // Callback for value changes
    var onValueChanged: ((Int) -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = false

        // Setup border view first (background layer)
        setupBorderView()

        // Setup slider track
        setupSliderTrack()

        // Setup gradient
        setupGradient()

        // Setup emojis
        setupEmojis()

        // Setup selection indicator
        setupSelectionIndicator()
    }

    private func setupBorderView() {
        borderView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.3)
        borderView.layer.cornerRadius = (trackHeight + sliderBorderWidth * 2) / 2

        // Add subtle shadow to the border view
        borderView.layer.shadowColor = UIColor.black.cgColor
        borderView.layer.shadowOpacity = 0.08
        borderView.layer.shadowOffset = CGSize(width: 0, height: 2)
        borderView.layer.shadowRadius = 4
        borderView.layer.masksToBounds = false

        addSubview(borderView)
    }

    private func setupSliderTrack() {
        sliderTrack.backgroundColor = .clear
        sliderTrack.layer.cornerRadius = trackHeight / 2
        sliderTrack.layer.masksToBounds = true
        addSubview(sliderTrack)
    }

    private func setupGradient() {
        // Colors from red to green matching the design
        let colors: [CGColor] = [
            UIColor(red: 0.90, green: 0.30, blue: 0.25, alpha: 1.0).cgColor,  // Red
            UIColor(red: 0.95, green: 0.50, blue: 0.25, alpha: 1.0).cgColor,  // Orange
            UIColor(red: 0.98, green: 0.78, blue: 0.28, alpha: 1.0).cgColor,  // Yellow
            UIColor(red: 0.68, green: 0.85, blue: 0.40, alpha: 1.0).cgColor,  // Light green
            UIColor(red: 0.35, green: 0.78, blue: 0.48, alpha: 1.0).cgColor   // Green
        ]

        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        sliderTrack.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupEmojis() {
        for i in 0..<5 {
            let label = UILabel()
            label.text = emojis[i]
            label.font = .systemFont(ofSize: 22)
            label.textAlignment = .center
            sliderTrack.addSubview(label)
            emojiLabels.append(label)
        }
    }

    private func setupSelectionIndicator() {
        // Rounded rectangle that overlaps the slider track (like engineering slider)
        selectionIndicator.backgroundColor = .clear

        // Create metallic gradient frame layer
        metallicGradientLayer.cornerRadius = selectionIndicatorCornerRadius
        metallicGradientLayer.colors = [
            UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0).cgColor,   // Bright white silver (top)
            UIColor(red: 0.88, green: 0.88, blue: 0.92, alpha: 1.0).cgColor,  // Light silver
            UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0).cgColor,  // Bright highlight
            UIColor(red: 0.82, green: 0.82, blue: 0.86, alpha: 1.0).cgColor,  // Medium silver
            UIColor(red: 0.75, green: 0.75, blue: 0.80, alpha: 1.0).cgColor   // Dark shadow (bottom)
        ]
        metallicGradientLayer.locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        metallicGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        metallicGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        selectionIndicator.layer.addSublayer(metallicGradientLayer)

        // Create inner mask to make it hollow (transparent center)
        let innerMaskLayer = CAShapeLayer()
        innerMaskLayer.fillRule = .evenOdd
        metallicGradientLayer.mask = innerMaskLayer

        // Strong shadow on the outside
        selectionIndicator.layer.shadowColor = UIColor.black.cgColor
        selectionIndicator.layer.shadowOpacity = 0.7
        selectionIndicator.layer.shadowOffset = CGSize(width: 0, height: 5)
        selectionIndicator.layer.shadowRadius = 10
        selectionIndicator.layer.masksToBounds = false

        // Add to main view so it can extend beyond track bounds
        addSubview(selectionIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let trackY: CGFloat = 5

        // Layout border view (white background with shadow)
        borderView.frame = CGRect(
            x: horizontalPadding - sliderBorderWidth,
            y: trackY - sliderBorderWidth,
            width: bounds.width - (horizontalPadding * 2) + (sliderBorderWidth * 2),
            height: trackHeight + (sliderBorderWidth * 2)
        )
        borderView.layer.cornerRadius = (trackHeight + sliderBorderWidth * 2) / 2

        // Layout slider track with padding
        sliderTrack.frame = CGRect(
            x: horizontalPadding,
            y: trackY,
            width: bounds.width - (horizontalPadding * 2),
            height: trackHeight
        )

        // Update gradient frame and corner radius
        gradientLayer.frame = sliderTrack.bounds
        gradientLayer.cornerRadius = trackHeight / 2

        // Layout emojis with proper spacing
        let trackWidth = sliderTrack.bounds.width
        let usableWidth = trackWidth - (emojiInset * 2)
        let emojiSize: CGFloat = 32

        for (index, label) in emojiLabels.enumerated() {
            let xPosition: CGFloat
            if index == 0 {
                xPosition = emojiInset
            } else if index == 4 {
                xPosition = trackWidth - emojiInset
            } else {
                let segmentWidth = usableWidth / 4
                xPosition = emojiInset + (segmentWidth * CGFloat(index))
            }

            label.frame = CGRect(
                x: xPosition - (emojiSize / 2),
                y: (trackHeight - emojiSize) / 2,
                width: emojiSize,
                height: emojiSize
            )
        }

        updateSelectionIndicator(animated: false)
    }

    private func updateSelectionIndicator(animated: Bool = true) {
        let trackWidth = sliderTrack.bounds.width
        let usableWidth = trackWidth - (emojiInset * 2)
        let trackY: CGFloat = 5

        let xPosition: CGFloat
        if currentStep == 0 {
            xPosition = horizontalPadding + emojiInset
        } else if currentStep == 4 {
            xPosition = horizontalPadding + trackWidth - emojiInset
        } else {
            let segmentWidth = usableWidth / 4
            xPosition = horizontalPadding + emojiInset + (segmentWidth * CGFloat(currentStep))
        }

        // Position indicator to overlap the slider track (extends beyond top and bottom)
        let indicatorFrame = CGRect(
            x: xPosition - (selectionIndicatorWidth / 2),
            y: trackY + (trackHeight - selectionIndicatorHeight) / 2,
            width: selectionIndicatorWidth,
            height: selectionIndicatorHeight
        )

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.selectionIndicator.frame = indicatorFrame
                self.updateMetallicFrame()
            }
        } else {
            selectionIndicator.frame = indicatorFrame
            updateMetallicFrame()
        }
    }

    private func updateMetallicFrame() {
        // Update gradient layer to fill indicator
        metallicGradientLayer.frame = selectionIndicator.bounds

        // Create hollow metallic frame (transparent center)
        let outerPath = UIBezierPath(roundedRect: selectionIndicator.bounds,
                                      cornerRadius: selectionIndicatorCornerRadius)

        // Inner rectangle (hollow part) - 7px border width
        let borderWidth: CGFloat = 7
        let innerRect = selectionIndicator.bounds.insetBy(dx: borderWidth, dy: borderWidth)
        let innerPath = UIBezierPath(roundedRect: innerRect,
                                      cornerRadius: selectionIndicatorCornerRadius - borderWidth)

        outerPath.append(innerPath)

        if let maskLayer = metallicGradientLayer.mask as? CAShapeLayer {
            maskLayer.path = outerPath.cgPath
        }
    }

    private func getEmojiXPosition(for step: Int) -> CGFloat {
        let trackWidth = sliderTrack.bounds.width
        let usableWidth = trackWidth - (emojiInset * 2)

        if step == 0 {
            return horizontalPadding + emojiInset
        } else if step == 4 {
            return horizontalPadding + trackWidth - emojiInset
        } else {
            let segmentWidth = usableWidth / 4
            return horizontalPadding + emojiInset + (segmentWidth * CGFloat(step))
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled else { return }
        handleTouch(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled else { return }
        handleTouch(touches)
    }

    private func handleTouch(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Find the closest emoji position
        var closestStep = 0
        var minDistance: CGFloat = .infinity

        for step in 0...4 {
            let emojiX = getEmojiXPosition(for: step)
            let distance = abs(location.x - emojiX)

            if distance < minDistance {
                minDistance = distance
                closestStep = step
            }
        }

        if closestStep != currentStep {
            currentStep = closestStep
            onValueChanged?(currentStep)
        }
    }

    override var intrinsicContentSize: CGSize {
        // Height needs to accommodate the taller selection indicator
        return CGSize(width: UIView.noIntrinsicMetric, height: selectionIndicatorHeight + 10)
    }
}
