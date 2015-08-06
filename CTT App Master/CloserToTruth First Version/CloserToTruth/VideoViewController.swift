//
//  VideoViewController.swift
//  CloserToTruth
//
//  Created by Dave Scherler on 4/17/15.
//  Copyright (c) 2015 DaveScherler. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController, UIWebViewDelegate {
    
    var isPresented: Bool?
    var urlstring: String?
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    let closeButtonIcon = UIImage(named: "Close Button White 4042.png")
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet weak var loadingVideoIndicator: UIActivityIndicatorView!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoView.delegate = self
        self.isPresented = true
        
        // ALEXIS: HTML code below provided by Tomer to try to see if we could use it in the webView
        //        var myHTML: String?
        //        myHTML = "<div id='kaltura_player_1429574249' style='width: 120px; height: 99px;' itemprop='video' itemscope itemtype='http://schema.org/VideoObject'><span itemprop='name' content='ChaDa-014'></span><span itemprop='description' content=''></span><span itemprop='duration' content='525'></span><span itemprop='thumbnail' content='http://cdnbakmi.kaltura.com/p/1529571/sp/152957100/thumbnail/entry_id/0_qnqhojel/version/100000/acv/152'></span><span itemprop='width' content='120'></span><span itemprop='height' content='99'></span></div><script src='http://cdnapi.kaltura.com/p/1529571/sp/152957100/embedIframeJs/uiconf_id/29215882/partner_id/1529571?autoembed=true&entry_id=0_qnqhojel&playerId=kaltura_player_1429574249&cache_st=1429574249&width=120&height=99'></script>"
        //
        //        self.videoView.loadHTMLString(myHTML, baseURL: nil)
        
        
        if let url = NSURL(string: self.urlstring!) {
            let request = NSURLRequest(URL: url)
            self.videoView.loadRequest(request)
        }
        makeNavigationBarCloseButton()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println("the video has finished loading")
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
