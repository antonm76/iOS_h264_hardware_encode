//
//  SocketWriter.swift
//  iOS_H264Encode
//
//  Created by Artem Kirienko on 21/02/2019.
//  Copyright © 2019 NTU. All rights reserved.
//

import Foundation
import SocketSwift

fileprivate enum SocketType
{
    case TCP
    case UDP
}

@objc class SocketWriter: NSObject
{
    private let type = SocketType.UDP
    
    private let server = try! Socket(.inet, type: .stream, protocol: .tcp)
    private let client = try! Socket(.inet, type: .datagram, protocol: .udp)
    private let queue = DispatchQueue(label: "SocketWriter")

    private var vlc: Socket!
    
    @objc(writeData:)
    func write(data: Data)
    {
        queue.async
            {
                data.withUnsafeBytes {
                    (pointer: UnsafePointer<UInt8>) -> Void in
                    
                    if self.type == .TCP
                    {
                        try? self.vlc.write(pointer, length: data.count)
                    }
                    else if self.type == .UDP
                    {
                        try? self.client.write(pointer, length: data.count)
                    }
                }
        }
    }

    @objc
    func start() {
        if type == .TCP
        {
            try! server.bind(port: 8090, address: nil)
            try! server.listen()
            vlc = try! server.accept()
        }
        else if type == .UDP
        {
            try! client.connect(port: 8090, address: "10.110.7.80")
        }
    }

    @objc
    func stop() {
        if type == .TCP
        {
            server.close()
            vlc.close()
        }
        else if type == .UDP
        {
            client.close()
        }
    }
}
