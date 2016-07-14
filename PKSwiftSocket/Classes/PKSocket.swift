//
//  PKSocket.swift
//  Pods
//
//  Created by Prateek Kansara on 14/07/16.
//
//

import Foundation

private let addressRequiredError = "Address required"
private let portNumberError = "Port number required"
private let streamError = "Stream Error"
private let streamEnded = "Stream Ended"
private let undefinedError = "Stream Undefined error"

public protocol PKStreamDelegate : NSObjectProtocol {
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent)
}

class PKSocket : NSObject {
    
    var address : String!
    var port : Int!
    
    public var delegate: PKStreamDelegate?
    
    private var bufferSize = 10240
    
    private var streamOpened : Bool = false
    
    private var onConnection : (() -> Void)?
    
    private var onRecievingData : ((data : String)-> Void)?
    
    private var OnError : ((errorString : String)->Void)?
    
    override init() {
        super.init()
    }
    
    convenience init(lAddress : String, lPort : Int) {
        self.init()
        address = lAddress
        port = lPort
        
        initializeStreams()
    }
    
    private var inputStream : NSInputStream?
    private var outputStream : NSOutputStream?
    
    
    private func initializeStreams()  {
        
        NSStream.getStreamsToHostWithName(address, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream?.delegate = self
        outputStream?.delegate = self
        
        inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    public func setBufferSize (lBufferSize : Int){
        bufferSize = lBufferSize
    }
    
    public func openConnection() {
        
        if inputStream == nil {
            initializeStreams()
        }
        
        inputStream?.open()
        outputStream?.open()
    }
    
    public func isStreamOpened() -> Bool{
        return streamOpened
    }
    
    public func handleConnection(connectionSuccess : ()->Void, data : (Data : String) -> Void, Error : (errorString : String)->Void){
        
        onConnection = connectionSuccess
        onRecievingData = data
        OnError = Error
        
        if address == nil {
            OnError!(errorString: addressRequiredError)
        }
        
        if port == nil {
            OnError!(errorString: portNumberError)
        }
        
        openConnection()
    }
    
    public func sendDataToStream(dataToSend : String){
        let encodedDataArray = [UInt8](dataToSend.utf8)
        outputStream?.write(encodedDataArray, maxLength: encodedDataArray.count)
    }
    
    public func closeConnection(){
        inputStream?.close()
        outputStream?.close()
    }
}

extension PKSocket : NSStreamDelegate{
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        if ((delegate?.respondsToSelector(#selector(PKSocket.stream(_:handleEvent:)))) != nil) {
            delegate?.stream(aStream, handleEvent: eventCode)
        }
        
        let lBufferSize = bufferSize
        var buffer = Array<UInt8>(count: lBufferSize, repeatedValue: 0)
        var len : Int!
        
        switch (eventCode) {
            
        case NSStreamEvent.OpenCompleted:
            onConnection!()
            streamOpened = true
            break
        case NSStreamEvent.HasBytesAvailable:
            if aStream == inputStream {
                
                while ((inputStream?.hasBytesAvailable) != nil) {
                    
                    len = (inputStream?.read(&buffer, maxLength: bufferSize))!
                    
                    if len > 0 {
                        let serverData = NSString.init(bytes: buffer, length: len, encoding: NSASCIIStringEncoding)!
                        if serverData.length > 0 {
                            onRecievingData!(data : serverData as! String)
                        }
                    }
                    break
                }
            }
            break
        case NSStreamEvent.HasSpaceAvailable :
//            print("Stream has space available")
            break
        case NSStreamEvent.ErrorOccurred :
            aStream.close()
            closeConnection()
            OnError!(errorString: streamError)
            break
        case NSStreamEvent.EndEncountered :
            aStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            OnError!(errorString: streamEnded)
            break
        default :
            OnError!(errorString: undefinedError)
            break
        }
    }

}