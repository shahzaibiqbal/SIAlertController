//
//  SIAlertController
//
//  Created by shahzaib iqbal on 12/16/16.
//  Copyright © 2016 shahzaib iqbal. All rights reserved.
//

import UIKit
enum PresentationStyle: String {
    case actionSheet, alertView
}
class SIAlertController: UIViewController, UIViewControllerTransitioningDelegate, CustomPresentationDelegate {
    
    var prefreredPresentationStyle: PresentationStyle = .alertView
    var enableTouchDissmiss: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if(self.responds(to: #selector(setter: UIViewController.transitioningDelegate)))
        {
            self.modalPresentationStyle = UIModalPresentationStyle.custom
            self.transitioningDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.preferredContentSize == .zero {
            self.preferredContentSize = self.view.frame.size
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    open func viewWillDismiss() {
    }
    func userTappedOnView() {
        if self.prefreredPresentationStyle == .actionSheet || self.enableTouchDissmiss {
            self.dismiss(animated: true, completion: nil)
        }
    }
    //MARK: - custom Animation methods
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimationController(style: prefreredPresentationStyle)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting, presentationStyle: prefreredPresentationStyle, delegate: self)
    } 
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.viewWillDismiss()
        if prefreredPresentationStyle == .alertView {
            return DismissAnimationController()
        }
        else {
            return nil
        }
    }
}
//MARK: - custom RoundRectPresentationController
protocol CustomPresentationDelegate {
    func userTappedOnView()
}
class CustomPresentationController : UIPresentationController {
    var dimmingView: UIView!
    var customDelegate: CustomPresentationDelegate!
    
    private var currentStyle: PresentationStyle!
    private var kbHeight: CGFloat = 0
    private var isTransitionDone: Bool = false
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, presentationStyle: PresentationStyle, delegate d: CustomPresentationDelegate) {
        self.customDelegate = d
        currentStyle = presentationStyle
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomPresentationController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CustomPresentationController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    func initDimmingView()
    {
        if(self.dimmingView == nil)
        {
            dimmingView = UIView(frame: (self.containerView?.bounds)!)
            dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(gestureHandler(gesture:)))
            dimmingView.addGestureRecognizer(gesture)
        }
    }
    @objc func gestureHandler(gesture: UITapGestureRecognizer) {
        customDelegate.userTappedOnView()
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardSize =  (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        if !isTransitionDone {
            return
        }
        kbHeight = (keyboardSize?.height)!
        if ((self.presentedView?.frame.origin.y)! + (self.presentedView?.frame.size.height)!) > (keyboardSize?.origin.y)! {
            let expectedy = self.containerView!.frame.size.height - (self.presentedView?.frame.size.height)! - kbHeight - 10
            let expectCenter = expectedy + ((self.presentedView?.frame.size.height)! / 2)
            self.presentedView!.center = CGPoint(x: self.presentedView!.center.x, y: expectCenter)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if !isTransitionDone {
            return
        }
        kbHeight = 0
        UIView.animate(withDuration: 0.3) { 
            self.presentedView?.center = (self.containerView?.center)!
        }
    }
    override func presentationTransitionWillBegin() {
        self.isTransitionDone = false
        self.initDimmingView()
        self.dimmingView.frame = self.containerView!.bounds
        self.dimmingView.alpha = 0
        self.containerView!.addSubview(self.dimmingView)
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) -> Void in
            self.dimmingView.alpha = 1.0
        }, completion: { (context) -> Void in
            
        })
    }
    override func presentationTransitionDidEnd(_ completed: Bool) {
        self.isTransitionDone = true
        if(!completed)
        {
            self.dimmingView.removeFromSuperview()
        }
    }
    override func dismissalTransitionWillBegin() {
        self.isTransitionDone = false
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) -> Void in
            self.dimmingView.alpha = 0.0
        }, completion: { (context) -> Void in
            
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if(completed)
        {
            self.dimmingView.removeFromSuperview()
        }
    }
    
    private func frameOfPresentedViewInContainerView(size: CGSize) -> CGRect {
        let sizeWidth: CGFloat = self.presentedViewController.preferredContentSize.width
        let sizeHeight: CGFloat = self.presentedViewController.preferredContentSize.height
        var frame: CGRect!
        if currentStyle == .alertView {
            var expectY: CGFloat = 0
            expectY = (size.height - sizeHeight) / 2
            if kbHeight > 0 {
                expectY = size.height - sizeHeight - kbHeight - 10
            }
            frame = CGRect(x: (size.width - sizeWidth) / 2, y: expectY, width: sizeWidth, height: sizeHeight)
        }
        else {
            frame = CGRect(x: (size.width - sizeWidth) / 2, y: size.height - sizeHeight, width: sizeWidth, height: sizeHeight)
        }
        return frame
    }
    override func containerViewWillLayoutSubviews() {
        self.initDimmingView()
        self.dimmingView.frame = self.containerView!.bounds
        self.presentedView!.frame = self.frameOfPresentedViewInContainerView(size: self.containerView!.frame.size)
    }
}

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var currentStyle: PresentationStyle!
    init(style: PresentationStyle) {
        currentStyle = style
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView: UIView = transitionContext.containerView
        let presentedView: UIView = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view)!
        presentedView.alpha = 0
        presentedView.frame = containerView.bounds
        containerView.addSubview(presentedView)
        var transform: CGAffineTransform = presentedView.transform
        if currentStyle == .alertView {
             presentedView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        else {
            presentedView.transform = transform.translatedBy(x: 0, y: containerView.bounds.size.height)
        }
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: { 
            presentedView.transform = transform
            presentedView.alpha = 1.0
        }) { (b) in
            transitionContext.completeTransition(true)
        }
    }
    
}
class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presentedView: UIView = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view)!
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            presentedView.transform = transform
            presentedView.alpha = 0.0
        }) { (b) in
            presentedView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
}
