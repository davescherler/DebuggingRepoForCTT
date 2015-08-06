//
//  DisplayViewController.swift
//  CloserToTruth CLEAN + CoreData Version
//
//  Created by Dave Scherler on 4/15/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import UIKit
import CoreData


@objc
protocol DisplayViewControllerDelegate {
    optional func toggleMenu()
    optional func refreshFavoritesList()
}

class DisplayViewController: UIViewController {

    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var termName: UILabel!
    @IBOutlet weak var quoteText: UITextView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    // ALEXIS: variables to store the values of the quote that do not get displayed on screen but are needed
    var interviewLink: String?
    var interviewVideo: String?
    var authorInfo: String?
    var idOfQuote: String?
    var termID: String?
    var featureDate: String?
    
    var isFavorite: Bool?
    
    
    //variable for nav bar icons
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 85, height: 30))
    let logo = UIImage(named: "CTT Logo White.png")
    let hamburgerButton = UIImage(named: "glyphicons-517-menu-hamburger.png")
//    let bookmarkButton = UIImage(named: "white bookmark.png")
    let bookmarkPlainImage = UIImage(named: "glyphicons-20-heart-empty.png")
    let bookmarkFillImage = UIImage(named: "glyphicons-20-heart-filled.png")
    var bookmarkButton = UIButton()
//    var bookmarkButtonSelected: Bool = false
    
    //delegate for talking to the ContainerVC
    var delegate: DisplayViewControllerDelegate?
    
    //this uses the didSet modifier to call the updateQuoteData as soon as it's set
    var quoteDataToDisplay: QuoteData? {
        didSet {
            self.updateQuoteData()
        }
    }
    
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationBarButtons()
        
    }
    
    @IBAction func authorInfoButtonPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let authorInfoVC = storyboard.instantiateViewControllerWithIdentifier("AuthorInfoVC") as! AuthorInfoViewController
        // ALEXIS: Now we're passing to the 'authorInfoVC' AuthorViewController the author ID so that it knows what info to display
        authorInfoVC.contributorID = self.authorInfo!
        if let passingName = self.authorName.text {
            authorInfoVC.textForAuthorName = passingName
        }
        self.presentViewController(authorInfoVC, animated: true, completion: nil)
    }

    
    @IBAction func videoButtonPressed(sender: UIButton) {
//        println("Debugger: video button pressed!")
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoVC = storyboard.instantiateViewControllerWithIdentifier("VideoVC") as! VideoViewController
//        videoVC.urlstring = self.interviewLink
        videoVC.kalturaVideoID = self.interviewVideo
        self.presentViewController(videoVC, animated: true, completion: nil)
    }
    
    func saveToCoreData() {
        if let context = appDelegate.managedObjectContext {
            Favorite.createNewFavoriteEntry(context, idOfQuote: self.idOfQuote!, quote_text: self.quoteText.text!, term_name: self.termName.text!, drupal_interview_url: self.interviewLink!, contributor_id: self.authorInfo!, contributor_name: self.authorName.text!, video_id: self.interviewVideo!)
            
            appDelegate.saveContext()
//            println("Debugger: saved data to Core Data!")
            
            let fetchRequestForFavorites = NSFetchRequest(entityName: "Favorite")
            
            if let listOfReturnedFavorites: [Favorite] = context.executeFetchRequest(fetchRequestForFavorites, error: nil) as? [Favorite] {
                for favorites in listOfReturnedFavorites {
//                    println("Debugger: The number of CoreData favorites is :\(listOfReturnedFavorites.count)")
                }
            }
        }
    }
    
    func deleteFavoriteFromCoreData() {
        if let context = self.appDelegate.managedObjectContext {
            
            let fetchRequestForFavorites = NSFetchRequest(entityName: "Favorite")
            
            //apply a filter to the fetch request, filter will look for favs matching the idOfQuote
            let filter = NSPredicate(format: "idOfQuote == %@", self.idOfQuote!)
            
            fetchRequestForFavorites.predicate = filter
            
            var error = NSError?()
            
            if let fetchResults: [Favorite] = context.executeFetchRequest(fetchRequestForFavorites, error: nil) as? [Favorite] {

                for result in fetchResults {
                    //we can just delete 'result' because since we're filtering by the quote_id, which is completely unique, the filter will always return exactly one result. Which is the one we delete.
                    appDelegate.managedObjectContext?.deleteObject(result)
//                    println("Debugger: User just deleted: \(appDelegate.managedObjectContext?.deletedObjects)")
                    appDelegate.saveContext()
                }
            } else {
//                println("Debugger: no more favorites?")
            }
        }
    }

    func bookmarkButtonPressed() {
//        println("Debugger: bookmark button pressed!")
        
        if self.isFavorite == true {
            self.isFavorite = false
            self.bookmarkButton.setImage(self.bookmarkPlainImage, forState: .Normal)
            deleteFavoriteFromCoreData()
            //delegate?.refreshFavoritesList!()
//            println("Debugger: isFavorite is now \(self.isFavorite)")
            
        } else {
            self.isFavorite = true
            self.bookmarkButton.setImage(self.bookmarkFillImage, forState: .Normal)
            saveToCoreData()
            //delegate?.refreshFavoritesList!()
//            println("Debugger: isFavorite is now \(self.isFavorite)")
        }
        delegate?.refreshFavoritesList!()
//        println("Debugger: End of button pressed")
    }
    
    //this is what actually slides the menuViewContoller in, the displayViewController out. 
    func toggleMenuButton() {
//        println("Debugger: menu button pressed!")
        delegate?.toggleMenu!()
    }
    //this updates the labels on the displayViewController
    func updateQuoteData() {
        self.authorName.text = self.quoteDataToDisplay?.authorName
        self.termName.text = self.quoteDataToDisplay?.termName
        self.termID = self.quoteDataToDisplay?.termID
        self.quoteText.text = self.quoteDataToDisplay?.quoteText
        self.authorInfo = self.quoteDataToDisplay?.contributorID
        self.interviewLink = self.quoteDataToDisplay?.drupalInterviewURL
        self.interviewVideo = self.quoteDataToDisplay?.kalturaVideoID
        self.idOfQuote = self.quoteDataToDisplay?.quoteID
        self.featureDate = self.quoteDataToDisplay?.featureDate
    }
    
    func makeNavigationBarButtons() {
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.translucent = false
        
        
        //make logo
        self.imageView.image = self.logo
        self.imageView.contentMode = .ScaleAspectFit
        navigationItem.titleView = self.imageView
        
        //make menu button
        let hamburgerButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        hamburgerButton.frame = CGRectMake(0, 0, 20, 20)
        hamburgerButton.setImage(self.hamburgerButton, forState: .Normal)
        hamburgerButton.addTarget(self, action: "toggleMenuButton", forControlEvents: .TouchUpInside)
        
        var leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        //make bookmarkbutton
        self.bookmarkButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        self.bookmarkButton.frame = CGRectMake(0, 0, 20, 20)
        self.bookmarkButton.setImage(self.bookmarkPlainImage, forState: .Normal)
        self.bookmarkButton.addTarget(self, action: "bookmarkButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        var rightBarButtonItem = UIBarButtonItem(customView: self.bookmarkButton)
        navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
