//
//  multitalkStreamPair.swift
//  ios-multitalk
//
//  Created by Torgayev Tamirlan on 5/18/16.
//  Copyright © 2016 pseudobeer. All rights reserved.
//

import Foundation

class multitalkStreamPair: NSObject, NSStreamDelegate {
    var inputStream: NSInputStream
    var outputStream: NSOutputStream
    var parentView: ViewController?
    
    var bufferpointer: UnsafeMutablePointer<UInt8>
    
    @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.EndEncountered:
            outputStream.close()
            outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        case NSStreamEvent.ErrorOccurred:
            NSLog("Stream error occured")
        case NSStreamEvent.HasBytesAvailable:
            if inputStream == aStream {
                let string = readAll()
                if let unwrappedParent = parentView {
                    unwrappedParent.input = string;
                    unwrappedParent.updateTextView();
                }
            }
        case NSStreamEvent.HasSpaceAvailable:
            if outputStream == aStream {
                NSLog("has space available?")
            }
        case NSStreamEvent.OpenCompleted:
            NSLog("Opened streams")
        default:
            NSLog("Unknown stream event")
        }
    }
    
    override init(){
        
        let buffer = malloc(sizeof(UInt8)*1024)
        
        bufferpointer = unsafeBitCast(buffer, UnsafeMutablePointer<UInt8>.self)
        
        var readStream: Unmanaged<CFReadStream>? = nil
        var writeStream: Unmanaged<CFWriteStream>? = nil
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "api.pseudobeer.jp", 11111, &readStream, &writeStream)
        
        let inputStreamOpt = readStream!.takeRetainedValue() as NSInputStream?
        let outputStreamOpt = writeStream!.takeRetainedValue() as NSOutputStream?
        
        if let inputStreamUnwrap = inputStreamOpt {
            inputStream = inputStreamUnwrap
            if let outputStreamUnwrap = outputStreamOpt {
                outputStream = outputStreamUnwrap
                
                super.init()
                
                inputStream.delegate = self
                outputStream.delegate = self
                
                inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
                outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
                
                inputStream.open()
                outputStream.open()
                
                while(outputStream.streamStatus != NSStreamStatus.Open) {}
                
            } else {
                fatalError("Cannot initialize sockets")
            }
        } else {
            fatalError("Cannot initialize sockets")
        }
    }
    
    func writeToStream(a: String) {
        
        let data: NSData = a.dataUsingEncoding(NSUTF8StringEncoding)!
        outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        write(1, UnsafePointer<UInt8>(data.bytes), data.length)
    }
    
    func readAll() -> String {
        
        var len: Int
        var ret: String = ""
        
        while(inputStream.hasBytesAvailable != false) {
            if self.inputStream.hasBytesAvailable {
                len = self.inputStream.read(self.bufferpointer, maxLength: 1024)
                let data = NSData(bytes: self.bufferpointer, length: len)
                ret += String(NSString(data: data, encoding: NSUTF8StringEncoding))
                
            }
        }
        
        return ret
        
    }
    
}