//
//  ImageViewController.swift
//  ARTranslator
//
//  Created by Nora AlNashwan on 18/06/2018.
//  Copyright © 2018 Nora AlNashwan. All rights reserved.
//

import UIKit
import VisualRecognitionV3

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    var capturedImage: UIImage?
    var visualRecognition: VisualRecognition!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.goToNextViewController))
        guard let availableImage = capturedImage else {
            showAlert(message: "An error occurred during the image presentation")
            return
        }
        imageView.image = availableImage
    }
    
    @objc func goToNextViewController(){
        self.loadIndicator.startAnimating()
        var result = ""
        let failure = { (error: Error) in
            self.showAlert(message: error.localizedDescription)
        }
        visualRecognition = VisualRecognition(version: Credentials.version, apiKey: Credentials.vr_apiKey)
        visualRecognition.classify(image: imageView.image!, failure: failure){ Classifiers in
            for c in Classifiers.images[0].classifiers[0].classes {
                        result.append("\(c.className) ")
            }
            DispatchQueue.main.async {
                let translationViewController = self.storyboard!.instantiateViewController(withIdentifier: "TranslationVC") as! TranslationViewController
                translationViewController.textFromImage = result
                self.loadIndicator.stopAnimating()
                self.navigationController!.pushViewController(translationViewController, animated: true)
            }
        }
    }

    func showAlert(message:String) -> Void {
        let alert = UIAlertController(title: "",message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
