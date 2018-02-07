//
//  UnlockViewController.swift
//  Unlock
//
//  Created by KimSe young on 2/5/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var startPoint: UIImageView!
    @IBOutlet weak var firstPoint: UIImageView!
    @IBOutlet weak var secondPoint: UIImageView!
    @IBOutlet weak var endPoint: UIImageView!

    ////////////UNLOCK SEQUENCE//////////////
    let lockPattern = [1, 2, 3, 4]
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
        updateCircleFeedback(circleNumber: 4, isOn: false)

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
                processSwipePattern(circleNumber: 3)
            } else if hitView == endPoint {
                processSwipePattern(circleNumber: 4)
            }
        }
    }
    
    // Override touchesEded method already provided by parent class.
    override func touchesEnded(_ touches: Set<UITouch>, with evet: UIEvent?){
        // Reset the scree when user lifts touch off.
        resetScreen()
    }
    
    // Logic for different stages of the swipe sequence.
    func processSwipePattern(circleNumber: Int){
        // Append circle number if swipePattern array is empty.
        if swipePattern.count == 0 {
            // Append passed in circleNumber ito swipe pattern array.
            swipePattern.append(circleNumber)
            
            // Update visual feedback.
            updateCircleFeedback(circleNumber: circleNumber, isOn: true)
        } else {
            // Only append new circle number if different from last circle number.
            // User touch could still be over same circle so do not capture circle number.
            if swipePattern.last != circleNumber {
                swipePattern.append(circleNumber)
                updateCircleFeedback(circleNumber: circleNumber, isOn: true)
            }
            
            // When swipePatternarray count hits 3, check agaist lockPattern.
            if swipePattern.count == 3 {
                statusLabel.text = (swipePattern == lockPattern) ? "Unlocked" : "Try Again"
            }
        }
    }
}
