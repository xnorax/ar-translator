//
//  FormViewController.swift
//  ARTranslator
//
//  Created by Nora AlNashwan on 21/06/2018.
//  Copyright © 2018 Nora AlNashwan. All rights reserved.
//

import UIKit
import Eureka
import LanguageTranslatorV2

class TranslationViewController: FormViewController,  UINavigationControllerDelegate {
    
    var textFromImage: String!
    var languageList = [String:String]()
    var languageNames = [String]()
    var languageTranslator: LanguageTranslator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        languageTranslator = LanguageTranslator(username: Credentials.tr_username, password: Credentials.tr_password)
        
        languageList = ["Arabic":"ar",
            "Chinese (Simplified)":"zh",
            "Chinese (Traditional)":"zh-TW",
            "Dutch":"nl",
            "English":"en",
            "French":"fr",
            "German":"de",
            "Italian":"it",
            "Japanese":"ja",
            "Korean":"ko",
            "Polish":"pl",
            "Portuguese":"pt",
            "Russian":"ru",
            "Spanish":"es",
            "Turkish":"tr"]
       
            for (key, _) in self.languageList {
                self.languageNames.append(key)
            }
            self.setUpForm()
    }
    
    private func setUpForm() {
        form
            +++ Section("Text to translate")
            <<< TextAreaRow("from") { row in
                row.value = textFromImage
                row.textAreaHeight = .dynamic(initialTextViewHeight: 150)
                }
            
            <<< AlertRow<String>("languageTo") { row in
                row.options = languageNames
                row.title = "Translate to"
                row.selectorTitle = "Detect Language"
                row.value = "Detect Language"
                }.onChange({ (row) in
                    let params = self.fetchFormValues()
                    let failure = { (error: Error) in
                        let alertController = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true)
                    }
                    let request = TranslateRequest(text: [params["from"]!], modelID: "en-"+params["target"]!+"-conversational")
                    self.languageTranslator.translate(request: request, failure: failure) { translation in
                        DispatchQueue.main.async {
                            self.form.rowBy(tag: "translatedText")?.value = translation.translations[0].translationOutput
                            self.form.rowBy(tag: "translatedText")?.reload()
                        }
                    }
                })
            
            +++ Section("Translated text")
            <<< TextAreaRow("to") { row in
                row.tag = "translatedText"
                row.placeholder = "Translated text"
                row.textAreaHeight = .dynamic(initialTextViewHeight: 150)
        }
    }
    
    private func fetchFormValues() -> [String: String] {
        var params: [String: String] = [:]
        let formValues = form.values()
        params["source"] = "en"
        if let translateFromText = formValues["from"] as? String {
            params["from"] = translateFromText
        }
        if let languageTo = formValues["languageTo"] as? String {
            params["target"] = self.extractLanguageCodeFromLanguageName(name: languageTo)
        }
        return params
    }

    private func extractLanguageCodeFromLanguageName(name: String) -> String? {
        for (key, value) in self.languageList {
            if name == key {
                return value
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
