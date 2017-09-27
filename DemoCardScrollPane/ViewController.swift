//
//  ViewController.swift
//  DemoCardScrollPane
//
//  Created by Nyon Nguyen on 9/22/17.
//  Copyright © 2017 Nyon Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPageViewControllerDelegate {

    @IBOutlet weak var processBar: KDCircularProgress!
    @IBOutlet weak var processLabel: UILabel!
    
    @IBOutlet weak var learnCollectionView: UICollectionView!
    @IBOutlet weak var page: UIPageControl!

    // The progress of learner - This value should be stored in database
    var completedPercentage = 0
    
    let learnModeCellSize = CGSize(width: 175, height: 200)
    let spaceBetweenCell = CGFloat(40)
    
    // Init page indicator values
    var currentIndex = 1
    var endIndex = 1
    
    // Declaration: Learn Mode collection view
    var pageIndex: Int = 0
    var pageSize: CGFloat {
        return CGFloat(spaceBetweenCell + learnModeCellSize.width)
    }
    let cellId = "learnModeCellId"
    
    var modes: [LearnMode] = [
        LearnMode(title: "Card 1", questionType: "type1", numQuest: 10, numAnswer: 5),
        LearnMode(title: "Card 2", questionType: "type1", numQuest: 20, numAnswer: 4),
        LearnMode(title: "Card 3", questionType: "type1", numQuest: 15, numAnswer: 10),
        LearnMode(title: "Card 4", questionType: "type1", numQuest: 25, numAnswer: 20),
        LearnMode(title: "Card 5", questionType: "type1", numQuest: 10, numAnswer: 8)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init collection view
        learnCollectionView.delegate = self
        learnCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var totalQuest = 0
        var totalAnswer = 0
        for learnMode in modes {
            //print(" \(learnMode.numberOfAnswerCompleted)/\(learnMode.numberOfQuestion)")
            totalQuest += learnMode.numberOfQuestion
            totalAnswer += learnMode.numberOfAnswerCompleted
        }
        let percentageCompleted = self.calculatePercentage(totalQuest, numAnswer: totalAnswer)
        
        // setup circle process
        processLabel.text = String(Int(percentageCompleted)) + "%"
        processBar.startAngle = -90 // start at 12 o'clock
        processBar.angle = convertToCircularPercentage(percentageCompleted)
        
        // init learn mode
        page.numberOfPages = modes.count
        page.currentPage = pageIndex
        
        learnCollectionView.reloadData()
    }
    
    // MARK: Display settings
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Learn Mode collection view
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, (self.view.frame.width/2) - (self.learnModeCellSize.width/2), 0, (self.view.frame.width/2) - (self.learnModeCellSize.width/2))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LearnModeCell
        cell.title.text = modes[(indexPath as NSIndexPath).item].title
        
        let learnMode = modes[(indexPath as NSIndexPath).item]
        let modeNumOfAnswers = learnMode.numberOfAnswerCompleted
        let modeNumOfQuestions = learnMode.numberOfQuestion
        let percentage = self.calculatePercentage(modeNumOfQuestions, numAnswer: modeNumOfAnswers)
        
        cell.status.text = "Đã làm " + String(modeNumOfAnswers) + "/" + String(modeNumOfQuestions) + " câu"
        cell.percentage.text = String(Int(percentage)) + "%"
        cell.processBar.angle = convertToCircularPercentage(percentage)
        
        cell.backgroundColor = UIColor(white: 1, alpha: 0.2)
        
        cell.layer.cornerRadius = 5
        cell.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor;
        cell.layer.shadowOffset = CGSize(width: 5.0, height: 5.0);
        cell.layer.shadowRadius = 3.0;
        cell.layer.shadowOpacity = 1;
        cell.layer.masksToBounds = false;
        
        if (indexPath as NSIndexPath).item == pageIndex {
            cell.alpha = 1
        } else {
            cell.alpha = 0.3
            cell.scaleUpSize()
        }
        
        return cell
    }
    
    // do something when click on a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.item == pageIndex) {
            collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            let cell = collectionView.cellForItem(at: indexPath) as! LearnModeCell
            cell.poke()
            
            print(modes[(indexPath as NSIndexPath).item].title)
            
            //Goto Learn view
            //let storyboard = UIStoryboard.init(name: "Learn", bundle: nil)
            //let screen = storyboard.instantiateViewController(withIdentifier: "LearnViewController") as! LearnViewController
            //screen.typeOfQuestion = modes[indexPath.item].questionType
            //self.present(screen, animated: true, completion: nil)
        }
    }
    
    // set size for each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return learnModeCellSize
    }
    
    // set the space between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // size of page is depended on cells and space between them.
        // size of a page is calculated by adding the space between cells and the width of cell
        // scroll possition
        let xOffset = scrollView.contentOffset.x
        // the page index is caculated by:
        pageIndex = Int(floor((xOffset - pageSize / 2) / pageSize) + 1)
        page.currentPage = pageIndex
        
        for i in learnCollectionView.indexPathsForVisibleItems {
            let cell = learnCollectionView.cellForItem(at: i) as! LearnModeCell
            if (i as NSIndexPath).item == pageIndex {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.alpha = 1
                    cell.restoreSize()
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.alpha = 0.3
                    cell.scaleUpSize()
                }, completion: nil)
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: (pageSize)*CGFloat(pageIndex), y: scrollView.contentOffset.y), animated: true)
    }
    
    // MARK: Extension
    
    func calculatePercentage(_ numQuest: Int, numAnswer: Int) -> Double {
        return round(Double(numAnswer)/Double(numQuest)*100)
    }
    
    func convertToCircularPercentage(_ percentage: Double) -> Double {
        return percentage*360/100
    }
    
}
