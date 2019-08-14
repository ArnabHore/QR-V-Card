//
//  WebViewController.swift
//  QR-BCard
//
//  Created by SlicePay on 16/08/18.
//  Copyright © 2018 Arnab Hore. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var webkitView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webkitView.navigationDelegate = self
        
        webkitView.addObserver(self, forKeyPath: "loading", options: .new, context: nil);
        webkitView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        
        let myUrl = URL(string: "http://popcornarena.com/getmycontact/credits.html")
        let myUrlRequest = URLRequest(url: myUrl!)
        webkitView.load(myUrlRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Observe Value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" {
            print("Loading")
        } else if keyPath == "estimatedProgress" {
            print(webkitView.estimatedProgress);
            progressView.progress = Float(webkitView.estimatedProgress)
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed with error: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finish")
    }
}
