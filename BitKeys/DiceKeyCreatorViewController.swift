//
//  DiceKeyCreatorViewController.swift
//  BitKeys
//
//  Created by Peter on 3/27/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import SystemConfiguration

class DiceKeyCreatorViewController: UIViewController {
    
    @IBOutlet var upperLabel: UILabel!
    var clearButton = UIButton()
    var diceButton = UIButton()
    var backButton = UIButton()
    var diceArray = [UIButton]()
    var createKeysButton = UIButton()
    var privateKey = String()
    var bitcoinAddress = String()
    var tappedIndex = Int()
    var privateKeyQRCode:UIImage!
    var privateKeyQRView:UIImageView!
    var privateKeyImage:UIImage!
    var imageView:UIView!
    var myField: UITextView!
    var privateKeyMode:Bool!
    var connected:Bool!
    var privateKeyText:String!
    var bitcoinAddressButton = UIButton()
    var backUpButton = UIButton(type: .custom)
    
    @IBOutlet var scrollView: UIScrollView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        privateKeyMode = true
        showDice()
        addBackButton()
        addClearButton()
        addCheckAddressButton()
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: 414, height: 1900)
    }
    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        self.connected = isReachable
        return (isReachable && !needsConnection)
    }

    func showDice() {
        
        self.isInternetAvailable()
        
        //if self.connected == false {
            
            var xvalue = 25;
            var yvalue = 60
            
            var zero = 0
            
            for _ in 0..<20 {
                
                for _ in 0..<5 {
                    
                    zero = zero + 1
                    self.diceButton = UIButton(frame: CGRect(x: xvalue, y: yvalue, width: 65, height: 65))
                    self.diceButton.tag = zero
                    self.diceButton.showsTouchWhenHighlighted = true
                    self.diceButton.backgroundColor = .gray
                    self.diceButton.setTitle("\(0)", for: .normal)
                    self.diceButton.titleLabel?.textColor = UIColor.white
                    self.diceButton.addTarget(self, action: #selector(self.tapDice), for: .touchUpInside)
                    self.diceArray.append(self.diceButton)
                    self.scrollView.addSubview(self.diceButton)
                    xvalue = xvalue + 75
                }
                xvalue=25;
                yvalue = yvalue + 90
            }
            
       /* } else {
            
            DispatchQueue.main.async {
                self.displayAlert(title: "Device Connection Insecure", message: "Please enable airplane mode to create private keys.")
                //self.imageView.removeFromSuperview()
                //self.bitField.removeFromSuperview()
                //self.numberArray.removeAll()
                //self.showBitcoin()
            }
            
        }
        */
                
    }
    

    @objc func tapDice(sender: UIButton!) {
        
        let diceNumber = Int((sender.titleLabel?.text)!)
        
        func addDiceValue() {
           
            if diceNumber == 0 {
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.backgroundColor = .black
                }
            } else if diceNumber == 1 {
                DispatchQueue.main.async {
                    sender.setTitle("2", for: .normal)
                    sender.backgroundColor = .black
                }
            } else if diceNumber == 2 {
                DispatchQueue.main.async {
                    sender.setTitle("3", for: .normal)
                    sender.backgroundColor = .black
                }
            } else if diceNumber == 3 {
                DispatchQueue.main.async {
                    sender.setTitle("4", for: .normal)
                    sender.backgroundColor = .black
                }
            } else if diceNumber == 4 {
                DispatchQueue.main.async {
                    sender.setTitle("5", for: .normal)
                    sender.backgroundColor = .black
                }
            } else if diceNumber == 5 {
                DispatchQueue.main.async {
                    sender.setTitle("6", for: .normal)
                    sender.backgroundColor = .black
                }
            } else if diceNumber == 6 {
                DispatchQueue.main.async {
                    sender.setTitle("1", for: .normal)
                    sender.backgroundColor = .black
                }
            }
            
        }
        
        if sender.tag == 1 && diceNumber == 0 {
            
            self.tappedIndex = sender.tag
            addDiceValue()
            
        } else if sender.tag == self.tappedIndex + 1 {
            
            self.tappedIndex = sender.tag
            addDiceValue()
            
        } else if sender.tag == self.tappedIndex {
            
            addDiceValue()
            
        } else {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: NSLocalizedString("You must input dice values in order!", comment: ""), message: "In order for the key to be cryptographically secure you must input the actual values of your dice as they appear to you from left to right, in order row by row.\n\nStart with the top left dice and work your way to the right being very careful to ensure you input the dice values correctly.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok, got it", comment: ""), style: .default, handler: { (action) in
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Why?", comment: ""), style: .default, handler: { (action) in
                    
                    self.displayAlert(title: "", message: "We make it impossible for you to input the dice values out of order becasue we don't want you to accidentally create a Private Key that is not based on true cryptographic secure randomness. We also do this to make it impossible for you to accidentaly tap and change a value of a dice you have already input. Secure keys ARE WORTH the effort!")
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Start Over", comment: ""), style: .destructive, handler: { (action) in
                    
                    self.clearDice()
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func createKeys(baseSixNumber: String) -> (privateKeyAddress: String, publicKeyAddress: String) {
    
        if let newData = baseSixNumber.data(using: String.Encoding.utf8){
            
            let shaOfKey = BTCSHA256(newData)
            let keys = BTCKey.init(privateKey: shaOfKey! as Data)
            let privateKey2 = keys?.privateKeyAddress!.description
            let privateKey3 = privateKey2?.components(separatedBy: " ")
            let privateKey = privateKey3![1].replacingOccurrences(of: ">", with: "")
            let segwitAddress = BTCScriptHashAddress.init(data: keys?.address.data)
            let segwitAddress2 = (segwitAddress?.description)?.components(separatedBy: " ")
            let bitcoinAddress = segwitAddress2![1].replacingOccurrences(of: ">", with: "")
            return (privateKey, bitcoinAddress)
        
        } else {
            
            return ("", "")
    
        }
        
    }
    
    @objc func tapCreateKeys() {
        
        var allDiceInputed:Bool! = true
        var numberArray = [String]()
        
        for dice in self.diceArray {
            
            let diceNumber = Int((dice.titleLabel?.text)!)
            numberArray.append(String(describing: diceNumber!))
            print("count = \(numberArray.count)")
            
            if diceNumber == 0 {
                
                allDiceInputed = false
                
            }
        }
        
        if allDiceInputed == true {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: NSLocalizedString("Are you sure you have input the dice values correctly?", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, I'm sure", comment: ""), style: .default, handler: { (action) in
                    
                    let randomNumber = numberArray.joined()
                    self.privateKey = self.createKeys(baseSixNumber: randomNumber).privateKeyAddress
                    self.bitcoinAddress = self.createKeys(baseSixNumber: randomNumber).publicKeyAddress
                    
                    if self.privateKey != "" {
                        
                        for dice in self.diceArray {
                            dice.removeFromSuperview()
                        }
                        
                        self.privateKeyText = self.privateKey
                        self.privateKeyQRCode = self.generateQrCode(key: self.privateKey)
                        self.privateKeyQRView = UIImageView(image: self.privateKeyQRCode!)
                        self.privateKeyQRView.center = self.view.center
                        self.privateKeyQRView.frame = CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.view.center.y - ((self.view.frame.width - 50)/2), width: self.view.frame.width - 50, height: self.view.frame.width - 50)
                        self.privateKeyQRView.alpha = 0
                        
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            //self.imageView.alpha = 0
                            //self.bitField.alpha = 0
                            
                        }, completion: { _ in
                            
                           // self.imageView.removeFromSuperview()
                            //self.bitField.removeFromSuperview()
                            self.createKeysButton.removeFromSuperview()
                            self.clearButton.removeFromSuperview()
                            self.view.addSubview(self.privateKeyQRView)
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                
                                self.privateKeyQRView.alpha = 1
                                
                            }, completion: { _ in
                                
                                self.upperLabel.text = "Bitcoin Private Key"
                                self.myField = UITextView (frame:CGRect(x: self.view.center.x - ((self.view.frame.width - 50)/2), y: self.view.center.y + ((self.view.frame.width - 50)/2), width: self.view.frame.width - 50, height: 100))
                                self.myField.text = self.privateKey
                                self.myField.isEditable = false
                                self.myField.isSelectable = true
                                self.myField.font = .systemFont(ofSize: 24)
                                self.view.addSubview(self.myField)
                                self.addBackUpButton()
                                self.addKeyToggleButton()
                                
                            })
                            
                        })
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: "There was an error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive, handler: { (action) in
                                
                                self.privateKeyQRCode = nil
                                self.privateKeyImage = nil
                                self.privateKeyQRView.image = nil
                                self.upperLabel.text = ""
                                self.myField.text = ""
                                self.imageView.removeFromSuperview()
                                self.imageView = nil
                                self.bitcoinAddress = ""
                                self.backUpButton.removeFromSuperview()
                                self.bitcoinAddressButton.removeFromSuperview()
                                self.privateKeyText = ""
                                self.clearDice()
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("No, let me check", comment: ""), style: .default, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
            
        } else {
          
            DispatchQueue.main.async {
                self.displayAlert(title: "Missing Dice!", message: "You need to fill all the dice out in order to create cryptographically secure randomness and therefore secure keys. None of the dice can have a value of 0.")
            }
            
        }
        
    }
    
    func clearDice() {
        
        for dice in self.diceArray {
            dice.removeFromSuperview()
        }
        self.diceArray.removeAll()
        self.tappedIndex = 0
        self.showDice()
        
    }
    
    @objc func tapClearDice() {
        
        clearDice()
        
    }
    
    @objc func home() {
        
        if self.privateKey != "" {
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Have you saved this Private Key?", message: "Ensure you have saved this before going back if you'd like to use this Private Key in the future.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("I saved it, go back", comment: ""), style: .destructive, handler: { (action) in
                    
                    self.privateKeyQRCode = nil
                    self.privateKey = ""
                    self.bitcoinAddress = ""
                    self.clearDice()
                    self.privateKeyImage = nil
                    self.privateKeyQRView.image = nil
                    self.upperLabel.text = ""
                    self.myField.text = ""
                    self.backUpButton.removeFromSuperview()
                    self.privateKeyText = ""
                    self.dismiss(animated: false, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    @objc func getAddress() {
        
        if privateKeyMode {
            
            DispatchQueue.main.async {
                
                self.upperLabel.text = "Bitcoin Address"
                self.myField.text = self.bitcoinAddress
                self.privateKeyQRCode = self.generateQrCode(key: self.bitcoinAddress)
                self.privateKeyQRView.image = self.privateKeyQRCode!
                self.bitcoinAddressButton.setTitle("Show Private Key", for: .normal)
                self.privateKeyMode = false
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.upperLabel.text = "Bitcoin Private Key"
                self.myField.text = self.privateKeyText
                self.privateKeyQRCode = self.generateQrCode(key: self.privateKeyText)
                self.privateKeyQRView.image = self.privateKeyQRCode!
                self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
                self.privateKeyMode = true
                
            }
        }
    }
    
    func addBackUpButton() {
        
        DispatchQueue.main.async {
            self.backUpButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.backgroundColor = .black
            self.backUpButton.setTitle("Back Up / Share / Save / Copy", for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
    
    func addCheckAddressButton() {
        
        DispatchQueue.main.async {
            self.createKeysButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
            self.createKeysButton.showsTouchWhenHighlighted = true
            self.createKeysButton.backgroundColor = .black
            self.createKeysButton.setTitle("Create Keys", for: .normal)
            self.createKeysButton.addTarget(self, action: #selector(self.tapCreateKeys), for: .touchUpInside)
            self.view.addSubview(self.createKeysButton)
        }
        
    }
    
    func addBackButton() {
        
        DispatchQueue.main.async {
            self.backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
            self.backButton.showsTouchWhenHighlighted = true
            self.backButton.backgroundColor = .black
            self.backButton.setTitle("Back", for: .normal)
            self.backButton.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(self.backButton)
        }
    }
    
    func addClearButton() {
        
        self.clearButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 100, y: 0, width: 100 , height: 55))
        self.clearButton.showsTouchWhenHighlighted = true
        self.clearButton.backgroundColor = .black
        self.clearButton.setTitle("Clear", for: .normal)
        self.clearButton.addTarget(self, action: #selector(self.tapClearDice), for: .touchUpInside)
        self.view.addSubview(self.clearButton)
    }
    
    func addKeyToggleButton() {
        
        DispatchQueue.main.async {
            self.bitcoinAddressButton = UIButton(frame: CGRect(x: self.view.frame.maxX - 150, y: 0, width: 150 , height: 55))
            self.bitcoinAddressButton.showsTouchWhenHighlighted = true
            self.bitcoinAddressButton.backgroundColor = .black
            self.bitcoinAddressButton.setTitle("Show Address", for: .normal)
            self.bitcoinAddressButton.addTarget(self, action: #selector(self.getAddress), for: .touchUpInside)
            self.view.addSubview(self.bitcoinAddressButton)
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    func generateQrCode(key: String) -> UIImage? {
        
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            privateKeyImage = UIImage(cgImage: cgImage!)
            return privateKeyImage
        }
        return nil
        
    }
    
    @objc func airDropImage() {
        
        print("airDropImage")
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            if self.privateKeyMode {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Private Key QR Code", comment: ""), style: .default, handler: { (action) in
                    
                    if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                        
                        let fileName = self.getDocumentsDirectory().appendingPathComponent("privateKey.png")
                        
                        try? data.write(to: fileName)
                        
                        let objectsToShare = [fileName]
                        
                        DispatchQueue.main.async {
                            
                            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityController, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Private Key Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.privateKeyText!]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Bitcoin Address QR Code", comment: ""), style: .default, handler: { (action) in
                    
                    if let data = UIImagePNGRepresentation(self.privateKeyImage) {
                        
                        let fileName = self.getDocumentsDirectory().appendingPathComponent("bitcoinAddress.png")
                        
                        try? data.write(to: fileName)
                        
                        let objectsToShare = [fileName]
                        DispatchQueue.main.async {
                            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            self.present(activityController, animated: true, completion: nil)
                        }
                        
                    }
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Bitcoin Address Text", comment: ""), style: .default, handler: { (action) in
                    
                    let textToShare = [self.bitcoinAddress]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension Data {
    func hex(separator:String = "") -> String {
        return (self.map { String(format: "%02X", $0) }).joined(separator: separator)
    }
}