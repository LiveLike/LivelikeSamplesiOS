//
//  WidgetTitleView.swift
//  LiveLikeSDK
//
//  Created by Heinrich Dahms on 2019-01-31.
//

import Lottie
import UIKit

class WidgetTitleView: UIView {
    // MARK: Private Properties

    private let animationViewSize: CGFloat = 18.0
    private var lottieView: LottieAnimationView?

    // MARK: UI Properties

    let widgetTag: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

//    var closeButton: UIButton = {
//        let image = UIImage(named: "widget_close", in: TF1Sample., compatibleWith: nil)
//        let button = UIButton(type: .custom)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.imageView?.contentMode = .scaleAspectFit
//        button.setImage(image, for: .normal)
//        return button
//    }()

    private var titleLeadingConstraint: NSLayoutConstraint!
    private var titleTrailingConstraint: NSLayoutConstraint!
    private var titleTopConstraint: NSLayoutConstraint!
    private var titleBottomConstraint: NSLayoutConstraint!

    private var widgetTagTopConstraint: NSLayoutConstraint!
    private var widgetTagLeadingConstraint: NSLayoutConstraint!
    private var widgetTagTrailingConstraint: NSLayoutConstraint!
    private var widgetTagBottomConstraint: NSLayoutConstraint!

    var titleMargins: UIEdgeInsets = .zero {
        didSet {
            titleLeadingConstraint.constant = titleMargins.left
            titleTrailingConstraint.constant = titleMargins.right
            titleTopConstraint.constant = titleMargins.top
            titleBottomConstraint.constant = titleMargins.bottom
        }
    }

    var widgetTagMargins: UIEdgeInsets = .zero {
        didSet {
            widgetTagTopConstraint.constant = widgetTagMargins.top
            widgetTagLeadingConstraint.constant = widgetTagMargins.left
            widgetTagTrailingConstraint.constant = widgetTagMargins.right
            widgetTagBottomConstraint.constant = widgetTagMargins.bottom
        }
    }

    private lazy var animationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var timerDuration: TimeInterval?
    private var interactionTimer: Timer?

    var closeButtonAction: () -> Void = { }

    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        configure()
    }


    // MARK: Private Functions - View Setup

    private func configure() {
        addSubview(widgetTag)
        configureAnimationView()
        configureTitleLabel()
        configureLayout()
//        closeButton.addTarget(self, action: #selector(closeButtonSelected), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(didMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func didMoveToForeground() {
        // Restart the timer animation from continuous time since background
        // We need to do this because when Lottie goes into background it pauses the animation
        if
            let interactionTimer = interactionTimer,
            let lottieView = lottieView,
            let lottieAnimation = lottieView.animation,
            let duration = timerDuration
        {
            let timeRemaining = interactionTimer.fireDate.timeIntervalSince(Date())
            let timeScalar = lottieAnimation.duration / duration

            lottieView.currentTime = (duration - timeRemaining) * timeScalar
            lottieView.play()
        }
    }

    private func configureTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .left
    }

    private func configureAnimationView() {
        addSubview(animationView)
    }

    func cancelTimer() {
        interactionTimer?.invalidate()
        lottieView?.stop()
        lottieView?.isHidden = true
    }

    func beginTimer(duration: Double, animationFilepath: String, completion: (() -> Void)? = nil) {
        timerDuration = duration
        interactionTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { _ in
            completion?()
        })

        let lottieView = LottieAnimationView(filePath: animationFilepath)
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.contentMode = .scaleAspectFit

        if let animationDuration = lottieView.animation?.duration, duration > 0 {
            lottieView.animationSpeed = CGFloat(animationDuration / duration)
        }

        animationView.addSubview(lottieView)

        // animationViewSize
        let constraints = [
            animationView.centerXAnchor.constraint(equalTo: lottieView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: lottieView.centerYAnchor),
            lottieView.heightAnchor.constraint(equalToConstant: animationViewSize),
            lottieView.widthAnchor.constraint(equalToConstant: animationViewSize)
        ]

        NSLayoutConstraint.activate(constraints)

        lottieView.play { finished in
            if finished {
                lottieView.isHidden = true
            }
        }

        self.lottieView = lottieView
    }

//    func showCloseButton() {
//        animationView.addSubview(closeButton)
//        closeButton.constraintsFill(to: animationView)
//    }

    func beginTimer(duration: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion)
    }

    @objc private func closeButtonSelected() {
        self.closeButtonAction()
    }

    private func configureLayout() {

        titleBottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: widgetTag.bottomAnchor)
        titleLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        titleTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: animationView.leadingAnchor)

        widgetTagTopConstraint = widgetTag.topAnchor.constraint(equalTo: topAnchor)
        widgetTagLeadingConstraint = widgetTag.leadingAnchor.constraint(equalTo: leadingAnchor)
        widgetTagTrailingConstraint = widgetTag.trailingAnchor.constraint(equalTo: animationView.leadingAnchor)
        widgetTagBottomConstraint = widgetTag.bottomAnchor.constraint(equalTo: titleLabel.topAnchor)

        // Title Label
        let constraints: [NSLayoutConstraint] = [

            widgetTag.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),

            widgetTagTopConstraint,
            widgetTagLeadingConstraint,
            widgetTagTrailingConstraint,
            widgetTagBottomConstraint,

            titleLeadingConstraint,
            titleTrailingConstraint,
            titleTopConstraint,
            titleBottomConstraint,

            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 32),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
