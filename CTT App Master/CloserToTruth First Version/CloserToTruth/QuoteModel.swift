//
//  QuoteModel.swift
//  CloserToTruth
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
    
    var delegate: ShowingQuote?
    
    //ALEXIS: The following variables are to store values for quotes pulled from JSON API
    var jsonTodaysQuote: NSArray?
    var json: NSArray?
    var midtempData:[String] = []
    
    
    init() {
        
        // ALEXIS: creating a default quote for the todaysQuote array. This is the quote that will show on screen if no internet connection was etablished at launch
        var todaysQuoteDefault = QuoteData(quoteText: "A connection with the Closer To Truth website could not be established. Either your phone doesn't have access to the Internet, or Closer To Truth servers are unavailable. Please try again later.", authorName: "", termName: "Couldn't Connect", contributorID: "", drupalInterviewURL: "", quoteID: "")
        
        self.todaysQuote.append(todaysQuoteDefault)
        
        //ALEXIS: working on loading JSON for today's quote
        if let url = NSURL(string: "http://www.closertotruth.com/api/todays-quote") {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if let jsonArray: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) {
                    self.jsonTodaysQuote = jsonArray as? NSArray
                    // Create a quote struct with Today's data, then append that struct to todaysQuote array
                    var quoteOne = QuoteData()
                    quoteOne.quoteID = self.jsonTodaysQuote![0]["quote_id"] as! String
                    quoteOne.authorName = self.jsonTodaysQuote![0]["contributor_name"] as! String
                    quoteOne.contributorID = self.jsonTodaysQuote![0]["contributor_id"] as! String
                    quoteOne.termName = self.jsonTodaysQuote![0]["term_name"] as! String
                    var cleanText = self.jsonTodaysQuote![0]["quote_text"] as! String
                    quoteOne.quoteText = cleanText.stringByReplacingOccurrencesOfString("&#039;", withString: "'", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    quoteOne.drupalInterviewURL = self.jsonTodaysQuote![0]["drupal_interview_url"] as! String
                    self.todaysQuote.insert(quoteOne, atIndex: 0)                    
//                    println("Today's quote elements are now: \(self.todaysQuote[0].drupalInterviewURL) and \(self.todaysQuote[0].contributorID)")
                }
                else {
                    println("QuoteModel: couldn't create jsonArray, which means there was no Internet connection. The no-connection text will show instead of a quote")
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in                    
                    // ACTIONS TO TAKE ONCE THE DATA IS LOADED. NOTHING DONE NOW
                    println("QuoteModel: dispatch_async() loading today's Quote")
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
                    println("QuoteModel: json in viewDidLoad(). json count is now \(self.json!.count)")
                    
                    // Append all the text of quotes to the midtempData array, so that we can show these quotes
                    // in the MenuViewController's table
                    if let jsonData = self.json {
                        println("QuoteModel: json in viewDidLoad(). jsonData exists")
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
                            

                            // ALEXIS: append the newly created quote struct to the quotes array
                            self.quotes.append(quoteOne)
                            
                        }
                        println("QuoteModel: json in viewDidLoad(). midtempData count is now \(self.quotes.count)")
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
        
        
        // Creating dummy data. This is where the JSON code should live.
        // Essentially, the code should parse the JSON data, find all the quote data (name, text, author, url, etc) and create discrete structs of QuoteData for each set of data. We then append each struct to the array above named 'quotes.' All we need to do is have a have to iterate through all the structs created from the JSON data and add each one to the array. The dummy data is easy to add because we know we only have two structs, but in reality we may not know how many structs will be created.
        
        
        
    }
    
    func quoteAtIndex(index:Int) -> QuoteData {
        return self.quotes[index]
    }
    
    func retrieveTodaysQuote(index: Int) -> QuoteData {
        return self.todaysQuote[0]
    }

}
