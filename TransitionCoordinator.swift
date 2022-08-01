//
//  TransitionCoordinator.swift
//  ExpandingCollasingViews
//
//  Created by Rani Ophir on 27/07/2022.
//  Copyright © 2022 MichiganLabs. All rights reserved.
//

import UIKit

class TransitionCoordinator: NSObject {
 
    private weak var mainViewController: CollectionViewController!
    private weak var detailViewController: DetailViewController!
    
    private var transitionDuration = 2.0
    
    private lazy var panGestureRecognizer = createPanGestureRecognizer()
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    init(mainViewController: CollectionViewController, detailViewController: DetailViewController) {
        self.mainViewController = mainViewController
        self.detailViewController = detailViewController
        super.init()
        detailViewController.view.addGestureRecognizer(panGestureRecognizer)
        runningAnimators = createTransitionAnimators()
    }
}

extension TransitionCoordinator {
    
    @objc private func didPanView(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view!)
        print("In didPanView ", translation)
        
//        runningAnimators.startAnimations()
        
        switch recognizer.state {
            case .began:
                runningAnimators.startAnimations()
                runningAnimators.pauseAnimations();
//                startInteractiveTransition()
            case .changed:
//                let translation = recognizer.translation(in: recognizer.view!)
                updateInteractiveTransition(distanceTraveled: translation.x)
            case .ended:
//                let velocity = recognizer.velocity(in: recognizer.view!).y
//                let isCancelled = isGestureCancelled(with: velocity)
                runningAnimators.continueAnimations()
            case .cancelled, .failed:
            print("hello")
//                continueInteractiveTransition(cancel: true)
            default:
                break
        }
    }
    
    private func animateTransition() {
        
    }
    
    // Scrubs transition on pan .changed
    private func updateInteractiveTransition(distanceTraveled: CGFloat) {
        var fraction = distanceTraveled / 150
        fraction *= -1;
        
//        if state == .open { fraction *= -1 }
        runningAnimators.fractionComplete = fraction
    }
    
    private func stopInteractiveAnimation() {
        
    }
    
    private func createTransitionAnimators() -> [UIViewPropertyAnimator] {
        let animator: UIViewPropertyAnimator = createSizeAnimator();
        return [animator];
    }
    
    private func createPositionAnimator() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 2, curve: .linear);
    }
    
    private func createSizeAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: self.transitionDuration, curve: .linear)
        let detailViewController: UIViewController = self.detailViewController
        animator.addAnimations {
            detailViewController.view.frame.size = CGSize(width: 100, height: 100)
            detailViewController.view.layoutIfNeeded()

                        // Move the view in the X direction. We concatinate here because we do not want to overwrite our
                        // previous transformation
//            self.transform = fromView.transform.concatenating(CGAffineTransform(translationX: xDiff, y: 0))
        }
        animator.scrubsLinearly = false
        return animator;
    }
    
}

extension TransitionCoordinator {
    
    @objc private func didPanViewDraggable(recoginzer: UIPanGestureRecognizer) {
        
        print("scroll view offset: ", self.detailViewController.scrollView.contentOffset.y);
        
        let draggingView = recoginzer.view!
        let translation = recoginzer.translation(in: recoginzer.view!)
        
        print("In didPanViewDraggable ", translation)
        
        draggingView.layer.masksToBounds = true
        draggingView.layer.cornerRadius = 30;
        
        
        switch recoginzer.state {
        case .began, .changed:
            print("changed")
            self.detailViewController.scrollView.isScrollEnabled = false
            
//            draggingView.layer.masksToBounds = true
//            draggingView.layer.cornerRadius = 30;
            if #available(iOS 13.0, *) {
              draggingView.layer.cornerCurve = .continuous
            } else {
              // Fallback on earlier versions
            }
            
            let movingAnimator = UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1)
                          
            movingAnimator.addAnimations {
                // The reason why it uses `layer` is prevent layout in safe-area.
                draggingView.layer.position.x += translation.x
                draggingView.layer.position.y += translation.y
                draggingView.layer.cornerRadius = 32
            }

            movingAnimator.startAnimation()
            recoginzer.setTranslation(.zero, in: draggingView)
            
        case .ended:
            print("ended")
            
            self.detailViewController.scrollView.isScrollEnabled = false
            
            let velocity = recoginzer.velocity(in: recoginzer.view)

            let originalCenter = CGPoint(x: draggingView.bounds.midX, y: draggingView.bounds.midY)
            let distanceFromCenter = CGPoint(
                x: originalCenter.x - draggingView.center.x,
                y: originalCenter.y - draggingView.center.y
            )
            
            let shouldExit =
                abs(distanceFromCenter.x) > 80 || abs(distanceFromCenter.y) > 80
                || abs(velocity.x) > 100 || abs(velocity.y) > 100
            
            if(shouldExit) {
                self.disminssTransition()
            } else {
                
                let animator = UIViewPropertyAnimator(
                    duration: 0.62,
                    timingParameters: UISpringTimingParameters(
                        dampingRatio: 0.9,
                        initialVelocity: .zero
                    )
                )
                
                animator.addAnimations {
                    draggingView.center = .init(
                        x: draggingView.bounds.width / 2,
                        y: draggingView.bounds.height / 2
                    )
                    draggingView.transform = .identity
                    draggingView.layer.cornerRadius = 0
                }
                
                animator.startAnimation()
            }
            
        case .cancelled, .failed:
            self.detailViewController.scrollView.isScrollEnabled = true
            
            draggingView.center = CGPoint(
                x: draggingView.bounds.width / 2,
                y: draggingView.bounds.height / 2
            )
            draggingView.transform = .identity
            draggingView.layer.cornerRadius = 0
            
            
        default:
            break
        }
    }
    
    
    
}

extension TransitionCoordinator: UIGestureRecognizerDelegate {
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return self.detailViewController.scrollView.contentOffset.y == 0
//    }
    
    //make the gesture recognizer work with the scroll view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    private func createPanGestureRecognizer() -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(didPanViewDraggable(recoginzer:)))
        recognizer.delegate = self
        return recognizer
    }
}

extension TransitionCoordinator {
    
    func presentTransition() {
        let container = mainViewController.view

        // ===========================================================
        // Step 1: Get the views we are animating
        // ===========================================================

        // Views we are animating FROM
        guard
            let fromVC = self.mainViewController as? Animatable,
            let fromContainer = fromVC.containerView,
            let fromChild = fromVC.childView
        else {
            return
        }

        // Views we are animating TO
        guard
            let toVC = self.detailViewController as? Animatable,
            let toView = toVC.containerView
        else {
            return
        }

        // Preserve the original frame of the toView
        let originalFrame = toView.frame

        container!.addSubview(toView)

        // ===========================================================
        // Step 2: Determine start and end points for animation
        // ===========================================================

        // Get the coordinates of the view inside the container
        let originFrame = CGRect(
            origin: fromContainer.convert(fromChild.frame.origin, to: container),
            size: fromChild.frame.size
        )
        let destinationFrame = toView.frame

        toView.frame = originFrame
        toView.layoutIfNeeded()

        fromChild.isHidden = true

        // ===========================================================
        // Step 3: Perform the animation
        // ===========================================================

        let yDiff = destinationFrame.origin.y - originFrame.origin.y
        let xDiff = destinationFrame.origin.x - originFrame.origin.x

        // For the duration of the animation, we are moving the frame. Therefore we have a separate animator
        // to just control the Y positioning of the views. We will also use this animator to determine when
        // all of our animations are done.

        // Animate the card's vertical position
        let positionAnimator = UIViewPropertyAnimator(duration: self.transitionDuration, dampingRatio: 0.95)
        positionAnimator.addAnimations {
            // Move the view in the Y direction
            toView.transform = CGAffineTransform(translationX: 0, y: yDiff)
        }

        // Animate the card's size
        let sizeAnimator = UIViewPropertyAnimator(duration: self.transitionDuration, curve: .easeInOut)
        sizeAnimator.addAnimations {
            // Animate the size of the Card View
            toView.frame.size = destinationFrame.size
            toView.layoutIfNeeded()

            // Move the view in the X direction. We concatenate here because we do not want to overwrite our
            // previous transformation
            toView.transform = toView.transform.concatenating(CGAffineTransform(translationX: xDiff, y: 0))
        }

        // Call the animation delegate
        toVC.presentingView(
            sizeAnimator: sizeAnimator,
            positionAnimator: positionAnimator,
            fromFrame: originFrame,
            toFrame: destinationFrame
        )

        // Animation completion.
        let completionHandler: (UIViewAnimatingPosition) -> Void = { _ in
            toView.transform = .identity
            toView.frame = originalFrame

            toView.layoutIfNeeded()

            fromChild.isHidden = false

//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

//        // Put the completion handler on the longest lasting animator
//        if (self.positioningDuration > self.resizingDuration) {
//            positionAnimator.addCompletion(completionHandler)
//        } else {
            sizeAnimator.addCompletion(completionHandler)
//        }

        // Kick off the two animations
        positionAnimator.startAnimation()
        sizeAnimator.startAnimation()
    }
    
    func disminssTransition() {
        let container = self.mainViewController.view

       // ===========================================================
       // Step 1: Get the views we are animating
       // ===========================================================

       // Views we are animating FROM
       guard
        let fromVC = self.detailViewController as? Animatable,
        let fromView = fromVC.containerView
       else {
           return
       }

       // Views we are animating TO
       guard
        let toVC = self.mainViewController as? Animatable,
        let toView = self.mainViewController.view,
           let toContainer = toVC.containerView,
           let toChild = toVC.childView
       else {
           return
       }
        
//       container!.addSubview(toView)
//       container!.addSubview(fromView)

       // ===========================================================
       // Step 2: Determine start and end points for animation
       // ===========================================================

       // Get the coordinates of the view inside the container
       let originFrame = fromView.frame
       let destinationFrame = CGRect(
           origin: toContainer.convert(toChild.frame.origin, to: container),
           size: toChild.frame.size
       )

       toChild.isHidden = true

       // ===========================================================
       // Step 3: Perform the animation
       // ===========================================================

       let yDiff = destinationFrame.origin.y - originFrame.origin.y
       let xDiff = destinationFrame.origin.x - originFrame.origin.x

       // For the duration of the animation, we are moving the frame. Therefore we have a separate animator
       // to just control the Y positioning of the views. We will also use this animator to determine when
       // all of our animations are done.
       let positionAnimator = UIViewPropertyAnimator(duration: self.transitionDuration, dampingRatio: 0.95)
       positionAnimator.addAnimations {
           // Move the view in the Y direction
           fromView.transform = CGAffineTransform(translationX: 0, y: yDiff)
       }

       let sizeAnimator = UIViewPropertyAnimator(duration: self.transitionDuration, curve: .easeInOut)
       sizeAnimator.addAnimations {
           fromView.frame.size = destinationFrame.size
           fromView.layoutIfNeeded()

           // Move the view in the X direction. We concatinate here because we do not want to overwrite our
           // previous transformation
           fromView.transform = fromView.transform.concatenating(CGAffineTransform(translationX: xDiff, y: 0))
       }

       // Call the animation delegate
       fromVC.dismissingView(
           sizeAnimator: sizeAnimator,
           positionAnimator: positionAnimator,
           fromFrame: originFrame,
           toFrame: destinationFrame
       )

       // Animation completion.
       let completionHandler: (UIViewAnimatingPosition) -> Void = { _ in
           fromView.removeFromSuperview()
           toChild.isHidden = false

//           transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
       }

       // Put the completion handler on the longest lasting animator
//       if (self.positioningDuration > self.resizingDuration) {
//           positionAnimator.addCompletion(completionHandler)
//       } else {
           sizeAnimator.addCompletion(completionHandler)
//       }

       // Kick off the two animations
       positionAnimator.startAnimation()
       sizeAnimator.startAnimation()
    }
    
}
