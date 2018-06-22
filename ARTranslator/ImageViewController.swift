//
//  ImageViewController.swift
//  ARTranslator
//
//  Created by Nora AlNashwan on 18/06/2018.
//  Copyright © 2018 Nora AlNashwan. All rights reserved.
//

import UIKit
import VisualRecognitionV3

struct Language {
    let code: String
    let name: String
}

class ImageViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var capturedImage: UIImage?
    var languageList: [Language]?
    var visualRecognition: VisualRecognition!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.goToNextViewController))
        self.languageList = [Language(code: "en", name: "English"),
                        Language(code: "es", name: "Spanish"),
                        Language(code: "fr", name: "French"),
                        Language(code: "de", name: "German"),
                        Language(code: "it", name: "Italian"),
                        Language(code: "pt", name: "Portuguese")]
        
        if let availableImage = capturedImage {
            imageView.image = availableImage
        }
        
    }
    
    @objc func goToNextViewController(){
        let translationViewController = self.storyboard!.instantiateViewController(withIdentifier: "TranslationVC") as! TranslationViewController;
       visualRecognition = VisualRecognition(version: "2018-06-21", accessToken: Credentials.vr_sessionKey)
        let failure = { (error: Error) in
            let alert = UIAlertController(title: "",message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        var result = ""
        visualRecognition.classify(image: imageView.image!, failure: failure){ Classifiers in
                    for c in Classifiers.images[0].classifiers[0].classes {
                        result.append("\(c.className) ")
                    }
            DispatchQueue.main.async {
                translationViewController.textFromImage = result
                self.navigationController!.pushViewController(translationViewController, animated: true)
            }
            
            
        }
            
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
