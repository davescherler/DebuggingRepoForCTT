//
//  ContainerViewController.swift
//  CloserToTruth
//
//  Created by Dave Scherler on 4/15/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case MenuExpanded
}

class ContainerViewController: UIViewController, DisplayViewControllerDelegate, PassingQuote, ShowingQuote {
    //create an instance of the model
    var model = QuoteModel()
    // ALEXIS: the favQuotes data needs to be called in ContainerVC, maybe later it can be called in a different file, just like allQuotes comes from QuoteModel
    var favQuotesData = [QuoteData]()
    
    
    var mainNavigationController: UINavigationController!
    var displayViewController: DisplayViewController!
    var currentState: SlideOutState = .BothCollapsed { didSet {
        let shouldShowShadow = currentState != .BothCollapsed
        showShadowForDisplayViewController(shouldShowShadow)
        }}
    var menuViewController: MenuViewController?
    let displayVCExpandedOffset: CGFloat = 60
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("ContainerVC: viewDidLoad()")
        // ALEXIS Adding ContainerViewVC as a delegate of model
        model.delegate = self
        
        displayViewController = UIStoryboard.displayViewController()
        displayViewController?.delegate = self

        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        mainNavigationController = UINavigationController(rootViewController: displayViewController)
        view.addSubview(mainNavigationController.view)
        addChildViewController(mainNavigationController)
        
        mainNavigationController.didMoveToParentViewController(self)
        println("the number of quote structs is \(model.quotes.count)")
        println("MenuViewVC: viewDidLoad()")

        
        // ALEXIS: Now loading the data from the Favorites plist
        // bookmarksPath is a string that is the path to the Favorites.plist file
        var bookmarksPath = NSBundle.mainBundle().pathForResource("Favorites", ofType: "plist")
        var bookmarks = NSMutableArray(contentsOfFile: bookmarksPath!)
        if bookmarks!.count > 0 {
            println("ContainerVC: viewDidLoad() number of objects stored in plist is > 0 at \(bookmarks!.count)")
            refreshFavoritesList()
        } else {
            println("ContainerVC: viewDidLoad() number of objects stored in plist is: \(bookmarks!.count)")
        }
    }
    //all these functions are just to call and show the menu screens.
    func addMenuViewController() {
        println("ContainerVC: addMenuViewController()")
        
        if (menuViewController == nil) {
            
            menuViewController = UIStoryboard.menuViewController()
            menuViewController?.delegate = self
            //pass quotes text to menuViewController
            menuViewController!.quotesText = model.quotes
            menuViewController!.favQuotesData = self.favQuotesData
            println("ContainerVC: adding \(self.favQuotesData.count) quotes to MenuVC favQuotesData")
            addChildMenuViewController(menuViewController!)
        }
    }
    
    func addChildMenuViewController(menuViewController: MenuViewController) {
        println("ContainerVC: addChildMenuViewController()")
        view.insertSubview(menuViewController.view, atIndex: 0)
        addChildViewController(menuViewController)
        menuViewController.didMoveToParentViewController(self)
    }
    
    func animateMenu(#shouldExpand: Bool) {
//        println("ContainerVC: animateMenu()")
        if (shouldExpand) {
            currentState = .MenuExpanded
            
            animateMainViewControllerXPosition(targetPosition: CGRectGetWidth(mainNavigationController.view.frame) - displayVCExpandedOffset)
            
        } else {
            animateMainViewControllerXPosition(targetPosition: 0) { finished in
                self.currentState = .BothCollapsed
                self.menuViewController!.view.removeFromSuperview()
                self.menuViewController = nil;
            }
        }
    }
    
    func animateMainViewControllerXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
//        println("ContainerVC: animateMainViewControllerXPosition()")
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.mainNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForDisplayViewController(shouldShowShadow: Bool) {
//        println("ContainerVC: showShadowForMainViewController()")
        if (shouldShowShadow) {
            mainNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            mainNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    func toggleMenu() {
        println("ContainerVC: toggleMenu()")
        let notAlreadyExpanded = (currentState != .MenuExpanded)
        
        if notAlreadyExpanded {
            addMenuViewController()
        }
        animateMenu(shouldExpand: notAlreadyExpanded)
//        println("finished running toggleMenu")
    }
    
    func refreshFavoritesList() {
        println("ContainerVC: refreshFavoritesList()")
        var bookmarksPath = NSBundle.mainBundle().pathForResource("Favorites", ofType: "plist")
        var bookmarks = NSMutableArray(contentsOfFile: bookmarksPath!)
        // ALEXIS: empty favQuotesData and reload with the latest from the plist
            self.favQuotesData = []
            for i in bookmarks! {
                var favQuoteFromPlist = QuoteData()
                favQuoteFromPlist.quoteText = i["quote_text"] as! String
                favQuoteFromPlist.authorName = i["contributor_name"] as! String
                favQuoteFromPlist.termName = i["term_name"] as! String
                favQuoteFromPlist.contributorID = i["contributor_id"] as! String
                favQuoteFromPlist.drupalInterviewURL = i["drupal_interview_url"] as! String
                favQuoteFromPlist.quoteID = i["quote_id"] as! String
                
                self.favQuotesData.append(favQuoteFromPlist)
            }
    }
    
    func passingTodaysQuote(index: Int) {
        // The purpose of this method is to update the quote on the DisplayVC with today's quote from JSON
            let quoteSelected = self.model.retrieveTodaysQuote(index)
            self.displayViewController.quoteDataToDisplay = quoteSelected
        println("ContainerVC passingTodaysQuote(): checking if the quote is a favorite")
        var isFavoriteQuote = checkIfFavorite(quoteSelected.quoteID)
        
        if isFavoriteQuote == false {
            self.displayViewController.isFavorite = false
            self.displayViewController.bookmarkButton.setImage(displayViewController.bookmarkPlainImage, forState: .Normal)
        } else {
            self.displayViewController.isFavorite = true
            self.displayViewController.bookmarkButton.setImage(displayViewController.bookmarkFillImage, forState: .Normal)
        }

        
    }
    
    func didSelectQuoteAtIndex(index: Int) {
        println("ContainerVC: function called by the MenuVC table")
        let quoteSelected = self.model.quoteAtIndex(index)
        self.displayViewController.quoteDataToDisplay = quoteSelected
        toggleMenu()
        updateBackgroundImage()
    }
    
    
    func showSelectedQuote(index: Int, listOrigin: String) {
        println("ContainerVC: showSelectedQuote() called by the MenuVC table")
        var quoteSelected = QuoteData()
        var quoteId = String()
        if listOrigin == "All" {
            quoteSelected = self.model.quoteAtIndex(index)
            quoteId = quoteSelected.quoteID
        } else {
            quoteSelected = self.favQuotesData[index]
            quoteId = quoteSelected.quoteID
            println("ContainerVC showSelectedQuote() favQuotesData is \(self.favQuotesData.count) long")
        }
        self.displayViewController.quoteDataToDisplay = quoteSelected
        println("Container showSelectedQuote(): check if quote is favorite or not")
        var isFavoriteQuote = checkIfFavorite(quoteId)
        
        if isFavoriteQuote == false {
        self.displayViewController.isFavorite = false
        self.displayViewController.bookmarkButton.setImage(displayViewController.bookmarkPlainImage, forState: .Normal)
        } else {
           self.displayViewController.isFavorite = true
           self.displayViewController.bookmarkButton.setImage(displayViewController.bookmarkFillImage, forState: .Normal)
        }
        
        toggleMenu()
        updateBackgroundImage()
    }
    
    func checkIfFavorite(quoteIdToCheck: String)->Bool{
        var resultOfCheck = false
        // Creating an array of quote IDs that we will use for reference
        var favQuotesIdArray:[String] = []
        
        // Creating a mutable array that stores all the favorite quotes
        var bookmarksPath = NSBundle.mainBundle().pathForResource("Favorites", ofType: "plist")
        var bookmarks = NSMutableArray(contentsOfFile: bookmarksPath!)
        
        // Populating favQuotesIdArray with the IDs of the saved quotes in the Favorites.plist
        if bookmarks!.count > 0 {
            for i in bookmarks! {
                favQuotesIdArray.append(i["quote_id"] as! NSString as String)
            }
            println("ContainerVC checkIfFavorite(): bookmarks IDs are now: \(favQuotesIdArray)")
        }
        
        for i in 0..<favQuotesIdArray.count {
            if favQuotesIdArray[i] == quoteIdToCheck {
                println("found the id at position \(i)")
                resultOfCheck = true
                break
            }
        }
        println("End of checkIfFavorite(): the result is \(resultOfCheck)")
        return resultOfCheck
    }
    
    func updateBackgroundImage() {
        var imagePath = NSBundle.mainBundle().pathForResource("BackgroundImageList", ofType: "plist")
        var imageNames = NSArray(contentsOfFile: imagePath!)
        //println("the image names are: \(imageNames)")
        
        var numberOfImages = imageNames?.count
        var randomNumber = Int(arc4random_uniform(UInt32(numberOfImages!)))
        //println("MainViewVC: There are:\(numberOfImages) images and the random number is:\(randomNumber)")
        
        let imageArray: [String] = imageNames as! Array
        
        var randomImageName = imageArray[randomNumber]
        //println("the random image is: \(randomImageName)")
        
        displayViewController!.backgroundImage.image = UIImage(named: randomImageName)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func menuViewController() -> MenuViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MenuVC") as? MenuViewController
    }
    
    class func displayViewController() -> DisplayViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DisplayVC") as? DisplayViewController
    }
}
