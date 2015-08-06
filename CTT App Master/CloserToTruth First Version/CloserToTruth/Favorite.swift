//
//  Favorite.swift
//  CloserToTruth
//
//  Created by Alexis Saint-Jean on 4/21/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import Foundation
import CoreData

@objc(Favorite)

class Favorite: NSManagedObject {
    
    @NSManaged var quote_id: String
    @NSManaged var quote_text: String
    @NSManaged var term_name: String
    @NSManaged var drupal_interview_url: String
    @NSManaged var contributor_name: String
    @NSManaged var contributor_id: String
    
    class func createNewFavoriteEntry(context: NSManagedObjectContext, quote_id: String, quote_text: String, term_name: String, drupal_interview_url: String, contributor_id: String, contributor_name: String) -> Favorite {
        
        var newFavorite = NSEntityDescription.insertNewObjectForEntityForName("Favorite", inManagedObjectContext: context) as! Favorite
        
        newFavorite.quote_id = quote_id
        newFavorite.quote_text = quote_text
        newFavorite.term_name = term_name
        newFavorite.drupal_interview_url = drupal_interview_url
        newFavorite.contributor_id = contributor_id
        newFavorite.contributor_name = contributor_name
        
        return newFavorite
    }
}
