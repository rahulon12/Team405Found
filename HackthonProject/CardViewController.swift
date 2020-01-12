//
//  CardViewController.swift
//  HackthonProject
//
//  Created by Rahul Narayanan on 1/11/20.
//  Copyright © 2020 Rahul Narayanan. All rights reserved.
//

import UIKit
import Kanna
import Alamofire

class CardViewController: UIViewController {

    @IBOutlet var handleArea: UIView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var challengeLabel: UILabel!
    
    
    var descriptionLabel: UILabel!
    var tableView: UITableView!
    
    var level: Level!
    
    var currentFlower = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        switch level.gameMode {
        case .seek:
            let label = UILabel()
            label.text = "You have to find a \(level.flowers?.first ?? "?")"
            label.frame = CGRect(x: self.view.center.x-185, y: self.view.center.y-100, width: self.view.frame.width, height: 100)
            //label.center = self.view.center
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
            self.view.addSubview(label)
            break
        case .explore:
            descriptionLabel = UILabel(frame: CGRect(x: self.view.center.x-185, y: self.view.center.y-300, width: self.view.frame.width, height: 500))
            descriptionLabel.textAlignment = .center
            descriptionLabel.font = UIFont.systemFont(ofSize: 24, weight: .ultraLight)
            descriptionLabel.numberOfLines = 10
            descriptionLabel.minimumScaleFactor = 0.4
            self.view.addSubview(descriptionLabel)
        case .learn:
            tableView = UITableView(frame: CGRect(x: self.view.center.x-185, y: self.view.center.y-119, width: self.view.frame.width, height: self.view.frame.height))
            tableView.dataSource = self
            tableView.delegate = self
            self.view.addSubview(tableView)
        }
        
        challengeLabel.text = "Swipe up to " + level.description
        
    }
    
//    // Grabs the HTML from nycmetalscene.com for parsing.
//    func scrapeWiki() -> Void {
//        Alamofire.request("https://www.google.com/search?q=rose&oq=rose&aqs=chrome..69i57j0l7.447j0j8&sourceid=chrome&ie=UTF-8").responseString { response in
//            print("\(response.result.isSuccess)")
//            if let html = response.result.value {
//                self.parseHTML(html: html)
//            }
//        }
//    }
//
//    func parseHTML(html: String) -> Void {
//        // Finish this next
//
//        do {
//
//            let doc = try Kanna.HTML(html:html, encoding: String.Encoding.utf8)
//            print(doc.xpath("/html/body/div[7]/div[3]/div[10]/div[1]/div[3]/div[2]/div[1]/div[1]/div[1]/div/div[2]/div/div[1]/div/div/div/div/span[1]/text()"))
//            /*for link in doc.xpath("/html/body/div[7]/div[3]/div[10]/div[1]/div[3]/div[2]/div[1]/div[1]/div[1]/div/div[2]/div/div[1]/div/div/div/div/span[1]/text()") {
//                print(link)
//
//            }
//            */
//        } catch let error {
//                print(error)
//        }
//
//        ///html/body/div[7]/div[3]/div[10]/div[1]/div[3]/div[2]/div[1]/div[1]/div[1]/div/div[2]/div/div[1]/div/div/div/div/span[1]/text()
//
//
//
//
//    }

    

}

extension CardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flowers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = flowers[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if flowers[indexPath.row] == self.currentFlower {
            let alert = UIAlertController(title: "Great job!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back to menu", style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Wrong answer", message: "Correct Answer was \(self.currentFlower)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back to menu", style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}
