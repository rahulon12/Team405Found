//
//  HomeViewController.swift
//  HackthonProject
//
//  Created by Rahul Narayanan on 1/11/20.
//  Copyright © 2020 Rahul Narayanan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    let cellScaling: CGFloat = 0.6
    
    var levels = [Level]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupLevels()
        setupCollectionView()
        
        
    }
    
    func setupLevels(){
        
        let level1 = Level(name: "Seek", time: 300, flowers: nil, image: UIImage(systemName: "hare.fill")!)
        let level2 = Level(name: "Explore", time: nil, flowers: nil, image: UIImage(systemName: "magnifyingglass.circle")!)
        let level3 = Level(name: "Learn", time: nil, flowers: nil, image: UIImage(systemName: "book.circle")!)
        
        levels = [level1, level2, level3]
        
        
    }
    
    fileprivate func setupCollectionView() {
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * cellScaling)
        
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        collectionView.reloadData()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return levels.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ChallengeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChallengeCollectionViewCell
        
        cell.setup(level: levels[indexPath.item])
        
        return cell
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(identifier: "gameView") as! GameViewController
        
        vc.level = levels[indexPath.item]
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}
