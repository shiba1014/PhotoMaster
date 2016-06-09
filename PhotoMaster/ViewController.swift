//
//  ViewController.swift
//  PhotoMaster
//
//  Created by Paul McCartney on 2016/06/09.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func presentPickerController(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        photoImageView.image = image
    }
    
    @IBAction func selectButtonTapped(sender: UIButton) {
        let alert = UIAlertController(title: "画像の取得先を選択", message: nil, preferredStyle: .ActionSheet)
        
        let firstAction = UIAlertAction(title: "カメラ", style: .Default) {
            action in
            self.presentPickerController(.Camera)
        }
        
        let secondAction = UIAlertAction(title: "アルバム", style: .Default) {
            action in
            self.presentPickerController(.PhotoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func drawText(image:UIImage) -> UIImage {
        let text = "test"
        UIGraphicsBeginImageContext(image.size)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let textRect = CGRectMake(5, 5, image.size.width - 5, image.size.height - 5)
        let textFontAttrbutes = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(120),
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSParagraphStyleAttributeName: NSMutableParagraphStyle.defaultParagraphStyle()
        ]
        
        text.drawInRect(textRect, withAttributes: textFontAttrbutes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func drawMaskImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        let maskImage = UIImage(named: "penguin")
        let offset: CGFloat = 50.0
        let maskRect = CGRectMake(image.size.width - maskImage!.size.width - offset,
                                  image.size.height - maskImage!.size.height - offset,
                                  maskImage!.size.width, maskImage!.size.height)
        maskImage!.drawInRect(maskRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func simpleAlert(titleString: String) {
        let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func processButtonTapped(sender: UIButton) {
        guard let selectedPhoto = photoImageView.image else {
            simpleAlert("画像がありません")
            return
        }
        
        let alertController = UIAlertController(title: "合成するパーツを選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "テキスト", style: .Default, handler: {
            action in
            self.photoImageView.image = self.drawText(selectedPhoto)
        })
        let secondAction = UIAlertAction(title: "ペンギン", style: .Default, handler: {
            action in
            self.photoImageView.image = self.drawMaskImage(selectedPhoto)
        })
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func postToSNS(serviceType: String) {
        let myComposeView = SLComposeViewController(forServiceType: serviceType)
        myComposeView.setInitialText("PhotoMasterからの投稿だよ")
        myComposeView.addImage(photoImageView.image)
        self.presentViewController(myComposeView, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonTapped(sendar: UIButton) {
        guard let selectedPhoto = photoImageView.image else {
            simpleAlert("画像がありません")
            return
        }
        
        let alertController = UIAlertController(title: "アップロード先を選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "Facebookに投稿", style: .Default, handler: {
            action in
            self.postToSNS(SLServiceTypeFacebook)
        })
        let secondAction = UIAlertAction(title: "Twitterに投稿", style: .Default, handler: {
            action in
             self.postToSNS(SLServiceTypeTwitter)
        })
        let thirdAction = UIAlertAction(title: "カメラロールに保存", style: .Default, handler: {
            action in
            UIImageWriteToSavedPhotosAlbum(selectedPhoto, self, nil, nil)
            self.simpleAlert("アルバムに保存されました")
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Default, handler: nil)
        
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(thirdAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

