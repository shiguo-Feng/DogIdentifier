//
//  ViewController.swift
//  DogIdentifier
//
//  Created by Shiguo Feng on 2023-04-01.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let uniqueLabels = ["Affenpinscher", "Afghan Hound", "African Hunting Dog", "Airedale Terrier", "American Staffordshire Terrier", "Appenzeller Sennenhund", "Australian Terrier", "Basenji", "Basset", "Beagle", "Bedlington Terrier", "Bernese Mountain Dog", "Black-and-tan Coonhound", "Blenheim Spaniel", "Bloodhound", "Bluetick", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier Des Flandres", "Boxer (dog)", "Brabancon Griffon", "Briard", "Brittany Spaniel", "Bull Mastiff", "Cairn Terrier", "Cardigan Welsh Corgi", "Chesapeake Bay Retriever", "Chihuahua (dog)", "Chow (dog)", "Clumber Spaniel", "Cocker Spaniel", "Collie", "Curly-coated Retriever", "Dandie Dinmont", "Dhole", "Dingo", "Doberman", "English Foxhound", "English Setter", "English Springer", "Entlebucher", "American Eskimo Dog", "Flat-coated Retriever", "French Bulldog", "German Shepherd", "German Short-haired Pointer", "Giant Schnauzer", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Groenendael", "Ibizan Hound", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Japanese Spaniel", "Keeshond", "Australian Kelpie", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lakeland Terrier", "Leonberger", "Lhasa Apso", "Malamute", "Belgian Shepherd", "Maltese Dog", "Xoloitzcuintle", "Miniature Pinscher", "Miniature Poodle", "Miniature Schnauzer", "Newfoundland dog", "Norfolk Terrier", "Norwegian Elkhound", "Norwich Terrier", "Old English Sheepdog", "Otterhound", "Papillon dog", "Pekinese", "Pembroke Welsh Corgi", "Pomeranian dog", "Pug", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "St. Bernard (dog)", "Saluki", "Samoyed dog", "Schipperke", "Scotch Terrier", "Scottish Deerhound", "Sealyham Terrier", "Shetland Sheepdog", "Shih-tzu", "Siberian Husky", "Silky Terrier", "Soft-coated Wheaten Terrier", "Staffordshire Bull Terrier", "Standard Poodle", "Standard Schnauzer", "Sussex Spaniel", "Tibetan Mastiff", "Tibetan Terrier", "Toy Poodle", "Toy Terrier", "Vizsla", "Treeing Walker Coonhound", "Weimaraner", "Welsh Springer Spaniel", "West Highland White Terrier", "Whippet", "Wire Fox Terrier", "Yorkshire Terrier"]

    @IBOutlet weak var outputButton1: UIButton!
    @IBOutlet weak var outputButton2: UIButton!
    var buttons = [UIButton]()
    @IBOutlet weak var explainTextLabel: UILabel!
    let imagePicker = UIImagePickerController()
    let model = try? DogFullClassifier(configuration: MLModelConfiguration())
    let wikipediaURL = "https://www.wikipedia.org/w/api.php"
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
//        imagePicker.sourceType  = .camera
        updateViews()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        explainTextLabel.addGestureRecognizer(tapGesture)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            detect(image: userPickedImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: UIImage) {
        let buttons = [outputButton1, outputButton2]
        var color: UIColor
        let input = try? DogFullClassifierInput(input_1With: image.cgImage!)
        let output = try? model?.predictions(inputs: [input!])
        let probs = output![0].Identity
    

        
        if let b = try? UnsafeBufferPointer<Float>(probs) {
            let probsArray = Array(b)
            let sortedProbsArray = probsArray.enumerated().sorted { $0.element > $1.element }
            let top2 = sortedProbsArray.prefix(2)
            for (i, (index, value)) in top2.enumerated() {
                let label = uniqueLabels[index]
                let probability = String(format: "%.2f", value * 100)
                
                switch value {
                case 0.85...1:
                    color = UIColor.green
                case 0.65 ... 0.84:
                    color = UIColor.blue
                case 0.3 ... 0.64:
                    color = UIColor.gray
                default:
                    color = UIColor.red
                }
//                let text = "\(label) (\(probability)%)"
                buttons[i]?.isHidden = false
                let subtitle = "(\(probability)%)"
                let attributedText = NSMutableAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 18)])
                attributedText.append(NSAttributedString(string: "\n" + subtitle, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: color]))
                buttons[i]?.setAttributedTitle(attributedText, for: .normal)
//                buttons[i]?.setTitle(text, for: .normal)
//                self.requestWiki(dogName: uniqueLabels[index])
            }
        }
    }
    
    @objc func labelTapped(sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let alertController = UIAlertController(title: nil, message: label.text, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func requestWiki(dogName: String) {
        let parameters: [String:String] = [
            "format": "json",
            "action": "query",
            "prop": "extracts|pageimages",
            "exintro": "",
            "explaintext": "",
            "titles" : dogName,
            "indexpageids": "",
            "redirects": "1",
            "pithumbsize" : "500"
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
//                print("Success got the dog info")
//                print(response)
                
                let dogJson: JSON = JSON(response.result.value!)
                let pageid: String = dogJson["query"]["pageids"][0].stringValue
                let dogDescription: String = dogJson["query"]["pages"][pageid]["extract"].stringValue
                let dogImageURL = dogJson["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                
                self.imageView.sd_setImage(with: URL(string: dogImageURL))
                self.explainTextLabel.text = dogDescription
                self.explainTextLabel.isUserInteractionEnabled = true
            }
        }
    }
    func updateViews() {
        navigationItem.title = ""
        outputButton1.isHidden = true
        outputButton2.isHidden = true
        explainTextLabel.text = "Snap a pic or choose one from your gallery to uncover your furry friend's breed. Double-tap to learn more!"
        explainTextLabel.isUserInteractionEnabled = false
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        updateViews()
        imagePicker.sourceType  = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func albumTapped(_ sender: UIBarButtonItem) {
        updateViews()
        imagePicker.sourceType  = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func output1Tapped(_ sender: UIButton) {
        if let title = sender.currentAttributedTitle?.string {
            let dogName = title.components(separatedBy: "\n")[0]
            requestWiki(dogName: dogName)
            navigationItem.title = dogName
        }
    }

    @IBAction func output2Tapped(_ sender: UIButton) {
        if let title = sender.currentAttributedTitle?.string {
            let dogName = title.components(separatedBy: "\n")[0]
            requestWiki(dogName: dogName)
            navigationItem.title = dogName
        }
    }
}

