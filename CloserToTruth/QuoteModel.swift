//
//  QuoteModel.swift
//  CloserToTruth CLEAN + CoreData Version
//
//  Created by Dave Scherler on 4/15/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import Foundation

protocol ShowingQuote {
    func passingTodaysQuote(index: Int)
}


class QuoteModel {
    var quotes = [QuoteData]()
    var todaysQuote = [QuoteData]()
    var taxonomyList = [TaxonomyData]()
    
    var delegate: ShowingQuote?
    
    //ALEXIS: The following variables are to store values for quotes pulled from JSON API
    var jsonTodaysQuote: NSArray?
    var json: NSArray?
    var taxonomies: NSArray?
    var midtempData:[String] = []
    
    
    init() {
        
        // ALEXIS: creating a default quote for the todaysQuote array. This is the quote that will show on screen if no internet connection was etablished at launch
        var todaysQuoteDefault = QuoteData(quoteText: "A connection with the Closer To Truth website could not be established. Either your phone doesn't have access to the Internet, or Closer To Truth servers are unavailable. Please try again later.", authorName: "", termName: "Couldn't Connect", termID: "", contributorID: "", drupalInterviewURL: "", quoteID: "", kalturaVideoID: "", featureDate: "")
        
        self.todaysQuote.append(todaysQuoteDefault)
        
        //ALEXIS: working on loading JSON for today's quote
        if let url = NSURL(string: "http://www.closertotruth.com/api/todays-quote") {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if let jsonArray: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) {
                    self.jsonTodaysQuote = jsonArray as? NSArray
                    // Create a quote struct with Today's data, then append that struct to todaysQuote array
                    var quoteOne = QuoteData()
                    quoteOne.quoteID = self.jsonTodaysQuote![0]["quote_id"] as! String
                    
//                    quoteOne.quoteID = self.jsonTodaysQuote![0]["quote_id"] as! String
                    quoteOne.authorName = self.jsonTodaysQuote![0]["contributor_name"] as! String
                    quoteOne.contributorID = self.jsonTodaysQuote![0]["contributor_id"] as! String
                    quoteOne.termName = self.jsonTodaysQuote![0]["term_name"] as! String
                    quoteOne.termID = self.jsonTodaysQuote![0]["term_id"] as! String
                    var cleanText = self.jsonTodaysQuote![0]["quote_text"] as! String
                    quoteOne.quoteText = cleanText.stringByReplacingOccurrencesOfString("&#039;", withString: "'", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    quoteOne.drupalInterviewURL = self.jsonTodaysQuote![0]["drupal_interview_url"] as! String
                    quoteOne.kalturaVideoID = self.jsonTodaysQuote![0]["kaltura_asset_id"] as! String
                    quoteOne.featureDate = self.jsonTodaysQuote![0]["feature_date"] as! String
                    self.todaysQuote.insert(quoteOne, atIndex: 0)
                    
//                    println("Today's quote elements are now: \(self.todaysQuote[0].drupalInterviewURL) and \(self.todaysQuote[0].contributorID)")
                }
                else {
                    println("QuoteModel: couldn't create jsonArray, which means there was no Internet connection. The no-connection text will show instead of a quote")
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in                    
                    // ACTIONS TO TAKE ONCE THE DATA IS LOADED. NOTHING DONE NOW
//                    println("Debugger: QuoteModel: dispatch_async() loading today's Quote")
                    self.delegate?.passingTodaysQuote(0)
                    
                })
            })
            task.resume()
        }
        
        // working on loading JSON for all quotes
        // JSON Trial file https://raw.githubusercontent.com/ASJ3/PlayersGame/master/API_JSON/all-quotes-changed.json
        if let url = NSURL(string: "http://www.closertotruth.com/api/all-quotes") {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if let jsonArray: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) {
                    self.json = jsonArray as? NSArray
//                    println("Debugger: QuoteModel: json in viewDidLoad(). json count is now \(self.json!.count)")
                    
                    // Append all the text of quotes to the midtempData array, so that we can show these quotes
                    // in the MenuViewController's table
                    if let jsonData = self.json {
//                        println("Debugger: QuoteModel: json in viewDidLoad(). jsonData exists")
                        for i in jsonData {
                            //ALEXIS: create a default quote struct that will be populated by the JSON data
                            var quoteOne = QuoteData()
                            
                            if let quote = i["quote_text"] as? NSString {
                                var cleanText = quote as String
                                quoteOne.quoteText = cleanText.stringByReplacingOccurrencesOfString("&#039;", withString: "'", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            }
                            if let quoteUniqueID = i["quote_id"] as? NSString {
                                quoteOne.quoteID = quoteUniqueID as String
                            }
                            if let quoteAuthor = i["contributor_name"] as? NSString {
                                quoteOne.authorName = quoteAuthor as String
                            }
                            if let authorID = i["contributor_id"] as? NSString {
                                quoteOne.contributorID = authorID as String
                            }
                            if let quoteTerm = i["term_name"] as? NSString {
                                quoteOne.termName = quoteTerm as String
                            }
                            if let inteverviewLink = i["drupal_interview_url"] as? NSString {
                                quoteOne.drupalInterviewURL = inteverviewLink as String
                            }
                            if let inteverviewVideo = i["kaltura_asset_id"] as? NSString {
                                quoteOne.kalturaVideoID = inteverviewVideo as String
                            }
                            
                            if let quoteTermID = i["term_id"] as? NSString {
                                quoteOne.termID = quoteTermID as String
                            }
                            if let quoteFeatureDate = i["feature_date"] as? NSString {
                                quoteOne.featureDate = quoteFeatureDate as String
                            }
                            

                            // ALEXIS: append the newly created quote struct to the quotes array
                            self.quotes.append(quoteOne)
                            
                        }
//                        println("Debugger: QuoteModel: json in viewDidLoad(). midtempData count is now \(self.quotes.count)")
                        // ALEXIS: need to load the quote into the menu
                        //                        self.menu!.allQuotesData = self.midtempData
                        //                        var menuVCArray = self.menu!.allQuotesData
                        //                        println("MainViewVC: json in viewDidLoad(). The number of quotes in MenuViewVC's allQuotes is \(menuVCArray.count)")
                        //                        self.menu!.re_filter()
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    
                    // IMPORTANT we need to reload the data we got into our table view
                    //                    self.menu!.table.reloadData()
                })
            })
            task.resume()
        }
        
        //ALEXIS: working on loading JSON to the quote taxonomy (i.e. the terms used in the quote title label)
        if let url = NSURL(string: "http://www.closertotruth.com/api/topics") {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if let jsonArray: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) {
                    self.taxonomies = jsonArray as? NSArray
//                    println("Debugger: QuoteModel: json for taxonomy in viewDidLoad(). json count is now \(self.taxonomies!.count)")
                    
                    // Append all the text of quotes to the taxonomies array
                    if let jsonData = self.taxonomies {
//                        println("Debugger: QuoteModel: json in viewDidLoad(). jsonData exists")
                        for i in jsonData {
                            //ALEXIS: create a default quote struct that will be populated by the JSON data
                            var taxonomyOne = TaxonomyData()
                            
                            if let taxonomyTermID = i["term_id"] as? NSString {
                                taxonomyOne.termID = taxonomyTermID as String
                            }
                            if let taxonomyTermName = i["term_name"] as? NSString {
                                taxonomyOne.termName = taxonomyTermName as String
                            }
                            if let taxonomyParentTermID = i["parent_term_id"] as? NSString {
                                taxonomyOne.parentTermID = taxonomyParentTermID as String
                            }
                            if let taxonomyTermOrder = i["term_order"] as? NSString {
                                taxonomyOne.termOrder = taxonomyTermOrder as String
                            }
                            
                            
                            // ALEXIS: append the newly created quote struct to the quotes array
                            self.taxonomyList.append(taxonomyOne)
                            
                        }
//                        println("Debugger: QuoteModel: json in viewDidLoad(). taxonomy count is now \(self.taxonomyList.count)")
                        
//                        //Loop through taxonomyList to print the term names
//                        for i in 0..<self.taxonomyList.count {
//                        println("QuoteModel: \(self.taxonomyList[i].termName)")
//                        }
                        
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    
                    // IMPORTANT we need to reload the data we got into our table view
                    //                    self.menu!.table.reloadData()
                })
            })
            task.resume()
        }
        
        
        // Creating dummy data. This is where the JSON code should live.
        // Essentially, the code should parse the JSON data, find all the quote data (name, text, author, url, etc) and create discrete structs of QuoteData for each set of data. We then append each struct to the array above named 'quotes.' All we need to do is have a have to iterate through all the structs created from the JSON data and add each one to the array. The dummy data is easy to add because we know we only have two structs, but in reality we may not know how many structs will be created.
        
        
        
    }
    
    func quoteAtIndex(index:Int) -> QuoteData {
        fixTermNameInQuote(self.quotes[index])
//        return self.quotes[index]
        return fixTermNameInQuote(self.quotes[index])
    }
    
    func retrieveTodaysQuote(index: Int) -> QuoteData {
        fixTermNameInQuote(self.todaysQuote[0])
//        return self.todaysQuote[0]
        return fixTermNameInQuote(self.todaysQuote[0])
    }
    
    //The following function is to fix the term names given by the JSON. Sometimes the term name field includes redundant words (e.g. "Cosmos, Cosmos") which looks bad when we show the quote. 
    //There is a term ID field we can reference when using TaxonomyList to find the words used in the term Name field.
    func fixTermNameInQuote(quoteToUpdate: QuoteData) -> QuoteData {
        var tempQuote = quoteToUpdate

        //Get the term IDs (numbers) that describe the term name; clean them up and append them to an array called finalArray
        if let termIDString = quoteToUpdate.termID as String! {
            var tempIDArray = termIDString.componentsSeparatedByString(",")
            var finalIDArray = [String]()
            for i in 0..<tempIDArray.count {
                var cleanTermID = tempIDArray[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                finalIDArray.append(cleanTermID)
            }
//            println("Debugger: QuoteModel: finalIDArray is \(finalIDArray)")
        //Use the IDs in finalIDArray to find the right term names in taxonomyList, then add those term names to tempTermNameArray
            var tempTermNameArray = [String]()
            for i in finalIDArray {
                for j in taxonomyList {
                    if j.termID == i {
                        tempTermNameArray.append(j.termName)
                        break
                    }
                }
            }
//            println("Debugger: QuoteModel: tempTermNameArray is \(tempTermNameArray)")
            var finalTermNameArray = [String]()
            if tempTermNameArray.count > 0 {
                finalTermNameArray.append(tempTermNameArray[0])
                
                for i in 1..<tempTermNameArray.count {
                    var termNameAlreadyThere = false
                    for j in finalTermNameArray {
                        if tempTermNameArray[i] == j {
                            termNameAlreadyThere = true
                        }
                    }
                    if termNameAlreadyThere == false {
                        finalTermNameArray.append(tempTermNameArray[i])
                    }
                }
            }
            
            //If tempTermNameArray.count is > 0 then we succeeded in creating a cleaned up array of non-redundant term names, which we can then use in the quote to return
            if finalTermNameArray.count > 0 {
//                println("Debugger: Final term name array is now used to fix the quote")
                tempQuote.termName = ", ".join(finalTermNameArray)
            }
        }
        
//        println("Debugger: tempQuote term name is \(tempQuote.termName)")
        return tempQuote
    }

}
