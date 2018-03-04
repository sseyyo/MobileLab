//
//  ViewController.swift
//  mobile-lab-websockets
//
//  Created by Seyoung Kim on 2/26/18.
//  Copyright © 2018 Seyoung Kim. All rights reserved.
//

import UIKit
import Starscream    // Socket library
import CoreLocation
import CoreMotion
import Alamofire
import SwiftyJSON
import SDWebImage

// Create an enumeration for direction commands.

// An enumeration defines a common type for a group of related values and enables you to work with those values in a type-safe way within your code.

// In this example we also map the enumeration values to the number exact codes we need send to the server for each direction.

// In this case it not only
enum DirectionCode: String {
    case up = "0"
    case right = "1"
    case down = "2"
    case left = "3"
}

let playerIdKey = "PLAYER_ID";

class ViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate {

    @IBOutlet weak var StepsLabel: UILabel!
    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var compass: UIImageView!
    
    let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()
    
    var WalkBool: Bool! = false
    var dirAng: Int?

    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0}
    var yourLocation: CLLocation {
        get {return UserDefaults.standard.currentLocation}
        set {UserDefaults.standard.currentLocation = newValue}
    }
    
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation{
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation{
            case .landscapeLeft: return 90
            case .landscapeRight: return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            }
        }()
        return adjAngle
    }
    
   
    
    // User UserDefaults for simple storage.
    var defaults: UserDefaults!
    
    // Object for managing the web socket.
    var socket: WebSocket?
    
    // Input text field.
    @IBOutlet weak var playerIdTextField: UITextField!
    
    // Profile image view.
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // URL of web server.
        let urlString = "ws://websockets.mobilelabclass.com:1024/"
        
        Alamofire.request("https://dog.ceo/api/breeds/image/random").responseJSON { (responseData) in

            let json = JSON(responseData.result.value!)
            
            let dogImageURLString = json["message"].string!
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
           
            let myColor : UIColor = UIColor( red: 0.93, green: 0.34, blue: 0.31, alpha: 1.0 )
            self.profileImageView.layer.borderColor = myColor.cgColor
            self.profileImageView.layer.borderWidth = 5 // as you wish
            self.profileImageView.clipsToBounds = true //what is this
            
            self.profileImageView.sd_setImage(with: URL(string: dogImageURLString))
            
            guard let playerId = self.defaults.string(forKey: playerIdKey) else {
                self.presentAlertMessage(message: "Enter Player Id")
                return
            }
            
            // Send the playerId and dog image url string in this format.
            // Make sure the dogImageURLString variable is in scope.
            let message = "\(playerId), profile_image:\(dogImageURLString)"
            self.socket?.write(string: message) {
                print("⬆️  profile image sent message to server: ", message)
            }
        }
        
        playerIdTextField.layer.backgroundColor = UIColor.clear.cgColor
        
        // Create a WebSocket.
        socket = WebSocket(url: URL(string: urlString)!)
        
        // Assign WebSocket delegate to self
        socket?.delegate = self
        
        // Connect.
        socket?.connect()
        startTrackingActivityType()
        startCountingSteps()
        
        // Assigning notifications to when the app becomes active or inactive.
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    
        // Set delegate for text field to conform to protocol.
        playerIdTextField.delegate = self

        // Init user defaults object for storage.
        defaults = UserDefaults.standard

        // Get USER DEFAULTS data. ////////////
        // If there is a player id saved, set text field.
        if let playerId = defaults.string(forKey: playerIdKey) {
            playerIdTextField.text = playerId
        }
        
        locationManager.delegate = locationDelegate
        locationDelegate.locationCallback = { location in
            self.latestLocation = location
        }
        locationDelegate.headingCallback = { newHeading in
            func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
                let heading: CGFloat = {
                    let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
                    switch UIDevice.current.orientation {
                    case .faceDown: return -originalHeading
                    default: return originalHeading
                    }
                }()
                return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
            }
            UIView.animate(withDuration: 0.5){
                let angle = computeNewAngle(with: CGFloat(newHeading))
                self.dirAng = abs(Int(angle))
//                print("angle is \(String(describing: self.dirAng))")
                self.compass.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
     //////////////////////////////////////
    }
    func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.TextLabel.text = "Walking"
                    self?.WalkBool = true
                    self?.controlInterface()
                } else if activity.stationary {
                    self?.TextLabel.text = "Stationary"
                } else if activity.running {
                    self?.TextLabel.text = "Running"
                    self?.WalkBool = true
                    self?.controlInterface()
                } else if activity.automotive {
                    self?.TextLabel.text = "Automotive"
                } else {
                    print("no activity?")
                }
                
                
            }
        }
    }
    
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.StepsLabel.text = pedometerData.numberOfSteps.stringValue
                print(pedometerData.numberOfSteps.stringValue)
                print("walking\(self?.WalkBool)")
            }
        }
        

    }
    
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivityType()
            print("activity ")
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
            print("startcounting")
        }
    }

    // Textfield delegate method.
    // Update player id in user defaults when "Done" is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)

        // Check text field is not empty, otherwise save to user defaults.
        if (textField.text?.isEmpty)! {
            presentAlertMessage(message: "Enter Valid Player Id")
            textField.text = defaults.string(forKey: playerIdKey)!
        } else {

            // Set USER DEFAULTS data. ////////////
            defaults.set(textField.text!, forKey: playerIdKey)
            presentAlertMessage(message: "Player Id Saved!")
            //////////////////////////////////////
        }
        
        return false
    }
    

    // Helper method for displaying a alert view.
    func presentAlertMessage(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func controlInterface(){
        
         if (WalkBool){
            print("walk bool is true")
            if (dirAng == 0) {
                sendDirectionMessage(.up)
                print("up!!")
                WalkBool = false
            } else if (dirAng == 1){
                sendDirectionMessage(.right)
                print("right")

            } else if (dirAng == 3){
                sendDirectionMessage(.down)
                print("down")

            } else if (dirAng == 4){
                sendDirectionMessage(.left)
                print("left")

            } else {
                print("walk boolean is false")
            }
         }
 
        // Button actions connected from storyboard.
    
    }
    // WebSocket delegate methods
    func websocketDidConnect(socket: WebSocketClient) {
        print("✅ Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("🛑 Disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//         print(text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//         print(data)
    }

    func sendDirectionMessage(_ code: DirectionCode) {
        // Get the raw string value from the DirectionCode enum
        // that we created at the top of this program.
        sendMessage(code.rawValue)
    }

    func sendMessage(_ message: String) {
        // Check if there is a valid player id set.
        guard let playerId = defaults.string(forKey: playerIdKey) else {
            presentAlertMessage(message: "Enter Player Id")
            return
        }

        // Construct server message and write to socket. ///////////
        let message = "\(playerId), \(message)"
        socket?.write(string: message) {
            // This is a completion block.
            // We can write custom code here that will run once the message is sent.
            print("⬆️ sent message to server: ", message)
        }
        ///////////////////////////////////////////////////////////
    }
    
    @objc func willResignActive() {
        print("💡 Application will resign active. Disconnecting socket.")
        socket?.disconnect()
    }
    
    @objc func didBecomeActive() {
        print("💡 Application did become active. Connecting socket.")
        socket?.connect()
    }
}


// Some helpers using extensions
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

