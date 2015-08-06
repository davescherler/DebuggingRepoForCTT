//
//  VideoViewController.swift
//  CloserToTruth CLEAN + CoreData Version
//
//  Created by Dave Scherler on 4/17/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController, UIWebViewDelegate {
    
    var isPresented: Bool?
//    var urlstring: String?
    var kalturaVideoID: String?
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    let closeButtonIcon = UIImage(named: "glyphicons-193-circle-remove.png")
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet weak var loadingVideoIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoView.delegate = self
        self.isPresented = true
        
        //allow audio to play when device is in silent mode.
        var audioError: NSError?
        var audioControl = AVAudioSession.sharedInstance().setCategory(
            AVAudioSessionCategoryPlayback,
            withOptions: AVAudioSessionCategoryOptions.DuckOthers,
            error: &audioError)
        
        if !audioControl {
//            println("Debugger: Failed to set audio session category.  Error: \(audioError)")
        }
        
        // ALEXIS: the videoWidth and videoHeight variables are use to dynamically set the height and width of the different HTML elements so that the video contained within the UIWebView actually fits it (at least for now in the portrait mode)
        var videoWidth = String(Int(self.view.bounds.width - 60))
        var videoHeight = String(Int((self.view.bounds.width - 60) / 4 * 3))
        
        // ALEXIS: myHTML is a variable that will hold the code to use to display a video in the webView
        var myHTML = ""
        
        
        if let kalturaVidID = self.kalturaVideoID {
        
        // ALEXIS: The HTML code below is the code used by the webView to display a video. There are 3 dynamics variables
        // that are inserted in the code: videoWidth and videoHeight (to ensure the HTML player fits within the webView)
        // and kalturaVidID, which is a string that stores the ID of the video to watch
        
        var myHTML1 = "<div id='kaltura_player_1430180256' style='width: " +  videoWidth + "px; height: " + videoHeight + "px;' itemprop='video' itemscope itemtype='http://schema.org/VideoObject'> <span itemprop='name' content='quote-app'></span> <span itemprop='description' content=''></span> <span itemprop='duration' content=''></span> <span itemprop='thumbnail' content='http://cdnbakmi.kaltura.com/p/1529571/sp/152957100/thumbnail/entry_id/" + kalturaVidID + "/version/100000/acv/152'></span> <span itemprop='width' content='"
        var myHMTL2 = videoWidth + "'></span> <span itemprop='height' content='" + videoHeight + "'></span> </div> <script src='http://cdnapi.kaltura.com/p/1529571/sp/152957100/embedIframeJs/uiconf_id/29372971/partner_id/1529571?autoembed=true&entry_id=" + kalturaVidID + "&playerId=kaltura_player_1430180256&cache_st=1430180256&width=" + videoWidth +  "&height=" + videoHeight + "'></script>"
        
        myHTML = myHTML1 + myHMTL2
            
        }
        
        self.videoView.loadHTMLString(myHTML, baseURL: nil)
        
        var sizeOfWidth = self.view.bounds.width
        
//        println("Debugger: the current width of the screen is: \(sizeOfWidth)")
//        println("Debugger: the current width of the video is: \(videoWidth)")
//        println("Debugger: the current height of the video is: \(videoHeight)")
        

        makeNavigationBarCloseButton()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
//        println("Debugger: the video has finished loading")
        self.loadingVideoIndicator.stopAnimating()
        self.loadingVideoIndicator.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func makeNavigationBarCloseButton() {
        self.closeButton.image = closeButtonIcon
        self.closeButton.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.isPresented = false
        dismissViewControllerAnimated(true, completion: nil)
    }
}
