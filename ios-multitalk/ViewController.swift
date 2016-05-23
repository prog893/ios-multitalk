//
//  ViewController.swift
//  ios-multitalk
//
//  Created by Torgayev Tamirlan on 5/17/16.
//  Copyright © 2016 pseudobeer. All rights reserved.
//

// Test by Bouningen578
//test ame

import UIKit
import Foundation

class ViewController: UIViewController, UITextFieldDelegate, UINavigationBarDelegate {
    
    let recursiveLock = NSRecursiveLock()
    var socketPairInstance: multitalkStreamPair?
    var input = ""
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    @IBAction func touchOutside(sender: AnyObject) {
        self.resignFirstResponder()
    }
    
    @IBAction func touchEnter(sender: AnyObject) {
        updateText()
    }
    
    @IBAction func pushButton(sender: AnyObject) {
        updateText()
    }
    
    func updateText(){
        socketPairInstance!.writeToStream(textField!.text!)
        if (textView!.text!.characters.last != "\n") {
            textView!.text! += "\n"
        }
        recursiveLock.lockBeforeDate(NSDate(timeIntervalSinceNow: 0.5))
        
        if textField!.text!.characters.first != "\\" {
            textView!.text! += textField!.text!
            textView!.text! += "\n"
        }
        
        textField.text = ""
        
        recursiveLock.unlock()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        updateText()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.bottomMargin.constant += keyboardSize.height
            
            UIView.animateWithDuration((notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double)!, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.bottomMargin.constant -= keyboardSize.height
            
            UIView.animateWithDuration((notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double)!, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.textField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func btn_clicked(sender: UIBarButtonItem) {
        // Do something
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField!.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, UIApplication.sharedApplication().statusBarFrame.height*3))
        
        navigationBar.backgroundColor = UIColor.whiteColor()
        navigationBar.delegate = self;
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "静 Chat"
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Profile", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.btn_clicked(_:)))
        let rightButton = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditingWrap)))
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    func endEditingWrap() {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        socketPairInstance = multitalkStreamPair()
        socketPairInstance?.parentView = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTextView() {
        self.textView.text! += self.input
    }
    
    
    
    
}

