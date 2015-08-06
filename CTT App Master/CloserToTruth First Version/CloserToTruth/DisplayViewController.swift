//
//  DisplayViewController.swift
//  CloserToTruth
//
//  Created by Dave Scherler on 4/15/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import UIKit
//import CoreData


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
    var authorInfo: String?
    var idOfQuote: String?
    
    var isFavorite: Bool?
    
    
    //variable for nav bar icons
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 85, height: 30))
    let logo = UIImage(named: "CTT Logo White.png")
    let hamburgerButton = UIImage(named: "white hamburger.png")
//    let bookmarkButton = UIImage(named: "white bookmark.png")
    let bookmarkPlainImage = UIImage(named: "white bookmark.png")
    let bookmarkFillImage = UIImage(named: "bookmark Fill White.png")
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Now loading the data from the Favorites plist
        // bookmarksPath is a string that is the path to the Favorites.plist file
        var bookmarksPath = NSBundle.mainBundle().pathForResource("Favorites", ofType: "plist")
        var bookmarks = NSMutableArray(contentsOfFile: bookmarksPath!)
        if bookmarks!.count > 0 {
            println("DisplayVC: viewDidLoad() number of objects stored in plist is > 0 at \(bookmarks!.count)")
        } else {
            println("DisplayVC: viewDidLoad() number of objects stored in plist is: \(bookmarks!.count)")
        }
        

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
        println("video button pressed!")
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoVC = storyboard.instantiateViewControllerWithIdentifier("VideoVC") as! VideoViewController
        videoVC.urlstring = self.interviewLink
        self.presentViewController(videoVC, animated: true, completion: nil)
    }
    
    
//    @IBAction func bookmarkPressed(sender: UIBarButtonItem) {
//        println("bookmark pressed")
//        
//        
//    }
    // Dave to Alexis - this where your old addToFavorites code should go. This should create/remove the favorite record based on the pressed. I've added this function as the bookmarkButtons "selector" on line 123. So it should run this code everytime it's clicked. 
    func bookmarkButtonPressed() {
        println("bookmark button pressed!")
        
        var quoteDict = ["quote_id": self.idOfQuote, "quote_text": self.quoteText.text, "term_name": self.termName.text, "drupal_interview_url": self.interviewLink, "contributor_name": self.authorName.text,  "contributor_id": self.authorInfo]
        
        // Creating an array of quote IDs that we will use for reference
        var favQuotesIdArray:[String] = []
        
        // Creating a mutable array that stores all the favorite quotes
        var bookmarksPath = NSBundle.mainBundle().pathForResource("Favorites", ofType: "plist")
        var bookmarks = NSMutableArray(contentsOfFile: bookmarksPath!)
        
//        println("number of objects stored in plist is: \(bookmarks!.count)")
        
        // Populating favQuotesIdArray with the IDs of the saved quotes in the Favorites.plist
        if bookmarks!.count > 0 {
            for i in bookmarks! {
                favQuotesIdArray.append(i["quote_id"] as! NSString as String)
            }
            println("bookmarks IDs are now: \(favQuotesIdArray)")
        }
        
        if self.isFavorite == true {
            self.isFavorite = false
            self.bookmarkButton.setImage(self.bookmarkPlainImage, forState: .Normal)
            println("isFavorite is now \(self.isFavorite)")
            
            for i in 0..<favQuotesIdArray.count {
                if favQuotesIdArray[i] == quoteDict["quote_id"]! {
                    println("found the id at position \(i)")
                    // We need to remove reference to the quote in the variables that holds information about favorites
//                    self.favQuotesArray.removeAtIndex(i)
//                    self.favQuotesIdArray.removeAtIndex(i)
                    bookmarks!.removeObjectAtIndex(i)
                    bookmarks?.writeToFile(bookmarksPath!, atomically: true)
//                    self.menu?.favQuotesData = self.favQuotesArray
                    break
                }
            }
        } else {
            self.isFavorite = true
            self.bookmarkButton.setImage(self.bookmarkFillImage, forState: .Normal)
            println("isFavorite is now \(self.isFavorite)")
//            println("Trying to save quote info to plist")
            
            // Now we will store the quoteDict dictionary just created into our Favorites plist
            bookmarks!.insertObject(quoteDict, atIndex: 0)
            bookmarks?.writeToFile(bookmarksPath!, atomically: true)
            println("number of objects stored in plist is: \(bookmarks!.count)")
        }
        delegate?.refreshFavoritesList!()
        println("End of button pressed")
    }
    
    //this is what actually slides the menuViewContoller in, the displayViewController out. 
    func toggleMenuButton() {
        println("menu button pressed!")
        delegate?.toggleMenu!()
    }
    //this updates the labels on the displayViewController
    func updateQuoteData() {
        self.authorName.text = self.quoteDataToDisplay?.authorName
        self.termName.text = self.quoteDataToDisplay?.termName
        self.quoteText.text = self.quoteDataToDisplay?.quoteText
        self.authorInfo = self.quoteDataToDisplay?.contributorID
        self.interviewLink = self.quoteDataToDisplay?.drupalInterviewURL
        self.idOfQuote = self.quoteDataToDisplay?.quoteID
        
//        println("DisplayVC: See if quote's info updates correctly: authorInfo is \(self.authorInfo) and interviewURL is \(self.interviewLink) and idOfQuote is \(self.idOfQuote)")
    }
    
    func makeNavigationBarButtons() {
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        
        //make logo
        self.imageView.image = self.logo
        self.imageView.contentMode = .ScaleAspectFit
        navigationItem.titleView = self.imageView
        
        //make menu button
        let hamburgerButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        hamburgerButton.frame = CGRectMake(0, 0, 20, 15)
        hamburgerButton.setImage(self.hamburgerButton, forState: .Normal)
        hamburgerButton.addTarget(self, action: "toggleMenuButton", forControlEvents: .TouchUpInside)
        
        var leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        //make bookmarkbutton
        self.bookmarkButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        self.bookmarkButton.frame = CGRectMake(0, 0, 10, 20)
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
