//
//  ViewController.swift
//  YesNo
//
//  Created by KimSe young on 2/18/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var yesBtn: UIImageView!
    @IBOutlet weak var noBtn: UIImageView!
    
    var yesImages: [UIImage] = []
    var noImages: [UIImage] = []
    
    let yesView = UITextView()
    let noView = UITextView()
    
    var feedbackGenerator: UIImpactFeedbackGenerator!
    
    let yesColor = UIColor(red: 0.62, green: 1.0, blue: 0.9, alpha: 1.0)
    let noColor = UIColor(red: 1.0, green: 0.88, blue: 0.83, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesImages = createImageArray(total: 82, imagePrefix: "yest")
        noImages = createImageArray(total: 82, imagePrefix: "no")
//        yesView.backgroundColor = yesColor
//        yesView.text = "YES"
//        yesView.textAlignment = NSTextAlignment.center
//        noView.backgroundColor = noColor
//        noView.text = "NO"
//        noView.textAlignment = NSTextAlignment.center
//
////        yesView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
//        yesView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
//        noView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
//
//        yesView.center = CGPoint(x: 105, y: 350)
//        noView.center = CGPoint(x: 270, y: 350)
//
////        yesView.center = self.view.center
//        self.view.addSubview(yesView)
//        self.view.addSubview(noView)
//
//        feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
//
//        //let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        let yesTap = UITapGestureRecognizer(target: self, action: #selector(yhandleTap))
//        let noTap = UITapGestureRecognizer(target: self, action: #selector(nhandleTap))
//
//        noView.addGestureRecognizer(noTap)
//        yesView.addGestureRecognizer(yesTap)
////        self.view.addGestureRecognizer(tap)
    }
    
    func createImageArray(total: Int, imagePrefix: String) -> [UIImage]{
        var imageArray: [UIImage] = []
        
        for imageCount in 0..<total {
            let imageName = "\(imagePrefix)\(imageCount).png"
            let image = UIImage(named: imageName)!
            imageArray.append(image)
            print(imageName)
        }
        return imageArray
    }
    
    func imgAnimate(imageView: UIImageView, images: [UIImage]){
        imageView.animationImages = images
        imageView.animationDuration = 3.0
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
    }
    
    @IBAction func yesBtnTapped(_ sender: UIButton) {
        imgAnimate(imageView: yesBtn, images: yesImages)
    }
   
    @IBAction func noBtnTapped(_ sender: UIButton) {
        imgAnimate(imageView: noBtn, images: noImages)
    }
    

//
//    @objc
////    func handleTap(recognizer: UITapGestureRecognizer){
////
////            if let view = recognizer.view {
////            feedbackGenerator.impactOccurred()
////
////            UIView.animate(
////                withDuration: 0.7,
////                delay: 0.0,
////                options: [.curveEaseInOut,.autoreverse,.repeat],
////                animations: {
////                    view.transform = CGAffineTransform(scaleX: 1.0, y: 0.8)
////                })
////        }
////    }
//
//    func yhandleTap(recognizer: UITapGestureRecognizer){
//
//        if let view = recognizer.view {
//            feedbackGenerator.impactOccurred()
//
//            UIView.animate(
//
//                withDuration: 0.7,
//                delay: 0.0,
//                options: [.curveEaseInOut,.autoreverse, .repeat],
////                repeatCount: 3,
////                usingSpringWithDamping: 0.2,
////                initialSpringVelocity: 1,
//                animations: {
//                    view.transform = CGAffineTransform(scaleX: 1.0, y: 0.8)
//                },
//                completion: nil)
//
//            //            view.center = CGPoint(x:view.center.x, y:view.center.y + 60)
//            //            view.transform = view.transform.scaledBy(x: 1, y: 0.85)
//
//        }
//    }
//
//    @objc
//    func nhandleTap(recognizer: UITapGestureRecognizer){
//
//        if let view = recognizer.view {
//            feedbackGenerator.impactOccurred()
//
//            UIView.animate(
//                withDuration: 0.7,
//                delay: 0.0,
//                options: [.curveEaseInOut,.autoreverse, .repeat],
//                animations: {
//                    view.transform = CGAffineTransform(scaleX: 1.0, y: 0.8)
//                    //                    self.transform = CGAffineTransform(scaleX: 1.0, y: 0.8)
//                },
//                completion: nil)
//
//            //            view.center = CGPoint(x:view.center.x, y:view.center.y + 60)
//            //            view.transform = view.transform.scaledBy(x: 1, y: 0.85)
//
//        }
//    }
//
////    @IBAction func YesAction(_ sender: UIButton){
////        let pulse = CASpringAnimation(keyPath: "transform.scale")
////        pulse.duration = 3.0
////        pulse.fromValue = 0.92
////        pulse.toValue = 1.0
////        pulse.autoreverses = true
////        pulse.repeatCount = 10
////        pulse.initialVelocity = 0.5
////        pulse.damping = 1.0
//
////    }

    
    

}

