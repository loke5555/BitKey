//
//  ViewControllerBalanceChecker.swift
//  BitKeys
//
//  Created by Peter on 1/20/18.
//  Copyright © 2018 Fontaine. All rights reserved.
//

import UIKit
import AVFoundation

class ViewControllerBalanceChecker: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    
    let avCaptureSession = AVCaptureSession()
    var balance = Double()
    var backUpButton = UIButton(type: .custom)
    var bitcoinAddressQRCode = UIImage()
    var stringURL = String()
    
    //change to an array of dictioanries with nickname, and ability to delete them
    var addresses = String()

    
    @IBAction func addressText(_ sender: Any) {
        
        
      
    }
    
    
    
    
    
    @IBOutlet var addressToDisplay: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addressToDisplay.delegate = self
        print("ViewControllerBalanceChecker")
        addHomeButton()
        scanQRCode()
        
        if UserDefaults.standard.object(forKey: "address") != nil {
            
            addresses = UserDefaults.standard.object(forKey: "address") as! String
            self.addAddressBookButton()
            
        }
        
    }

    @IBOutlet var videoPreview: UIView!
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.addressToDisplay {
            
            DispatchQueue.main.async {
                
                self.checkBalance(address: self.addressToDisplay.text!)
                self.addressToDisplay.removeFromSuperview()
                self.avCaptureSession.stopRunning()
                
            }
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        addressToDisplay.resignFirstResponder()
        return true
    }
    
    enum error: Error {
        
        case noCameraAvailable
        case videoInputInitFail
        
    }
    
    func scanQRCode() {
        
        do {
           
            try scanQRNow()
            print("scanQRNow")
            
        } catch {
            
            print("Failed to scan QR Code")
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            
            addressToDisplay.removeFromSuperview()
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                
                stringURL = machineReadableCode.stringValue!
                //self.bitcoinAddressQRCode = machineReadableCode
                
                DispatchQueue.main.async {
                    self.addressToDisplay.text = self.stringURL
                }
                
                self.addresses = stringURL
                
                self.avCaptureSession.stopRunning()
                self.checkBalance(address: stringURL)
                
            }
        }
    }
    
    func scanQRNow() throws {
        
        
        
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            
            print("no camera")
            throw error.noCameraAvailable
            
        }
        
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            
            print("failed to int camera")
            throw error.videoInputInitFail
        }
        
        
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        self.avCaptureSession.addInput(avCaptureInput)
        self.avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = videoPreview.bounds
        self.videoPreview.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        self.avCaptureSession.startRunning()
        
    }
    /*
    func displayBalance() {
        
        DispatchQueue.main.async {
            self.videoPreview.removeFromSuperview()
            let balanceLabel = UILabel()
            balanceLabel.text = self.balance
            balanceLabel.center = self.view.center
            self.view.addSubview(balanceLabel)
            
        }
        
        
    }
    */
    

    func checkBalance(address: String) {
        print("checkBalance")
        
        var url:NSURL!
        url = NSURL(string: "https://blockchain.info/rawaddr/\(address)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonAddressResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            print("jsonAddressResult = \(jsonAddressResult)")
                            
                            //var finalBalance = String()
                            
                            if let finalBalanceCheck = jsonAddressResult["final_balance"] as? Double {
                                
                                let btcAmount = finalBalanceCheck / 100000000
                                self.balance = btcAmount
                                print(self.balance)
                                
                                    DispatchQueue.main.async {
                                        
                                        self.videoPreview.removeFromSuperview()
                                        
                                        let btcBalanceLabel = UILabel()
                                        btcBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) + 120), width: self.view.frame.width, height: self.view.frame.height)
                                        btcBalanceLabel.text = "\(btcAmount) BTC"
                                        btcBalanceLabel.textColor = UIColor.black
                                        btcBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                        btcBalanceLabel.textAlignment = .center
                                        self.view.addSubview(btcBalanceLabel)
                                        
                                        
                                         let addressLabel = UILabel()
                                         addressLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.frame.height - 100, width: self.view.frame.width, height: 60)
                                         addressLabel.text = address
                                         addressLabel.textColor = UIColor.black
                                         addressLabel.font = UIFont.systemFont(ofSize: 16)
                                         addressLabel.textAlignment = .center
                                         self.view.addSubview(addressLabel)
                                        
                                        //add label to bottom above button
                                        self.addBackUpButton()
                                        self.generateQrCode(key: address)
                                        self.getExchangeRates()
                                        
                                    }
                                
                            }
                            
                           
                            
                        } catch {
                            
                            print("JSon processing failed")
                            
                        }
                    }
                    
                    
                }
            }
        }
        
        task.resume()
    }
    
    func getExchangeRates() {
        
        var url:NSURL!
        url = NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                
                if error != nil {
                    
                    print(error as Any)
                    
                    
                } else {
                    
                    if let urlContent = data {
                        
                        do {
                            
                            let jsonQuoteResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                            
                            if let exchangeCheck = jsonQuoteResult["bpi"] as? NSDictionary {
                                
                                if let usdCheck = exchangeCheck["USD"] as? NSDictionary {
                                    
                                    if let rateCheck = usdCheck["rate_float"] as? Float {
                                        
                                        DispatchQueue.main.async {
                                            
                                        let exchangeRate = Double(rateCheck)
                                        let usdAmount = (self.balance * exchangeRate)
                                        let roundedUsdAmount = round(100 * usdAmount) / 100
                                        let roundedInt = Int(roundedUsdAmount)
                                        let usdBalanceLabel = UILabel()
                                        usdBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) + 60), width: self.view.frame.width, height: self.view.frame.height)
                                        usdBalanceLabel.text = "\(roundedInt.withCommas()) USD"
                                        usdBalanceLabel.textColor = UIColor.black
                                        usdBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                        usdBalanceLabel.textAlignment = .center
                                        self.view.addSubview(usdBalanceLabel)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                if let gbpCheck = exchangeCheck["GBP"] as? NSDictionary {
                                    
                                    if let rateCheck = gbpCheck["rate_float"] as? Float {
                                        
                                        DispatchQueue.main.async {
                                            
                                            let exchangeRate = Double(rateCheck)
                                            let gbpAmount = (self.balance * exchangeRate)
                                            let roundedGbpAmount = round(100 * gbpAmount) / 100
                                            let roundedInt = Int(roundedGbpAmount)
                                            let gbpBalanceLabel = UILabel()
                                            gbpBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2)), width: self.view.frame.width, height: self.view.frame.height)
                                            gbpBalanceLabel.text = "\(roundedInt.withCommas()) GBP"
                                            gbpBalanceLabel.textColor = UIColor.black
                                            gbpBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                            gbpBalanceLabel.textAlignment = .center
                                            self.view.addSubview(gbpBalanceLabel)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                if let euroCheck = exchangeCheck["EUR"] as? NSDictionary {
                                    
                                    if let rateCheck = euroCheck["rate_float"] as? Float {
                                        
                                        DispatchQueue.main.async {
                                            
                                            let exchangeRate = Double(rateCheck)
                                            let euroAmount = (self.balance * exchangeRate)
                                            let roundedEuroAmount = round(100 * euroAmount) / 100
                                            let roundedInt = Int(roundedEuroAmount)
                                            let euroBalanceLabel = UILabel()
                                            euroBalanceLabel.frame = CGRect(x: self.view.center.x - (self.view.frame.width / 2), y: self.view.center.y - ((self.view.frame.height / 2) - 60), width: self.view.frame.width, height: self.view.frame.height)
                                            euroBalanceLabel.text = "\(roundedInt.withCommas()) EUR"
                                            euroBalanceLabel.textColor = UIColor.black
                                            euroBalanceLabel.font = UIFont.systemFont(ofSize: 32)
                                            euroBalanceLabel.textAlignment = .center
                                            self.view.addSubview(euroBalanceLabel)
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                             }
 
                        } catch {
                            
                            print("JSon processing failed")
                        }
                    }
                    
                }
            }
        }
        
        task.resume()
        
    }
    
    func addHomeButton() {
        
        DispatchQueue.main.async {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100 , height: 55))
            button.showsTouchWhenHighlighted = true
            button.backgroundColor = .black
            button.setTitle("Back", for: .normal)
            button.addTarget(self, action: #selector(self.home), for: .touchUpInside)
            self.view.addSubview(button)
            
            
        }
        
    }
    @objc func home() {
        
        DispatchQueue.main.async {
            
            self.dismiss(animated: false, completion: nil)
        }
        
        
    }
    
    func addBackUpButton() {
        
        DispatchQueue.main.async {
            self.backUpButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.backgroundColor = .black
            self.backUpButton.setTitle("Save Bitcoin Address", for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.airDropImage), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
    
    func addAddressBookButton() {
        
        DispatchQueue.main.async {
            self.backUpButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
            self.backUpButton.showsTouchWhenHighlighted = true
            self.backUpButton.backgroundColor = .black
            self.backUpButton.setTitle("Address Book", for: .normal)
            self.backUpButton.addTarget(self, action: #selector(self.openAddressBook), for: .touchUpInside)
            self.view.addSubview(self.backUpButton)
        }
        
    }
    
    @objc func openAddressBook() {
        
        self.checkBalance(address: self.addresses)
        self.avCaptureSession.stopRunning()
        self.videoPreview.removeFromSuperview()
        self.addressToDisplay.removeFromSuperview()
        
    }
    
    @objc func airDropImage() {
        
        print("airDropImage")
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Save/Share/Copy", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add to Address Book", comment: ""), style: .default, handler: { (action) in
                
                
                UserDefaults.standard.set(self.addresses, forKey: "address")
                
                DispatchQueue.main.async {
                    
                    self.displayAlert(title: "Address Saved", message: "")
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Bitcoin Address QR Code", comment: ""), style: .default, handler: { (action) in
                    
                    if let data = UIImagePNGRepresentation(self.bitcoinAddressQRCode) {
                        
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
                    
                    let activityViewController = UIActivityViewController(activityItems: [self.addresses], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    func generateQrCode(key: String) {
        
        let ciContext = CIContext()
        let data = key.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let upScaledImage = filter.outputImage?.transformed(by: transform)
            let cgImage = ciContext.createCGImage(upScaledImage!, from: upScaledImage!.extent)
            self.bitcoinAddressQRCode = UIImage(cgImage: cgImage!)
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

extension Int {
    
    func withCommas() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
}
