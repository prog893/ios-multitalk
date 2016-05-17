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

class ViewController: UIViewController {
    
    var socketPairInstance: multitalkStreamPair?
    var input = ""
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var textField: UITextField!
    
    @IBAction func pushButton(sender: AnyObject) {
        socketPairInstance!.writeToStream(textField!.text!)
        textView!.text! += textField!.text!
        textView!.text! += "\n"
        textField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        socketPairInstance = multitalkStreamPair()
        socketPairInstance?.parentView = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTextView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.textView.text! += self.input
        })
        
    }
    
    
    
    
}

