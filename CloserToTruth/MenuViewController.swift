//
//  MenuViewController.swift
//  CloserToTruth CLEAN + CoreData Version
//
//  Created by Dave Scherler on 4/15/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import UIKit

protocol PassingQuote {
    func showSelectedQuote(index: Int, listOrigin: String)
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DisplayViewControllerDelegate {
    
    // ALEXIS: variables to work on showing the right table
    var favListSelected: Bool?
    var tableSelected: String?
    var favQuotesData = [QuoteData]()
    var arrayToUseForTable = [QuoteData]()
    var hiddenTable = false
    

    @IBOutlet weak var logoCTT: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var filterStatus: UISegmentedControl!
    @IBAction func filterQuotes(sender: UISegmentedControl) {
        
        switch filterStatus.selectedSegmentIndex {
        case 0:
//            println("Debugger: MenuVC case 0")
            self.tableSelected = "allQuotes"
            self.arrayToUseForTable = quotesText
            self.table.reloadData()
        case 1:
//            println("Debugger: MenuVC case 1")
            self.tableSelected = "favQuotes"
            self.arrayToUseForTable = favQuotesData
            self.table.reloadData()
        default:
//            println("Debugger: MenuVC default")
            self.tableSelected = "allQuotes"
            self.arrayToUseForTable = quotesText
            self.table.reloadData()
        }
    }
    @IBAction func showAppInfo(sender: AnyObject) {
        if self.hiddenTable == false {
            self.table.hidden = true
            self.filterStatus.hidden = true
            self.logoCTT.hidden = false
            self.hiddenTable = true
        } else {
            self.table.hidden = false
            self.filterStatus.hidden = false
            self.logoCTT.hidden = true
            self.hiddenTable = false
        }
        
    }
    
    func filter(filter: String) {
        if filter == "favQuotes" {
//            self.table = self.favQuotesData
//            println("MenuViewVC: filter() called for favQuotes. Number of favQuotes is \(self.favQuotesData.count)")
        } else {
//            self.table = self.quotesText
//            println("MenuViewVC: filter() called for allQuotes. Number of allQuotes is \(self.allQuotesData.count)")
        }
    }
    
    
    
    var delegate: PassingQuote?
    var quotesText: [QuoteData] = [] {
        didSet {
            self.table?.reloadData()
        } }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        // ALEXIS: Creating a few quoteData to have fav list to work with
//        println("MenuViewVC: viewDidLoad()")
//        var favQuote1 = QuoteData()
//        favQuote1.quoteText = "Fav 1"
//        favQuote1.authorName = "Me"
//        favQuote1.termName = "other"
//        favQuote1.contributorID = "3"
//        favQuote1.drupalInterviewURL = "www.google.com"
//        favQuote1.quoteID = "1"
//        
//        self.favQuotesData.append(favQuote1)
//        
//        var favQuote2 = QuoteData()
//        favQuote2.quoteText = "Fav 2"
//        favQuote2.authorName = "Dave"
//        favQuote2.termName = "New"
//        favQuote2.contributorID = "2"
//        favQuote2.drupalInterviewURL = "www.yahoo.com"
//        favQuote2.quoteID = "20"
//        
//        self.favQuotesData.append(favQuote2)
//        println("MenuViewVC: favQuotesData has now \(self.favQuotesData.count) quotes")
        
        self.arrayToUseForTable = quotesText
        
        self.table.reloadData()
        self.logoCTT.hidden = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayToUseForTable.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
        var cell = tableView.dequeueReusableCellWithIdentifier("quoteCell") as! UITableViewCell!
        if cell == nil  {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "quoteCell")
        }
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = arrayToUseForTable[indexPath.row].quoteText
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        println("Debugger: MenuViewVC: The selected row is \(indexPath.row)")
        var stringToPass: String?
        if self.tableSelected == "favQuotes" {
            stringToPass = "Favorites"
        } else {
            stringToPass = "All"
        }
        
        self.delegate?.showSelectedQuote(indexPath.row, listOrigin: stringToPass!)
//        self.delegate?.didSelectQuoteAtIndex(indexPath.row)
    }

}
