//
//  ShareSheetViewController.swift
//  CovetIt
//

import UIKit
import Social
import MobileCoreServices
import Foundation
import UniformTypeIdentifiers
import SwiftSoup

// MARK: - FancyTextEditor

class FancyTextEditor: UITextField {
    let padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: padding) }
}

// MARK: - Stage enum (kept for compatibility)

enum ShareSheetViewControllerInputStage {
    case PHOTO, TITLE, VENDOR, PRICE, CAPTION, PREVIEW
}

// MARK: - ShareSheetViewController

class ShareSheetViewController: UIViewController {

    // IBOutlets — kept for storyboard compatibility
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var skipButton: UIBarButtonItem!

    // Scraping / image picker
    var tableViewController = TableViewController()
    var activityIndicator: UIActivityIndicatorView?
    var loadingTextView: UILabel?

    // Product data
    var url: URL?
    var image: ScrapedImage?
    var productTitle: String?
    var produtVendor: String?
    var productPrice: Double?
    var caption: String?

    // Review screen refs (updated by scraper as data arrives)
    var imageView: UIImageView?
    var brandFieldView: FancyTextEditor?
    var itemNameFieldView: FancyTextEditor?
    var priceLabelView: UILabel?
    var commentsTextView: UITextView?
    var primaryButton: UIButton?

    // Unused legacy refs kept so resetUI compiles
    var imageViewPrompt: UILabel?
    var inputFieldView: FancyTextEditor?
    var inputFieldPrompt: UILabel?
    var freeformView: UITextView?
    var previewTitleText: UILabel?
    var previewSecondaryText: UILabel?
    var previewTertiaryText: UILabel?

    var alreadyConfigured = false

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if !isLoggedIn() {
            let alert = UIAlertController(
                title: "Please Login",
                message: "You cannot Covet things unless you have recently signed into the app",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.extensionContext!.cancelRequest(withError: RuntimeError("Not logged in"))
            })
            present(alert, animated: true)
        }

        // Remove Skip, clear title — Back stays and cancels the extension
        navigationItem.rightBarButtonItem = nil
        navigationItem.title = ""

        view.backgroundColor = UIColor.systemGroupedBackground

        showLoadingSpinner()

        tableViewController.setSelectedImageHandler { [weak self] image in
            guard let self else { return }
            self.image = image
            DispatchQueue.main.async {
                self.imageView?.image = image.image
                self.imageView?.layer.borderWidth = 2
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !alreadyConfigured else { return }
        alreadyConfigured = true

        getSharedURL { [weak self] u in
            guard let self, let url = u else { return }
            self.url = url.absoluteURL
            DispatchQueue.main.async { self.buildReviewScreen() }
            if let urlString = url.absoluteString {
                // Direct HTTP scrape — fills fields as soon as page data arrives
                Task {
                    if let scraped = await ExtensionPageScraper.scrape(urlString: urlString) {
                        await MainActor.run { self.applyExtensionScrape(scraped) }
                    }
                }
                // Socket scraper for images (runs in parallel)
                self.listedForScrapedImages(url: urlString)
            }
        }
    }

    // MARK: - Build review screen

    func buildReviewScreen() {
        // Clear loading spinner
        activityIndicator?.removeFromSuperview()
        loadingTextView?.removeFromSuperview()
        primaryButton?.removeFromSuperview()

        let W = view.frame.width
        let pad: CGFloat = 20
        let PW = W - pad * 2

        // ── HEADER: logo + "Covet It" ──────────────────────────────────
        let headerY = CGFloat(navbarHeight()) + 20
        let logoH: CGFloat = 20
        let logoW: CGFloat = logoH * 3.6

        let logoImgView = UIImageView()
        logoImgView.image = UIImage(named: "Covet_Logo_BW")
        logoImgView.contentMode = UIView.ContentMode.scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "it"
        titleLabel.font = UIFont(name: "Georgia", size: 22) ?? .systemFont(ofSize: 22, weight: .light)
        titleLabel.textColor = .label
        titleLabel.sizeToFit()

        let gap: CGFloat = 8
        let totalHeaderW = logoW + gap + titleLabel.frame.width
        let startX = (W - totalHeaderW) / 2
        let headerH: CGFloat = 32

        logoImgView.frame = CGRect(x: startX, y: headerY + (headerH - logoH) / 2, width: logoW, height: logoH)
        titleLabel.frame = CGRect(
            x: startX + logoW + gap,
            y: headerY + (headerH - titleLabel.frame.height) / 2,
            width: titleLabel.frame.width,
            height: titleLabel.frame.height
        )
        view.addSubview(logoImgView)
        view.addSubview(titleLabel)

        // ── PRODUCT IMAGE ──────────────────────────────────────────────
        let imgSize: CGFloat = 100
        let imgY = headerY + headerH + 14
        let imgView = UIImageView(frame: CGRect(x: (W - imgSize) / 2, y: imgY, width: imgSize, height: imgSize))
        imgView.image = image?.image
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        imgView.layer.cornerRadius = 12
        imgView.layer.masksToBounds = true
        imgView.layer.borderColor = UIColor.covetGreen.cgColor
        imgView.layer.borderWidth = image != nil ? 2 : 0
        imgView.backgroundColor = UIColor.systemGray6
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewPressed)))
        view.addSubview(imgView)
        self.imageView = imgView

        // ── DETAILS CARD ───────────────────────────────────────────────
        let cardY = imgY + imgSize + 14
        let rowH: CGFloat = 50
        let divH: CGFloat = 1
        let innerPad: CGFloat = 16
        let commentLabelH: CGFloat = 18
        let commentViewH: CGFloat = 72
        let cardH = innerPad + rowH + divH + rowH + divH + rowH + divH + commentLabelH + 8 + commentViewH + innerPad

        let card = UIView(frame: CGRect(x: pad, y: cardY, width: PW, height: cardH))
        card.backgroundColor = UIColor.systemBackground
        card.layer.cornerRadius = 14
        card.layer.masksToBounds = true
        card.layer.borderColor = UIColor.systemGray5.cgColor
        card.layer.borderWidth = 1
        view.addSubview(card)

        let labelW: CGFloat = 64
        let fieldX: CGFloat = labelW + innerPad + 4
        let fieldW: CGFloat = PW - fieldX - innerPad

        func makeRowLabel(_ text: String, y: CGFloat) -> UILabel {
            let l = UILabel(frame: CGRect(x: innerPad, y: y, width: labelW, height: rowH))
            l.attributedText = NSAttributedString(string: text.uppercased(), attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel,
                .kern: 0.8
            ])
            return l
        }

        func makeDivider(y: CGFloat) -> UIView {
            let v = UIView(frame: CGRect(x: innerPad, y: y, width: PW - innerPad * 2, height: divH))
            v.backgroundColor = UIColor.systemGray5
            return v
        }

        func makeInputField(placeholder: String, y: CGFloat, text: String?) -> FancyTextEditor {
            let f = FancyTextEditor(frame: CGRect(x: fieldX, y: y + (rowH - 32) / 2, width: fieldW, height: 32))
            f.placeholder = placeholder
            f.text = text ?? ""
            f.font = UIFont.systemFont(ofSize: 15)
            f.textColor = UIColor.label
            f.borderStyle = .none
            return f
        }

        var curY: CGFloat = innerPad

        // Brand row
        card.addSubview(makeRowLabel("Brand", y: curY))
        let brandF = makeInputField(placeholder: "Brand name", y: curY, text: produtVendor)
        brandF.addTarget(self, action: #selector(brandChanged(_:)), for: .editingChanged)
        card.addSubview(brandF)
        self.brandFieldView = brandF
        curY += rowH

        card.addSubview(makeDivider(y: curY)); curY += divH

        // Item Name row
        card.addSubview(makeRowLabel("Item", y: curY))
        let nameF = makeInputField(placeholder: "Item name", y: curY, text: productTitle)
        nameF.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)
        card.addSubview(nameF)
        self.itemNameFieldView = nameF
        curY += rowH

        card.addSubview(makeDivider(y: curY)); curY += divH

        // Price row (read-only, auto-filled)
        card.addSubview(makeRowLabel("Price", y: curY))
        let priceLabel = UILabel(frame: CGRect(x: fieldX + 12, y: curY, width: fieldW - 12, height: rowH))
        priceLabel.font = .systemFont(ofSize: 15)
        if let p = productPrice, p > 0 {
            priceLabel.text = "$\(Int(p))"
            priceLabel.textColor = .label
        } else {
            priceLabel.text = "Fetching..."
            priceLabel.textColor = .tertiaryLabel
        }
        card.addSubview(priceLabel)
        self.priceLabelView = priceLabel
        curY += rowH

        card.addSubview(makeDivider(y: curY)); curY += divH

        // Comments
        let commentHeader = UILabel(frame: CGRect(x: innerPad, y: curY + 2, width: PW, height: commentLabelH))
        commentHeader.attributedText = NSAttributedString(string: "COMMENTS", attributes: [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel,
            .kern: 0.8
        ])
        card.addSubview(commentHeader)
        curY += commentLabelH + 8

        let commentTV = UITextView(frame: CGRect(x: innerPad, y: curY, width: PW - innerPad * 2, height: commentViewH))
        commentTV.font = UIFont.systemFont(ofSize: 15)
        commentTV.backgroundColor = UIColor.systemGray6
        commentTV.layer.cornerRadius = 8
        commentTV.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        commentTV.delegate = self
        if let c = caption, !c.isEmpty {
            commentTV.text = c
            commentTV.textColor = .label
        } else {
            commentTV.text = "What do you love about it?"
            commentTV.textColor = .placeholderText
        }
        card.addSubview(commentTV)
        self.commentsTextView = commentTV

        // ── COVET IT BUTTON ────────────────────────────────────────────
        buildCovetItButton()
    }

    func buildCovetItButton() {
        primaryButton?.removeFromSuperview()
        let btn = UIButton(frame: CGRect(
            x: 20,
            y: view.frame.height - 56 - 32,
            width: view.frame.width - 40,
            height: 56
        ))
        btn.setTitle("Send", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor.covetGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(covetItPressed), for: .touchUpInside)
        view.addSubview(btn)
        self.primaryButton = btn
    }

    // MARK: - Actions

    @objc func covetItPressed() {
        // Sync comments field before saving
        if let tv = commentsTextView, tv.textColor != .placeholderText {
            caption = tv.text.isEmpty ? nil : tv.text
        }
        // If no image selected yet, try auto-picking the first scraped image
        if image == nil, let first = tableViewController.images.first {
            image = first
        }
        savePost()
    }

    @objc func brandChanged(_ tf: UITextField) { produtVendor = tf.text }
    @objc func nameChanged(_ tf: UITextField) { productTitle = tf.text }

    @objc func imageViewPressed() {
        if tableViewController.images.count > 0 {
            present(tableViewController, animated: true)
        } else {
            let alert = UIAlertController(title: "Loading images", message: "Images are still loading from the page — try again in a moment.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @IBAction func shareButtonPressed(_ sender: Any) {}
    @IBAction func backButtonPressed(_ sender: Any) {
        extensionContext?.cancelRequest(withError: RuntimeError("User cancelled"))
    }

    // MARK: - Loading spinner

    func showLoadingSpinner() {
        let midY = view.frame.height / 2
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: midY - 40, width: view.frame.width, height: 40))
        activityIndicator?.style = .medium
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)

        loadingTextView = UILabel(frame: CGRect(x: 0, y: midY + 8, width: view.frame.width, height: 32))
        loadingTextView?.text = "Loading product..."
        loadingTextView?.textAlignment = .center
        loadingTextView?.font = .systemFont(ofSize: 14)
        loadingTextView?.textColor = .secondaryLabel
        view.addSubview(loadingTextView!)
    }

    // MARK: - URL extraction

    @discardableResult
    func getSharedURL(completion: @escaping (NSURL?) -> Void) -> NSURL? {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
           let provider = item.attachments?.first,
           provider.hasItemConformingToTypeIdentifier("public.url") {
            provider.loadItem(forTypeIdentifier: "public.url", options: nil) { url, _ in
                completion(url as? NSURL)
            }
        }
        return nil
    }

    // MARK: - Keyboard handling

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let kbHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
              let btn = primaryButton else { return }
        btn.frame.origin.y = view.frame.height - kbHeight - 56 - 12
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        primaryButton?.frame.origin.y = view.frame.height - 56 - 32
    }

    // MARK: - Helpers

    func toggleButtonStatus(enabled: Bool) {
        primaryButton?.isEnabled = enabled
        primaryButton?.backgroundColor = enabled ? UIColor.covetGreen : UIColor.systemGray4
    }

    // Legacy stub — no longer used but kept so extensions compile
    func toggleImageBorderStatus(enabled: Bool) {
        imageView?.layer.borderWidth = enabled ? 2 : 0
    }
}

// MARK: - UITextViewDelegate

extension ShareSheetViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What do you love about it?"
            textView.textColor = .placeholderText
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        caption = textView.text
    }
}
