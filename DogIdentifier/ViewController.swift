//
//  ViewController.swift
//  DogIdentifier
//
//  Created by Shiguo Feng on 2023-04-01.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let uniqueLabels = ["affenpinscher", "afghan_hound", "african_hunting_dog", "airedale", "american_staffordshire_terrier", "appenzeller", "australian_terrier", "basenji", "basset", "beagle", "bedlington_terrier", "bernese_mountain_dog", "black-and-tan_coonhound", "blenheim_spaniel", "bloodhound", "bluetick", "border_collie", "border_terrier", "borzoi", "boston_bull", "bouvier_des_flandres", "boxer", "brabancon_griffon", "briard", "brittany_spaniel", "bull_mastiff", "cairn", "cardigan", "chesapeake_bay_retriever", "chihuahua", "chow", "clumber", "cocker_spaniel", "collie", "curly-coated_retriever", "dandie_dinmont", "dhole", "dingo", "doberman", "english_foxhound", "english_setter", "english_springer", "entlebucher", "eskimo_dog", "flat-coated_retriever", "french_bulldog", "german_shepherd", "german_short-haired_pointer", "giant_schnauzer", "golden_retriever", "gordon_setter", "great_dane", "great_pyrenees", "greater_swiss_mountain_dog", "groenendael", "ibizan_hound", "irish_setter", "irish_terrier", "irish_water_spaniel", "irish_wolfhound", "italian_greyhound", "japanese_spaniel", "keeshond", "kelpie", "kerry_blue_terrier", "komondor", "kuvasz", "labrador_retriever", "lakeland_terrier", "leonberg", "lhasa", "malamute", "malinois", "maltese_dog", "mexican_hairless", "miniature_pinscher", "miniature_poodle", "miniature_schnauzer", "newfoundland", "norfolk_terrier", "norwegian_elkhound", "norwich_terrier", "old_english_sheepdog", "otterhound", "papillon", "pekinese", "pembroke", "pomeranian", "pug", "redbone", "rhodesian_ridgeback", "rottweiler", "saint_bernard", "saluki", "samoyed", "schipperke", "scotch_terrier", "scottish_deerhound", "sealyham_terrier", "shetland_sheepdog", "shih-tzu", "siberian_husky", "silky_terrier", "soft-coated_wheaten_terrier", "staffordshire_bullterrier", "standard_poodle", "standard_schnauzer", "sussex_spaniel", "tibetan_mastiff", "tibetan_terrier", "toy_poodle", "toy_terrier", "vizsla", "walker_hound", "weimaraner", "welsh_springer_spaniel", "west_highland_white_terrier", "whippet", "wire-haired_fox_terrier", "yorkshire_terrier"]

    let imagePicker = UIImagePickerController()
    let model = try? DogC(configuration: MLModelConfiguration())
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType  = .camera
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            guard let convertedCIImage = CIImage(image: userPickedImage) else{
//                fatalError("cannot convert to CIImage")
//            }
            imageView.image = userPickedImage
            detect(image: userPickedImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: UIImage) {
        let input = try? DogCInput(input_1With: image.cgImage!)
        let output = try? model?.predictions(inputs: [input!])
        let probs = output![0].Identity
        
        if let b = try? UnsafeBufferPointer<Float>(probs) {
            let probsArray = Array(b)
//            if let maxIndex = probsArray.firstIndex(of: probsArray.max()!) {
//                print(uniqueLabels[maxIndex])
//            }
            let sortedProbsArray = probsArray.enumerated().sorted { $0.element > $1.element }
            let top3 = sortedProbsArray.prefix(3)
            for (index, value) in top3 {
                print("Index: \(index), Label: \(uniqueLabels[index]), Value: \(value)")
            }
        }

    }

    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType  = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func albumTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType  = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
}

