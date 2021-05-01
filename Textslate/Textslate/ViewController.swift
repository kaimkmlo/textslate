//
//  ViewController.swift
//  Textslate
//
//  Created by Kaiming Lo on 10/24/20.
//

import UIKit
import Vision

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var detectedLanguage: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var detectedText: UITextView!
    @IBOutlet weak var translatedLanguageLabel: UITextField!
    @IBOutlet weak var translatedText: UITextView!
    
    var languages = [String]()
    var languageCode = [String]()
    var imagePicker = UIImagePickerController()
    var recognisedTexts: String? = ""
    var languagePicker: UIPickerView! = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //translatedLanguage.setTitle("\(languages[0])", for: .normal)
        
        languages =
            ["English","Chinese","Japanese","Korean"]
        languageCode = ["en","zh-TW","ja","ko"]
        
        translatedLanguageLabel.isHidden = false
        //languagePicker.isHidden = true
        
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
        translatedLanguageLabel.delegate = self
        
        }
    
    func languagePickerView(textField: UITextField){
        //languagePicker.isHidden = false
        

        translatedLanguageLabel.inputView = self.languagePicker
        
        // Adding Toolbar for languagePicker
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100.0, height: 44.0))
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        //toolbar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        //toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ViewController.doneButton))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.cancelButton))
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        translatedLanguageLabel.inputAccessoryView = toolbar
    }
    
    @objc func doneButton() {
        self.translatedLanguageLabel.resignFirstResponder()
        }

    @objc func cancelButton() {
        self.translatedLanguageLabel.resignFirstResponder()
    }
    
    // **********Language Picker********
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return languages.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // Show selected language
        translatedLanguageLabel.text = "\(languages[row])"
        translatedLanguageLabel.isHidden = false
        
        // Set language code for translate() function
        TranslateAPI.apiManager.languageCode = self.languageCode[row]
        
        TranslateAPI.apiManager.translate(completion: {(translations) in
            if let translations = translations {
                print("translation available")
                DispatchQueue.main.async {
                    self.translatedText.text = "\(translations)"
                }
            }else{
                print("translation=nil")
            }
        })
        
        
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        self.languagePickerView(textField: translatedLanguageLabel)
    }
    
    
    //********************************
    
    
    //********TEXT RECOGNITION********
    func process(image: UIImage) {
            guard let imageData = image.pngData() else { return }
            let requestHandler = VNImageRequestHandler(data: imageData, options: [:])
            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                self.recognisedTexts = ""
                self.recognisedTexts?.append("")
                for observation in observations {
                    let candtidates = observation.topCandidates(1)
                    for candidate in candtidates {
                        self.recognisedTexts?.append("\(candidate.string)\n")
                        //(\(candidate.confidence))
                        //self.populateLabel()
                    }
                }
                /*DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                    self.activityIndicator?.stopAnimating()
                }*/
            }
             
            // Showing progress of text recognition from the given image.
            /*request.progressHandler = { (request, completed, error) in
                DispatchQueue.main.async {
                    self.hideScannedImage()
                    self.recognisedTexts = ""
                    self.resultLabel.text = "Recognising..\((Int(completed * 100)))%"
                }
            }*/
            request.recognitionLevel = .accurate // Using accurate recognition level to process static scanned images
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.1 // Minimum image height is the fraction of the image height. I want to process texts which are at least 10% of image height, remaining texts will be ignored.
             
            //self.activityIndicator?.isHidden = false
            //self.activityIndicator?.startAnimating()
            do {
                try requestHandler.perform([request])
            }catch{
                print("Unable to perform the requests: \(error).")
            }
        
        self.detectedText.text = recognisedTexts
        TranslateAPI.apiManager.text = recognisedTexts
        print(recognisedTexts!)
        }
    
    
    
    
    
    
    //********************************
    
    // Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        print("selected")
        
        
            self.dismiss(animated: true, completion: { () -> Void in

            })
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.image.image = image
            
            process(image: image)
        }
            

        }
    
    // IBAction

    @IBAction func camera(_ sender: UIButton) {
    }
    
    
    @IBAction func cameraRoll(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    print("Button capture")

                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.allowsEditing = false

                    present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /*@IBAction func showLanguagePicker(_ sender: UIButton) {
        if languagePicker.isHidden == true{
            translatedLanguageLabel.isHidden = true
            languagePicker.isHidden = false
        }else{
        }
    }*/
    
}

