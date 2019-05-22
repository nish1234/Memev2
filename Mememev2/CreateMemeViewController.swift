//
//  CreateMemeViewController.swift
//  Mememev1
//
//  Created by Nishtha Behal on 21/04/19.
//  Copyright © 2019 Nishtha Behal. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    
    private let defaultTopText = "TOP"
    private let defaultBottomText = "BOTTOM"
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 36)!,
        NSAttributedString.Key.strokeWidth:  -3.6
    ]

    //MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraPickButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topBarView: UIToolbar!
    @IBOutlet weak var toolbarView: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        imageSelected(flag: false)
        transitionToSentMemes()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        let memeImage = self.generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            activityController.popoverPresentationController?.sourceView = self.view
        }
        self.present(activityController, animated: true, completion: nil)
        activityController.completionWithItemsHandler = {
            (activity, success, items, error) in
            if(success && error == nil) {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImageFromSource(.camera)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickImageFromSource(.photoLibrary)
    }
    
    func pickImageFromSource(_ type: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = type
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: view life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSelected(flag: false)
        cameraPickButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        configure(topTextField, with: defaultTopText)
        configure(bottomTextField, with: defaultBottomText)
    }
    
    func configure(_ textField: UITextField, with defaultText: String) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.textAlignment = .center
    }
    
    func imageSelected(flag: Bool) {
        shareButton.isEnabled = flag
        topTextField.isEnabled = flag
        bottomTextField.isEnabled = flag
        if (!flag) {
            topTextField.text = defaultTopText
            bottomTextField.text = defaultBottomText
            imageView.image = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: UIImagePickerDelegate methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            imageSelected(flag: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Notifications
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        transitionToSentMemes()
    }

    func generateMemedImage() -> UIImage {
        hideToolbars(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideToolbars(false)
        return memedImage
    }

    func hideToolbars(_ flag: Bool) {
        toolbarView.isHidden = flag
        topBarView.isHidden = flag
    }
    
    func transitionToSentMemes() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

