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

class DogIdentifierViewController: UIViewController, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var outputButton1: UIButton!
    @IBOutlet weak var outputButton2: UIButton!
    
    var dogManager = DogBreedManager()
    var predictions: [DogBreed] = []
    var buttons = [UIButton]()
    
    @IBOutlet weak var explainTextLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        dogManager.delegate = self
        updateViews()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        explainTextLabel.addGestureRecognizer(tapGesture)
    }
    
    func detect(image: UIImage) {
        buttons = [outputButton1, outputButton2]
        predictions = dogManager.getPredictions(userPickedImage: image)
        
        for (i, dog) in predictions.enumerated() {
            buttons[i].isHidden = false
            let subtitle = "(\(dog.probabilityString)%)"
            let attributedText = NSMutableAttributedString(string: dog.name, attributes: [.font: UIFont.systemFont(ofSize: 18)])
            attributedText.append(NSAttributedString(string: "\n" + subtitle, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: dog.subtitleColor]))
            buttons[i].setAttributedTitle(attributedText, for: .normal)
        }
    }
    
    @objc func labelTapped(sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let alertController = UIAlertController(title: nil, message: label.text, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Got it!", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
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
    
    @IBAction func outputTapped(_ sender: UIButton) {
        if let title = sender.currentAttributedTitle?.string {
            let dogName = title.components(separatedBy: "\n")[0]
            navigationItem.title = dogName
            dogManager.requestWiki(dogName: dogName)
        }
    }
    
}

extension DogIdentifierViewController: DogBreedManagerDelegate {
    func updateDisplay(_ DogBreedManager: DogBreedManager, dogDescription: String, dogImageURL: String) {
        DispatchQueue.main.async {
            self.imageView.sd_setImage(with: URL(string: dogImageURL))
            self.explainTextLabel.text = dogDescription
            self.explainTextLabel.isUserInteractionEnabled = true
        }
    }
}
extension DogIdentifierViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            DispatchQueue.main.async {
                self.detect(image: userPickedImage)
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
