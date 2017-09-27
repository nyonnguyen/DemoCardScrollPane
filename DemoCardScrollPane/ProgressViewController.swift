//
//  ProcessViewController.swift
//  HocLaiXe
//
//  Created by Admin on 7/22/16.
//  Copyright © 2016 Han Luong. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPageViewControllerDelegate {

    @IBOutlet weak var processBar: KDCircularProgress!
    @IBOutlet weak var processLabel: UILabel!
    
    @IBOutlet weak var learnCollectionView: UICollectionView!
    @IBOutlet weak var page: UIPageControl!
    
    // The progress of learner - This value should be stored in database
    var completedPercentage = 65
    
    let learnModeCellSize = CGSize(width: 156, height: 200)
    let spaceBetweenCell = CGFloat(60)
    
    // Init page indicator values
    var currentIndex = 1
    var endIndex = 1
    
    // create the Menu
    lazy var menuCollectionView: MenuCollectionView = {
        let menu = MenuCollectionView()
        return menu
    }()
    
    // create an search
    lazy var SearchBar: ProgressSearchBar = {
        let searchBar = ProgressSearchBar()
        return searchBar
    }()
    
    // list question
    var listQuestion: [Question] = [Question]()
    
    // Declaration: Learn Mode collection view
    var pageIndex: Int = 0
    var pageSize: CGFloat {
        return CGFloat(spaceBetweenCell + learnModeCellSize.width)
    }
    let cellId = "learnModeCellId"
    
    var modes: [LearnMode] = [LearnMode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init collection view
        learnCollectionView.delegate = self
        learnCollectionView.dataSource = self
        
        // set the container height for search box
        self.SearchBar.containterHeight = self.view.frame.height
        
        //For typing in search box
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Swipe Left to Right to show Menu
        let swipeGestureShowMenu = UISwipeGestureRecognizer(target: self, action: #selector(handleMenu))
        swipeGestureShowMenu.direction = [.right]
        view.addGestureRecognizer(swipeGestureShowMenu)
        
        //get list question
        listQuestion = g_factoryQuestions.getListQuestions()
        
        //get list learn mode
        modes = g_learnModes.getListLearnMode()
        
        //Initialing info
        completedPercentage = g_factoryQuestions.numOfTotalQuestionCompleted()
        
        // setup circle process
        processLabel.text = String(completedPercentage*100/listQuestion.count) + "%"
        processBar.startAngle = -90
        processBar.angle = (Double(completedPercentage)*360)/Double(listQuestion.count)
        
        // init learn mode
        page.numberOfPages = modes.count
        page.currentPage = pageIndex
        
        learnCollectionView.reloadData()
    }
    
    func keyboardWillShow(_ notify: Notification) {
        self.SearchBar.keyboardHeight = (((notify as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height)!
        self.SearchBar.reDrawSearchBox()
    }
    
    func keyboardWillHide(_ notify: Notification) {
        self.SearchBar.keyboardHeight = 0
        self.SearchBar.reDrawSearchBox()
    }
    
    //Hide status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func handleMenu(_ sender: AnyObject) {
        menuCollectionView.showMenu()
    }
    
    @IBAction func handleSearch(_ sender: AnyObject) {
        // set data for the search box
        SearchBar.store = g_factoryQuestions.getListQuestions()
        
        // display search box
        SearchBar.createSearchBox()
    }
    
    func hideSearchBox() {
        // hide it
        SearchBar.hideSearchBox()
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
        let modeNumOfAnswers = learnMode.getNumberOfAnsersCompleted()
        let modeNumOfQuestions = learnMode.getNumberOfQuestion()
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
            let storyboard = UIStoryboard.init(name: "Learn", bundle: nil)
            let screen = storyboard.instantiateViewController(withIdentifier: "LearnViewController") as! LearnViewController
            screen.typeOfQuestion = modes[indexPath.item].questionType
            self.present(screen, animated: true, completion: nil)
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
    
}
