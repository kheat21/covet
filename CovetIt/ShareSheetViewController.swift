//
//  ShareSheetViewController.swift
//  CovetIt
//
//  Created by Covet on 1/23/22.
//

import UIKit
import Social
import MobileCoreServices
import Foundation
import UniformTypeIdentifiers
import SwiftSoup

class ShareSheetViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    var activityIndicator: UIActivityIndicatorView?
    var loadingTextView: UILabel?
    
    var alreadyConfigured: Bool = false
    var url: URL?;
    var selectedImage: ScrapedImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageViewPressed))
        previewImageView.addGestureRecognizer(tapGestureRecognizer)
        previewImageView.isUserInteractionEnabled = true
        
        let middleY = self.view.frame.height / 2
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(
            x: 0, y: middleY - 40, width: self.view.frame.width, height: 40
        ))
        activityIndicator!.startAnimating()
        
        loadingTextView = UILabel(frame: CGRect(
            x: 0, y: middleY + 12, width: self.view.frame.width, height: 40
        ))
        loadingTextView!.textAlignment = .center
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.alreadyConfigured {
            self.alreadyConfigured = true
            getSharedURL { url in
                self.url = url?.absoluteURL
                self.configureViewFor(url: self.url!)
                self.hideLoadingView()
            }
            self.showLoadingView(message: "This will only take a second")
        }
    }
    
    func configureViewFor(url: URL) {
        DispatchQueue.main.async {
            self.linkTextField.text = url.absoluteString
            self.titleTextField.text = self.getDefaultItemTitle()
        }
    }
    
    func getSharedURL(completion: @escaping (_: NSURL?) -> Void) -> NSURL? {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first {
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        if let shareURL = url as? NSURL {
                            // do what you want to do with shareURL
                            completion(shareURL)
                        }
                    })
                }
            }
        }
        return nil
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func imageViewPressed() {
        print("Image view pressed!")
        //DispatchQueue.main.sync {
            let tableViewController = TableViewController(url: self.url!.absoluteString)
            // tableViewController.modalPresentationStyle = .popover
            tableViewController.setSelectedImageHandler { image in
                self.selectedImage = image
                self.previewImageView.image = image.image
                self.dismiss(animated: true, completion: nil)
            }
            print("Trying to present table view controller")
        
            self.present(tableViewController, animated: true) {
                print("Completion")
            }
        // }
    }
    @IBAction func shareButtonPressed(_ sender: Any) {
        if !isFormValid() {}
    }
    
    func isFormValid() -> Bool {
        return (
            self.selectedImage != nil &&
            self.isTitleValid() &&
            self.isCommentValid()
        )
    }
    
    func isTitleValid() -> Bool {
        if let text = self.titleTextField.text {
            return text.count > 0
        }
        return false
    }
    
    func isCommentValid() -> Bool {
        if let comment = self.inputTextView.text {
            return comment.count > 0
        }
        return false
    }
    
    func getDefaultItemTitle() -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(getPageHTML())
            return try doc.title()
        } catch {
            return nil
        }
    }
    
    private func getPageHTML() throws -> String {
        return try String(contentsOf: self.url!)
    }
    
    func showLoadingView(message: String) {
            self.titleTextField.isHidden = true
            self.linkTextField.isHidden = true
            self.previewImageView.isHidden = true
            self.inputTextView.isHidden = true
            self.shareButton.isEnabled = false
            self.view.addSubview(self.activityIndicator!)
            self.view.addSubview(self.loadingTextView!)
            self.loadingTextView!.text = message
    }
    
    func hideLoadingView() {
        DispatchQueue.main.sync {
            self.titleTextField.isHidden = false
            self.linkTextField.isHidden = false
            self.previewImageView.isHidden = false
            self.inputTextView.isHidden = false
            self.activityIndicator!.removeFromSuperview()
            self.loadingTextView!.removeFromSuperview()
        }
    }
    
}
