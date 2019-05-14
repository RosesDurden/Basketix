//
//  ViewController.swift
//  BasketixIOS
//
//  Created by Roses on 28/04/2019.
//  Copyright © 2019 Sebastien Glass. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var joueurImage: UIImageView!
    
    @IBOutlet weak var nomPrenomJoueur: UILabel!
    
    @IBOutlet weak var nbChamp: UILabel!
    
    @IBOutlet weak var descriptionJoueur: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle left and right swipes
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async() {
            self.selectRandomPlayer()
        }
    }
    
    //func to use to recognize gesture on view
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right ||
            gesture.direction == UISwipeGestureRecognizer.Direction.left
       {
        self.selectRandomPlayer()
       }
    }
    
    func selectRandomPlayer(){
        guard let url = URL(string: "https://stopauxregimes.fr/MonWebService/api/getjoueurbyid.php")
            else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Erreur en réponse")
                    return }
            do{
                //Ici, dataResponse est issue d'une requête réseau
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                print(jsonResponse) //Response result
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
                // Sélectionne une photo aléatorie entre 1 et 3
                let number = Int.random(in: 1 ... 3)
                let stringNumber = "\(number)"
                
                guard let Photo1 = jsonArray[0]["Photo"+stringNumber] as? String else { return }
                let imageURL1:URL=URL(string: Photo1)!
                self.downloadImage(from: imageURL1)
                
                guard let NomJoueur = jsonArray[0]["NomJoueur"] as? String else { return }
                
                guard let Informations = jsonArray[0]["Informations"] as? String else { return }
                
                guard let RecompensesIndividuelles = jsonArray[0]["RecompensesIndividuelles"] as? String else { return }
                
                guard let PerfsIndividuelles = jsonArray[0]["PerfsIndividuelles"] as? String else { return }
                
                guard let FaitsMarquants = jsonArray[0]["FaitsMarquants"] as? String else { return }
                
                let DescriptionJoueur = Informations + "\n\n" + RecompensesIndividuelles + "\n\n" +
                    PerfsIndividuelles + "\n\n" + FaitsMarquants
                
                guard let NbChampion = jsonArray[0]["NbChampion"] as? String else { return }
                
                self.remplirInfo(NomJoueur: NomJoueur, Description: DescriptionJoueur, NbChampion: NbChampion)
                
            } catch let parsingError {
                print("Erreur", parsingError)
            }
        }
        task.resume()
    }
    
    func remplirInfo(NomJoueur: String, Description: String, NbChampion: String){
        DispatchQueue.main.async() {
            self.nomPrenomJoueur.text = NomJoueur
            // Mise en forme du textView
            self.descriptionJoueur.text = Description
            self.descriptionJoueur.layer.cornerRadius = 5
            self.descriptionJoueur.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            self.descriptionJoueur.layer.borderWidth = 0.5
            self.descriptionJoueur.clipsToBounds = true
            self.descriptionJoueur.scrollRangeToVisible(NSRange(location:0, length:0))
        }
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                UIView.transition(with: self.joueurImage,
                                  duration: 0.75,
                                  //options: .transitionFlipFromLeft,
                                  options:.transitionCurlUp,
                                  animations: { self.joueurImage.image =  UIImage(data: data) },
                                  completion: nil)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            selectRandomPlayer()
        }
    }

}

extension UIImageView {
    func loadurl(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
