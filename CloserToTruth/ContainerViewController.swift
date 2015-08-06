//
//  ContainerViewController.swift
//  CloserToTruth CLEAN + CoreData Version
//
//  Created by Dave Scherler on 4/15/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData

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
    
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        println("Debugger: ContainerVC: viewDidLoad()")
        // ALEXIS Adding ContainerViewVC as a delegate of model
        model.delegate = self
        
        displayViewController = UIStoryboard.displayViewController()
        displayViewController?.delegate = self
        //displayViewController.randomizeInitialBackgroundImage()

        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        mainNavigationController = UINavigationController(rootViewController: displayViewController)
        view.addSubview(mainNavigationController.view)
        addChildViewController(mainNavigationController)
        
        mainNavigationController.didMoveToParentViewController(self)
//        println("Debugger: ContainerVC: the number of quote structs is \(model.quotes.count)")

        
        //Dave: Reading the number of favorites stored in Core Data 
        if let context = self.appDelegate.managedObjectContext {
            let fetchRequestForFavorites = NSFetchRequest(entityName: "Favorite")
            
            if let listOfReturnedFavorites: [Favorite] = context.executeFetchRequest(fetchRequestForFavorites, error: nil) as? [Favorite] {
//                println("Debugger: ContainerVC: At viewDidLoad, the current number of CoreData favs is :\(listOfReturnedFavorites.count)")
            } else {
//                println("Debugger: ContainerVC: there are no favs saved in CoreData")
            }
        }
        // We have to refresh the favorites list here for when the user closes the app completely.
        refreshFavoritesList()
        
        
    }
    //all these functions are just to call and show the menu screen
    func addMenuViewController() {
//        println("Debugger: ContainerVC: addMenuViewController()")
        
        if (menuViewController == nil) {
            
            menuViewController = UIStoryboard.menuViewController()
            menuViewController?.delegate = self
            //pass model.quotes to menuViewController. This model.quotes is an array that stores as quoteData structs
            //all the info from the "all quotes" JSON file 
            menuViewController!.quotesText = model.quotes
            //ALEXIS: lass model.taxonomy array to menuVC.
            
            //this line of code updates the favQuotesData array in the MenuViewController
            menuViewController!.favQuotesData = self.favQuotesData
//            println("Debugger: ContainerVC: adding \(self.favQuotesData.count) quotes to MenuVC favQuotesData")
            addChildMenuViewController(menuViewController!)
        }
    }
    
    func addChildMenuViewController(menuViewController: MenuViewController) {
//        println("Debugger: ContainerVC: addChildMenuViewController()")
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
//        println("Debugger: ContainerVC: toggleMenu()")
        let notAlreadyExpanded = (currentState != .MenuExpanded)
        
        if notAlreadyExpanded {
            addMenuViewController()
            refreshFavoritesList()
        }
        animateMenu(shouldExpand: notAlreadyExpanded)
//        println("finished running toggleMenu")
    }
    
    func refreshFavoritesList() {
//        println("Debugger: ContainerVC: refreshFavoritesList()")
        
        //Dave: updating the favorites list displayed in the MenuViewController
        //resetting the favQuotesData and then re-populating it. 
        self.favQuotesData = []
        
        if let context = self.appDelegate.managedObjectContext {
            
            let fetchRequestForFavorites = NSFetchRequest(entityName: "Favorite")
            
            if let listOfReturnedFavorites: [Favorite] = context.executeFetchRequest(fetchRequestForFavorites, error: nil) as? [Favorite] {
                
                for favorite in listOfReturnedFavorites as [Favorite] {
                    //create an instance of QuoteData struct
                    var favoriteStoredInCoreData = QuoteData()
                    favoriteStoredInCoreData.quoteText = favorite.quote_text as String
                    favoriteStoredInCoreData.authorName = favorite.contributor_name as String
                    favoriteStoredInCoreData.termName = favorite.term_name as String
//                    favoriteStoredInCoreData.termID = favorite.term_id as String
                    favoriteStoredInCoreData.contributorID = favorite.contributor_id as String
                    favoriteStoredInCoreData.drupalInterviewURL = favorite.drupal_interview_url as String
                    favoriteStoredInCoreData.kalturaVideoID = favorite.video_id as String
                    favoriteStoredInCoreData.quoteID = favorite.idOfQuote as String
//                    favoriteStoredInCoreData.featureDate = favorite.feature_date as String
                    
                    self.favQuotesData.append(favoriteStoredInCoreData)
                }
            }
        }
    }
    
    func passingTodaysQuote(index: Int) {
        // The purpose of this method is to update the quote on the DisplayVC with today's quote from JSON
            let quoteSelected = self.model.retrieveTodaysQuote(index)
            self.displayViewController.quoteDataToDisplay = quoteSelected
//        println("Debugger: ContainerVC passingTodaysQuote(): checking if the quote is a favorite")
        
        checkIfFavorite(quoteSelected.quoteID)
        updateBackgroundImage()
    }
    
    
    func showSelectedQuote(index: Int, listOrigin: String) {
//        println("Debugger: ContainerVC: showSelectedQuote() called by the MenuVC table")
        var quoteSelected = QuoteData()
        var quoteId = String()
        if listOrigin == "All" {
            quoteSelected = self.model.quoteAtIndex(index)
            quoteId = quoteSelected.quoteID
        } else {
            quoteSelected = self.favQuotesData[index]
            quoteId = quoteSelected.quoteID
//            println("Debugger: ContainerVC showSelectedQuote() favQuotesData is \(self.favQuotesData.count) long")
        }
        self.displayViewController.quoteDataToDisplay = quoteSelected
//        println("Debugger: ContainerVC showSelectedQuote(): check if quote is favorite or not")
        
        checkIfFavorite(quoteId)
        toggleMenu()
        updateBackgroundImage()
    }
    
    func checkIfFavorite(quoteIdToCheck: String)->Bool{
        var resultOfCheck = false
       
        //Dave - adding the CoreData version 
        if let context = self.appDelegate.managedObjectContext {
            let fetchRequestForFavorites = NSFetchRequest(entityName: "Favorite")
            let filter = NSPredicate(format: "idOfQuote == %@", quoteIdToCheck)
            fetchRequestForFavorites.predicate = filter
            
            if let listOfReturnedFavorites: [Favorite] = context.executeFetchRequest(fetchRequestForFavorites, error: nil) as? [Favorite] {
                //println("At viewDidLoad, the current number of CoreData favs is :\(listOfReturnedFavorites.count)")
                
                if listOfReturnedFavorites.count > 0 {
                    for favorite in listOfReturnedFavorites{
                        resultOfCheck = true
//                        println("Debugger: The selected quote is currently a favorite")
                        self.displayViewController.isFavorite = true
                        self.displayViewController.bookmarkButton.setImage(displayViewController.bookmarkFillImage, forState: .Normal)
                    }
                } else {
                    resultOfCheck = false
//                    println("Debugger: The selected quote is NOT a favorite.")
                    self.displayViewController.isFavorite = false
                    self.displayViewController.bookmarkButton.setImage(displayViewController.bookmarkPlainImage, forState: .Normal)
                }
            }
        }
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
        
        displayViewController?.backgroundImage.image = UIImage(named: randomImageName)
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
