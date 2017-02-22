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
public protocol PKStreamDelegate : NSObjectProtocol {
    
    func PKStream(_ aStream: Stream, eventCode: Stream.Event)
}

/// Socket class

public class PKSocket : NSObject {
    
    public var address : String!
    public var port : Int!
    
    public var delegate: PKStreamDelegate?
    
    fileprivate var bufferSize = 10240
    
    fileprivate var streamOpened : Bool = false
    
    fileprivate var onConnection : ((_ data : String?) -> Void)?
    
    fileprivate var OnError : ((_ errorString : String)->Void)?
    
    override init() {
        //        super.init()
    }
    
    /**
     Initializing PKSocket object with IP and Port
     
     - parameter lAddress: String type IP/web address
     - parameter lPort:    Int type port value
     
     - returns: PKObject type
     */
    public convenience init(lAddress : String, lPort : Int) {
        self.init()
        address = lAddress
        port = lPort
        
        initializeStreams()
    }
    
    fileprivate var inputStream : InputStream?
    fileprivate var outputStream : OutputStream?
    
    /**
     Initializes Input and output Streams with IP and port
     
     - returns: Returns stream objects
     */
    fileprivate func initializeStreams()  {

        Stream.getStreamsToHost(withName: address!, port: port!, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream?.delegate = self
        outputStream?.delegate = self
    }
    
    /**
     Set buffer size which is required to read from response
     
     - parameter lBufferSize: Int type size
     */
    public func setBufferSize (_ lBufferSize : Int){
        bufferSize = lBufferSize
    }
    
    /**
     Open Stream connection
     */
    public func openConnection() {
        
        if inputStream == nil {
            initializeStreams()
        }
        
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        inputStream?.open()
        outputStream?.open()
    }
    
    /**
     Checks wheather the stream is opened or not
     
     - returns: Bool type variable
     */
    public func isStreamOpened() -> Bool{
        return streamOpened
    }
    
    /**
     Handle stream connection with blocks
     
     - parameter connectionSuccess: When connection is successful with address and port
     - parameter data:              On recieving data from address (returns server data as a String value)
     - parameter Error:             on Error connection to stream or stream ends enexpectedly (returns error with connection as a String value)
     */
    public func handleConnection(_ connectionSuccess : @escaping (_ data : String?)->Void, Error : @escaping (_ errorString : String)->Void){
        
        onConnection = connectionSuccess
        OnError = Error
        
        if address == nil {
            OnError!(addressRequiredError)
        }
        
        if port == nil {
            OnError!(portNumberError)
        }
        
        openConnection()
    }
   
    fileprivate var dataSent : String? = nil
    /**
     Send date to output stream
     
     - parameter dataToSend: String variable to send to Ip or address
     */
    public func sendDataToStream(_ dataToSend : String){
        if !outputStream!.hasSpaceAvailable{
           outputStream?.open()
        }
        dataSent = dataToSend
        let encodedDataArray = [UInt8](dataToSend.utf8)
        outputStream?.write(encodedDataArray, maxLength: encodedDataArray.count)
    }
    
    /**
     Closes currently activated streams
     */
    public func closeConnection(){
        inputStream?.close()
        outputStream?.close()
    }
    
    fileprivate var serverDataRecieved : String? = nil
}

// MARK: - Delegate method fot stream

extension PKSocket : StreamDelegate{
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        let lBufferSize = bufferSize
        var buffer = Array<UInt8>(repeating: 0, count: lBufferSize)
        var len : Int!
        
        switch (eventCode) {
        
        case Stream.Event.openCompleted:
            self.streamOpened = true
            break
        case Stream.Event.hasBytesAvailable:
                       if aStream == inputStream {
                while ((inputStream?.hasBytesAvailable) != nil) {
                    
                    len = (inputStream?.read(&buffer, maxLength: bufferSize))!
                    
                    if len > 0 {
                        
                        let serverData = NSString.init(bytes: buffer, length: len, encoding: String.Encoding.ascii.rawValue)!
                        if serverData.length > 0 {
                            serverDataRecieved = serverData as String
                            onConnection!(serverData as String)
                        }
                        else{
                            serverDataRecieved = "No Data Recieved"
                            onConnection!(serverDataRecieved)
                        }
                    }
                    break
                }
            }
            dataSent = nil

            break
        case Stream.Event.hasSpaceAvailable :
            if dataSent == nil{
                onConnection!(serverDataRecieved)
            }
            break
        case Stream.Event.errorOccurred :
            aStream.close()
            closeConnection()
            OnError!(streamError)
            break
        case Stream.Event.endEncountered :
            aStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            OnError!(streamEnded)
            break
        default :
            OnError!(undefinedError)
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
