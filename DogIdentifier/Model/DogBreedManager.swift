//
//  DogBreedManager.swift
//  DogIdentifier
//
//  Created by Shiguo Feng on 2023-04-13.
//

import Foundation
import CoreML
import UIKit
import Alamofire
import SwiftyJSON

protocol DogBreedManagerDelegate {
    func updateDisplay(_ DogBreedManager: DogBreedManager, dogDescription: String, dogImageURL: String)
}
struct DogBreedManager {
    
    let uniqueLabels = ["Affenpinscher", "Afghan Hound", "African Hunting Dog", "Airedale Terrier", "American Staffordshire Terrier", "Appenzeller Sennenhund", "Australian Terrier", "Basenji", "Basset", "Beagle", "Bedlington Terrier", "Bernese Mountain Dog", "Black-and-tan Coonhound", "Blenheim Spaniel", "Bloodhound", "Bluetick", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier Des Flandres", "Boxer (dog)", "Brabancon Griffon", "Briard", "Brittany Spaniel", "Bull Mastiff", "Cairn Terrier", "Cardigan Welsh Corgi", "Chesapeake Bay Retriever", "Chihuahua (dog)", "Chow (dog)", "Clumber Spaniel", "Cocker Spaniel", "Collie", "Curly-coated Retriever", "Dandie Dinmont", "Dhole", "Dingo", "Doberman", "English Foxhound", "English Setter", "English Springer", "Entlebucher", "American Eskimo Dog", "Flat-coated Retriever", "French Bulldog", "German Shepherd", "German Short-haired Pointer", "Giant Schnauzer", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Groenendael", "Ibizan Hound", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Japanese Spaniel", "Keeshond", "Australian Kelpie", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lakeland Terrier", "Leonberger", "Lhasa Apso", "Malamute", "Belgian Shepherd", "Maltese Dog", "Xoloitzcuintle", "Miniature Pinscher", "Miniature Poodle", "Miniature Schnauzer", "Newfoundland dog", "Norfolk Terrier", "Norwegian Elkhound", "Norwich Terrier", "Old English Sheepdog", "Otterhound", "Papillon dog", "Pekinese", "Pembroke Welsh Corgi", "Pomeranian dog", "Pug", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "St. Bernard (dog)", "Saluki", "Samoyed dog", "Schipperke", "Scotch Terrier", "Scottish Deerhound", "Sealyham Terrier", "Shetland Sheepdog", "Shih-tzu", "Siberian Husky", "Silky Terrier", "Soft-coated Wheaten Terrier", "Staffordshire Bull Terrier", "Standard Poodle", "Standard Schnauzer", "Sussex Spaniel", "Tibetan Mastiff", "Tibetan Terrier", "Toy Poodle", "Toy Terrier", "Vizsla", "Treeing Walker Coonhound", "Weimaraner", "Welsh Springer Spaniel", "West Highland White Terrier", "Whippet", "Wire Fox Terrier", "Yorkshire Terrier"]
    
    let wikipediaURL = "https://www.wikipedia.org/w/api.php"
    var delegate: DogBreedManagerDelegate?
    
    let model = try? DogFullClassifier(configuration: MLModelConfiguration())
    
    func getPredictions(userPickedImage: UIImage) -> [DogBreed] {
        let probs = predicttionsFromModel(userPickedImage)
        let dogs = top2Prediction(probs)
        return dogs
    }
    
    func predicttionsFromModel(_ userPickedImage: UIImage) -> MLMultiArray {
        // Ensure that we have a CGImage from the userPickedImage
        guard let cgImage = userPickedImage.cgImage else {
            fatalError("Failed to get CGImage from userPickedImage.")
        }

        // Create an input from the CGImage
        guard let input = try? DogFullClassifierInput(input_1With: cgImage) else {
            fatalError("Failed to create input for the model.")
        }

        // Make predictions using the model and the input
        guard let output = try? model?.predictions(inputs: [input]) else {
            fatalError("Failed to create output for the model.")
        }

        // Extract the probabilities from the output
        let probs = output[0].Identity
        return probs
    }
    
    func top2Prediction(_ probs : MLMultiArray) -> [DogBreed] {
        var dogBreeds:[DogBreed] = []
        if let b = try? UnsafeBufferPointer<Float>(probs) {
            let probsArray = Array(b)
            let sortedProbsArray = probsArray.enumerated().sorted { $0.element > $1.element }
            let top2 = sortedProbsArray.prefix(2)
            for (index, value) in top2 {
                let dogName = uniqueLabels[index]
                dogBreeds.append(DogBreed(name: dogName, probability: value))
            }
            return dogBreeds
        }
        return []
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
                let dogDescription = dogJson["query"]["pages"][pageid]["extract"].stringValue
                let dogImageURL = dogJson["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                
                self.delegate?.updateDisplay(self, dogDescription: dogDescription, dogImageURL: dogImageURL)
            } else {
                print("fail to get wiki.")
            }
        }
    }
    
    
}
