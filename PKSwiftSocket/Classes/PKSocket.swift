//
//  PKSocket.swift
//  Pods
//
//  Created by Prateek Kansara on 14/07/16.
//
//

import Foundation

/**
 *  Stream delegate method to handle event
 */
@objc protocol PKStreamDelegate : NSObjectProtocol {
    
    func PKStream(aStream: NSStream, eventCode: NSStreamEvent)
}

/// Socket class

public class PKSocket : NSObject {
    
    var address : String!
    var port : Int!
    
    var delegate: PKStreamDelegate?
    
    private var bufferSize = 10240
    
    private var streamOpened : Bool = false
    
    private var onConnection : (() -> Void)?
    
    private var onRecievingData : ((data : String)-> Void)?
    
    private var OnError : ((errorString : String)->Void)?
    
    override init() {
        //        super.init()
    }
    
    /**
     Initializing PKSocket object with IP and Port
     
     - parameter lAddress: String type IP/web address
     - parameter lPort:    Int type port value
     
     - returns: PKObject type
     */
    convenience init(lAddress : String, lPort : Int) {
        self.init()
        address = lAddress
        port = lPort
        
        initializeStreams()
    }
    
    private var inputStream : NSInputStream?
    private var outputStream : NSOutputStream?
    
    /**
     Initializes Input and output Streams with IP and port
     
     - returns: Returns stream objects
     */
    private func initializeStreams()  {
        
        NSStream.getStreamsToHostWithName(address, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream?.delegate = self
        outputStream?.delegate = self
    }
    
    /**
     Set buffer size which is required to read from response
     
     - parameter lBufferSize: Int type size
     */
    func setBufferSize (lBufferSize : Int){
        bufferSize = lBufferSize
    }
    
    /**
     Open Stream connection
     */
    func openConnection() {
        
        if inputStream == nil {
            initializeStreams()
        }
        
        inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inputStream?.open()
        outputStream?.open()
    }
    
    /**
     Checks wheather the stream is opened or not
     
     - returns: Bool type variable
     */
    func isStreamOpened() -> Bool{
        return streamOpened
    }
    
    /**
     Handle stream connection with blocks
     
     - parameter connectionSuccess: When connection is successful with address and port
     - parameter data:              On recieving data from address (returns server data as a String value)
     - parameter Error:             on Error connection to stream or stream ends enexpectedly (returns error with connection as a String value)
     */
    func handleConnection(connectionSuccess : ()->Void, data : (Data : String) -> Void, Error : (errorString : String)->Void){
        
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
    
    /**
     Send date to output stream
     
     - parameter dataToSend: String variable to send to Ip or address
     */
    func sendDataToStream(dataToSend : String){
        let encodedDataArray = [UInt8](dataToSend.utf8)
        outputStream?.write(encodedDataArray, maxLength: encodedDataArray.count)
    }
    
    /**
     Closes currently activated streams
     */
    func closeConnection(){
        inputStream?.close()
        outputStream?.close()
    }
}

// MARK: - Delegate method fot stream

extension PKSocket : NSStreamDelegate{
    
    public func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
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
                            onRecievingData!(data : serverData as String)
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

/// Constants
private let addressRequiredError = "Address required"
private let portNumberError = "Port number required"
private let streamError = "Stream Error"
private let streamEnded = "Stream Ended"
private let undefinedError = "Stream Undefined error"