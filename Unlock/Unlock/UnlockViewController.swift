//
//  UnlockViewController.swift
//  Unlock
//
//  Created by KimSe young on 2/5/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import UIKit

class UnlockViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var startPoint: UIImageView!
    @IBOutlet weak var firstPoint: UIImageView!
    @IBOutlet weak var secondPoint: UIImageView!
    @IBOutlet weak var endPoint: UIImageView!

    ////////////UNLOCK SEQUENCE//////////////
    var swipePattern = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reset screen on app start.
        resetScreen()
    }
    
    func resetScreen(){
        // Initialize status label
        statusLabel.text = "Find the fastest way home from school"
        
        // Update visual feedback
        updateCircleFeedback(circleNumber: 1, isOn: false)
        updateCircleFeedback(circleNumber: 2, isOn: false)
        updateCircleFeedback(circleNumber: 3, isOn: false)
        (circleNumber: 4, isOn: false)

        // Flush input pattern.
        swipePattern.removeAll()
    }
    
    // Helper method to update circle alpha for visual feedback. Don't need this in the future.
    func updateCircleFeedback(circleNumber: Int, isOn: Bool){
        if circleNumber == 1 {
            startPoint.alpha = isOn ? 0.2 : 1.0
            firstPoint.alpha = isOn ? 0.2 : 1.0
            secondPoint.alpha = isOn ? 0.2 : 1.0
            endPoint.alpha = isOn ? 0.2 : 1.0
        }
    }
    
    // Override touchesMoved method already provided by parent class
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        // Get first touch.
        if let firstTouch = touches.first{
            //Check which view user is touching.
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            
            // Process swipe pattern based on which circle is touched.
            if hitView == startPoint {
                processSwipePattern(circleNumber: 1)
            } else if hitView == firstPoint {
                processSwipePattern(circleNumber: 2)
            } else if hitView == secondPoint {
                processingSwipePatter(circleNumber: 3)
            } else if hitView == endPoint {
                processingSwipePattern(circleumber: 4)
            }
        }
    }
    
    // Override touchesEded method already provided by parent class.
    override func touchesEnded(_ touches: Set<UITouch>, with evet: UIEvent?){
        // Reset the scree when user lifts touch off.
        resetScreen()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self

        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect

        self.pageViewController!.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

        return .mid
    }


}
