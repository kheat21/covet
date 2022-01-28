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

class FancyTextEditor: UITextField {
    // Whatever you like
    let padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16);
    // Paddging for place holder
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    // Padding for text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    // Padding for text in editting mode
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}

enum ShareSheetViewControllerInputStage {
    case PHOTO
    case TITLE
    case VENDOR
    case PRICE
    case CAPTION
    case PREVIEW
}

class ShareSheetViewController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    //@IBOutlet weak var vendorTextField: UITextField!
    //@IBOutlet weak var priceTextField: UITextField!
    //@IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    //@IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    var activityIndicator: UIActivityIndicatorView?
    var loadingTextView: UILabel?
    var imageView: UIImageView?
    var imageViewPrompt: UILabel?
    var inputFieldView: FancyTextEditor?
    var inputFieldPrompt: UILabel?
    var freeformView: UITextView?
    var primaryButton: UIButton?
    
    var previewTitleText: UILabel?
    var previewSecondaryText: UILabel?
    var previewTertiaryText: UILabel?
    
    var alreadyConfigured: Bool = false
    var url: URL?;
    var image: ScrapedImage?;
    var productTitle: String?;
    var produtVendor: String?
    var productPrice: Double?
    var caption: String?
    
    var stages = [
        ShareSheetViewControllerInputStage.PHOTO,
        ShareSheetViewControllerInputStage.TITLE,
        ShareSheetViewControllerInputStage.VENDOR,
        ShareSheetViewControllerInputStage.PRICE,
        ShareSheetViewControllerInputStage.CAPTION,
        ShareSheetViewControllerInputStage.PREVIEW
    ]
    var stageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (isLoggedIn()) {
            let alert = UIAlertController(title: "Please Login", message: "You cannot Covet things unless you have recently signed into the app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.extensionContext!.cancelRequest(withError: RuntimeError("Not logged in"))
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        self.backButton!.tintColor = UIColor.covetGreen
        
        configureLoadingView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.alreadyConfigured {
            self.alreadyConfigured = true
            getSharedURL { url in
                self.url = url?.absoluteURL
                //self.configureViewFor(url: self.url!)
                self.buildUI()
            }
            // self.showLoadingView(message: "This will only take a second")
        }
    }
    
    @objc func primaryButtonPressed() {
        if self.stageIndex < self.stages.count - 1 {
            print("Going to the next page")
            nextPage()
        } else {
            print("Saving post...")
            savePost()
        }
    }
    
    @objc func nextPage() {
        self.stageIndex += 1
        resetUI()
        buildUI()
    }
    
    @objc func lastPage() {
        if self.stageIndex > 0 {
            self.stageIndex -= 1
            resetUI()
            buildUI()
        }
    }
    
    func buildUI() {
        DispatchQueue.main.async {
            let stage = self.stages[self.stageIndex]
            
            switch (stage) {
            case .PHOTO:
                self.buildPhotoPage(imageBorderPresentByDefault: self.image != nil)
                self.buildBottomButton(enabledByDefault: self.image != nil)
                self.skipButton.isEnabled = false
                self.skipButton.tintColor = UIColor.clear
            case .TITLE:
                self.buildInputPage(
                    prompt: "Product Title",
                    placeholder: "Industrial Incandescent Lamp",
                    value: self.productTitle as AnyObject
                )
                self.buildBottomButton(enabledByDefault: self.truthy(value: self.productTitle))
                self.skipButton.isEnabled = false
                self.skipButton.tintColor = UIColor.clear
            case .VENDOR:
                self.buildInputPage(
                    prompt: "Vendor (company that makes it)",
                    placeholder: "B&M Furniture",
                    value: self.produtVendor as AnyObject
                )
                self.buildBottomButton(enabledByDefault: self.truthy(value: self.produtVendor))
                self.skipButton.isEnabled = true
                self.skipButton.tintColor = UIColor.covetGreen
            case .PRICE:
                self.buildInputPage(
                    prompt: "Price",
                    placeholder: "$199.99",
                    value: self.productPrice as AnyObject,
                    inputType: .decimalPad
                )
                self.buildBottomButton(enabledByDefault: self.productPrice != nil)
                self.skipButton.isEnabled = true
                self.skipButton.tintColor = UIColor.covetGreen
            case .CAPTION:
                self.buildInputPage(
                    prompt: "Caption",
                    placeholder: "Say something about this product and why you like it",
                    value: self.caption as AnyObject
                )
                self.buildBottomButton(enabledByDefault: self.truthy(value: self.caption))
                self.skipButton.isEnabled = true
                self.skipButton.tintColor = UIColor.covetGreen
            case .PREVIEW:
                self.buildPreviewPage()
                self.buildBottomButton(enabledByDefault: true, text: "POST")
                self.skipButton.isEnabled = false
                self.skipButton.tintColor = UIColor.clear
            default:
                break
            }
            self.backButton.isEnabled = self.stageIndex > 0
    
        }
    }
    
    func resetUI() {
        self.activityIndicator?.removeFromSuperview()
        self.loadingTextView?.removeFromSuperview()
        self.imageView?.removeFromSuperview()
        self.imageViewPrompt?.removeFromSuperview()
        self.inputFieldView?.removeFromSuperview()
        self.inputFieldPrompt?.removeFromSuperview()
        self.freeformView?.removeFromSuperview()
        self.primaryButton?.removeFromSuperview()
        self.previewTitleText?.removeFromSuperview()
        self.previewSecondaryText?.removeFromSuperview()
        self.previewTertiaryText?.removeFromSuperview()
    }
    
    func buildInputPage(
        prompt: String,
        placeholder: String,
        value: AnyObject?,
        inputType: UIKeyboardType = .asciiCapable
    ) {
        
        let inputFieldPromptHeight: Double = 40.0
        let inputFieldPromptTopY: Double = self.fromTop(y: 16)
        let inputFieldViewTopY: Double = inputFieldPromptTopY + inputFieldPromptHeight + 16
        
        self.inputFieldPrompt = UILabel(frame: CGRect(
            x: self.paddedXLeft(),
            y: inputFieldPromptTopY,
            width: self.paddedWidth(),
            height: inputFieldPromptTopY
        ))
        self.inputFieldPrompt!.text = prompt
        
        self.inputFieldView = FancyTextEditor(frame: CGRect(
            x: self.paddedXLeft(),
            y: inputFieldViewTopY,
            width: self.paddedWidth(),
            height: 48
        ))
        self.inputFieldView?.backgroundColor = UIColor.white
        self.inputFieldView?.layer.masksToBounds = false
        self.inputFieldView?.layer.shadowRadius = 3.0
        self.inputFieldView?.layer.shadowColor = UIColor.gray.cgColor
        self.inputFieldView?.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.inputFieldView?.layer.shadowOpacity = 1
        self.inputFieldView?.layer.cornerRadius = 0
        self.inputFieldView?.borderStyle = .roundedRect
        self.inputFieldView?.placeholder = placeholder
        self.inputFieldView?.keyboardType = inputType
        
        var string: String = ""
        if let decimalValue = value as? Double {
            string = String(decimalValue)
        }
        else if let stringValue = value as? String {
            string = stringValue
        }
        
        self.inputFieldView?.text = string
        self.inputFieldView?.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        self.view.addSubview(self.inputFieldPrompt!)
        self.view.addSubview(self.inputFieldView!)
    }
    
    func buildPhotoPage(imageBorderPresentByDefault: Bool = false) {
        
        let imageViewSize = self.getImageSize()
        let imageViewYOrigin = self.fromTop(y: 64)
        
        self.imageView = UIImageView(frame: CGRect(
            x: self.centerX(width: imageViewSize),
            y: imageViewYOrigin,
            width: imageViewSize,
            height: imageViewSize
        ))
        self.imageView!.image = self.image?.image ?? UIImage(named: "Pick_Image")
        self.view.addSubview(self.imageView!)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageViewPressed))
        self.imageView!.addGestureRecognizer(tapGestureRecognizer)
        self.imageView!.isUserInteractionEnabled = true
        self.toggleImageBorderStatus(enabled: imageBorderPresentByDefault)
        
        self.imageViewPrompt = UILabel(frame: CGRect(
            x: 0,
            y: imageViewYOrigin + imageViewSize + 16.0,
            width: self.view.frame.width,
            height: 32
        ))
        self.imageViewPrompt?.textAlignment = .center
        self.imageViewPrompt?.text = "Pick the best picture of the product"
        self.imageViewPrompt?.textColor = UIColor.lightGray
        self.view.addSubview(self.imageViewPrompt!)
    }
    
    func buildPreviewPage() {
        
        let padding = 16.0
        let imageViewSize = self.getImageSize()
        let imageViewYOrigin = self.fromTop(y: 32)
        
        let primaryTextHeight = 48.0
        let primaryTextY = imageViewYOrigin + imageViewSize + padding
        
        let secondaryTextHeight = 32.0
        let secondaryTextY = primaryTextY + primaryTextHeight + padding
        
        let tertiaryTextHeight = 26.0
        let tertiaryTextY = secondaryTextY + secondaryTextHeight + padding
        
        let hasVendor = self.produtVendor != nil
        let hasPrice = self.productPrice != nil
        let hasVendorOrPrice = hasVendor || hasPrice
        let hasCaption = self.caption != nil
        
        self.imageView = UIImageView(frame: CGRect(
            x: self.centerX(width: imageViewSize),
            y: imageViewYOrigin,
            width: imageViewSize,
            height: imageViewSize
        ))
        self.imageView!.image = self.image?.image ?? UIImage(named: "Pick_Image")
        self.imageView!.layer.borderColor = UIColor.covetGreen.cgColor
        self.imageView!.layer.borderWidth = 4.0
        self.view.addSubview(self.imageView!)
        
        self.previewTitleText = UILabel(frame: CGRect(
            x: self.paddedXLeft(), y: primaryTextY, width: self.paddedWidth(), height: primaryTextHeight
        ))
        self.previewTitleText!.text = self.productTitle!
        self.previewTitleText!.textAlignment = .center
        self.previewTitleText!.font = .systemFont(ofSize: 24)
        
        self.previewSecondaryText = UILabel(frame: CGRect(
            x: self.paddedXLeft(), y: secondaryTextY, width: self.paddedWidth(), height: secondaryTextHeight
        ))
        self.previewSecondaryText!.textAlignment = .center
        self.previewSecondaryText!.font = .systemFont(ofSize: 20)
        var secondaryStr = ""
        if(hasVendor) {
            secondaryStr += produtVendor!
        }
        if (hasPrice) {
            if(self.produtVendor != nil) {
                secondaryStr += " - "
            }
            secondaryStr += "$" + String(productPrice!)
        }
        if (!hasVendorOrPrice && hasCaption) {
            secondaryStr += self.caption!
            self.previewSecondaryText!.font = .systemFont(ofSize: 16)
        }
        self.previewSecondaryText!.text = secondaryStr
        
        self.previewTertiaryText = UILabel(frame: CGRect(
            x: self.paddedXLeft(), y: tertiaryTextY, width: self.paddedWidth(), height: tertiaryTextHeight
        ))
        self.previewTertiaryText?.textAlignment = .center
        if (hasVendorOrPrice && hasCaption) {
            self.previewTertiaryText!.text = self.caption!
            self.previewTertiaryText!.font = .systemFont(ofSize: 16)
        }
        
        self.view.addSubview(self.previewTitleText!)
        self.view.addSubview(self.previewSecondaryText!)
        self.view.addSubview(self.previewTertiaryText!)
        
    }
    
    func buildBottomButton(enabledByDefault: Bool = false, text: String = "Next") {
        self.primaryButton = UIButton(frame: CGRect(
            x: self.paddedXLeft(),
            y: self.view.frame.height - (52.0 + 24.0),
            width: self.paddedWidth(),
            height: 52
        ))
        
        self.primaryButton?.setTitle(text, for: UIControl.State.normal)
        self.primaryButton?.layer.cornerRadius = 4
        self.primaryButton?.layer.shadowColor = UIColor.gray.cgColor
        self.primaryButton?.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.primaryButton?.layer.shadowOpacity = 0.3
        
        self.primaryButton?.addTarget(self, action: #selector(primaryButtonPressed), for: .touchUpInside)
        self.toggleButtonStatus(enabled: enabledByDefault)
        
        self.view.addSubview(self.primaryButton!)
    }
    
    func configureViewFor(url: URL) {
        DispatchQueue.main.async {
            let suggestedText = self.getDefaultItemTitle()
            
            // If the user's already typed something by the time we
            // get here, just keep whatever they typed
            if let existingText = self.productTitle {
                if existingText.count > 0 {
                    return
                }
            }
            self.productTitle = suggestedText
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
    
    @objc func imageViewPressed() {
        print("Image view pressed!")
        //DispatchQueue.main.sync {
            let tableViewController = TableViewController(url: self.url!.absoluteString)
            // tableViewController.modalPresentationStyle = .popover
            tableViewController.setSelectedImageHandler { image in
                self.image = image
                self.imageView?.image = image.image
                self.dismiss(animated: true, completion: nil)
                
                self.toggleButtonStatus(enabled: true)
                self.toggleImageBorderStatus(enabled: true)
            }
            print("Trying to present table view controller")
        
            self.present(tableViewController, animated: true) {
                print("Completion")
            }
    }
    @IBAction func shareButtonPressed(_ sender: Any) {
        nextPage()
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

    func configureLoadingView() {
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch ( self.stages[self.stageIndex] ) {
            case .TITLE:
                self.productTitle = textField.text
            case .VENDOR:
                self.produtVendor = textField.text
            case .PRICE:
                var val: Double? = nil
                if let text = textField.text {
                    if let doubleValue = Double(text) {
                        val = doubleValue
                    }
                }
                self.productPrice = val
            case .CAPTION:
                self.caption = textField.text
            default: break
        }
        if let text = textField.text {
            self.toggleButtonStatus(enabled: text.count > 0)
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        
        print("Keyboard will show")

//        guard let userInfo = notification.userInfo else { return }
//        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
        print(keyboardHeight)
        
        if let pb = self.primaryButton {
            print("Got the button")
            pb.frame = CGRect(
                x: self.paddedXLeft(),
                y: self.view.frame.height - keyboardHeight - 52.0 - 16.0,
                width: self.paddedWidth(),
                height: 52
            )
            print(pb.frame)
        }

//        var contentInset:UIEdgeInsets = self.scrollView.contentInset
//        contentInset.bottom = keyboardFrame.size.height + 20
//        scrollView.contentInset = contentInset
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        lastPage()
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {

        if let pb = self.primaryButton {
            pb.frame = CGRect(
                x: self.paddedXLeft(),
                y: self.view.frame.height - 52.0 - 24.0,
                width: self.paddedWidth(),
                height: 52
            )
        }
        
    }
    
    func toggleButtonStatus(enabled: Bool) {
        self.primaryButton?.isEnabled = enabled
        self.primaryButton?.backgroundColor = enabled ? UIColor.covetGreen : UIColor.darkGray
    }
    
    func toggleImageBorderStatus(enabled: Bool) {
        self.imageView!.layer.borderColor = UIColor.covetGreen.cgColor
        self.imageView!.layer.borderWidth = enabled ? 4.0 : 0.0
    }
    
    private func truthy(value: String?) -> Bool {
        if let val = value {
            return val.count > 0
        }
        return value != nil
    }
}
