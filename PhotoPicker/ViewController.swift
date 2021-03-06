//
//  ViewController.swift
//  PhotoPicker
//
//  Created by Russell Austin on 1/23/15.
//  Copyright (c) 2015 Russell Austin. All rights reserved.
//

import UIKit
import AVFoundation
import Social
import Accounts

class ViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }

    @IBAction func didPressTakePhoto(sender: UIButton) {
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    
                    
                    
//                    //tweet
//                    let accountStore = ACAccountStore()
//                    print(accountStore)
//                    let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
//                    accountStore.requestAccessToAccountsWithType(twitterAccountType,
//                        options: nil,
//                        completion: {
//                            (granted: Bool, error: NSError!) -> Void in
//                            if (!granted) {3
//                                print ("Access to Twitter Account denied")
//                            } else {
//                                let twitterAccounts = accountStore.accountsWithAccountType(twitterAccountType)
//                                if twitterAccounts.count == 0 {
//                                    print ("No Twitter Accounts available")
//                                    return
//                                } else {
//                                    let twitterParams = [
//                                        "status" : "yo",
//                                        "image" : image
//                                        
//                                    ]
//                                    let twitterAPIURL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
//                                    let request = SLRequest(forServiceType: SLServiceTypeTwitter,
//                                        requestMethod: SLRequestMethod.POST,
//                                        URL: twitterAPIURL,
//                                        parameters: twitterParams)
//                                    request.account = twitterAccounts.first as! ACAccount
//                                    request.performRequestWithHandler({
//                                        (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
//                                        Tweet.handlePostTweetResponse(responseData, urlResponse: urlResponse, error: error)
//                                    })
//                                }
//                            }
//
//                            
//                            
//                    })
                    
                    

                    //starts
                    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
                        let twitterController:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                        twitterController.setInitialText("Posting a tweet from iOS App" + "\r\n" + "\r\n" + "#Cool")
                        //img
                        twitterController.addImage(image)
                        self.presentViewController(twitterController, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Twitter Account", message: "Please login to your Twitter account.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    //ends
                
                }
            })
        }
        

    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession!.startRunning()
    }

    
    

}

