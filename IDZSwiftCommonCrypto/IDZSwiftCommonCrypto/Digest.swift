//
//  Digest.swift
//  SwiftCommonCrypto
//
//  Created by idz on 9/19/14.
//  Copyright (c) 2014 iOS Developer Zone. All rights reserved.
//

import Foundation
import CommonCrypto

// MARK: - Public Interface
 /**
  Public API for message digests.

  Usage is striaghtforward
  ::
        let  s = "The quick brown fox jumps over the lazy dog."
        var md5 : Digest = Digest(algorithm:.MD5)
        md5.update(s)
        let digest = md5.final()
  */
public class Digest
{   /**
        - MD2: Message Digest 2 See: http://en.wikipedia.org/wiki/MD2_(cryptography)
        - MD4
        - MD5
        - SHA1: Secure Hash Algorithm 1
        - SHA224: Secure Hash Algorithm 2 224-bit
        - SHA256: Secure Hash Algorithm 2 256-bit
        - SHA384: Secure Hash Algorithm 2 384-bit
        - SHA512: Secure Hash Algorithm 2 512-bit
     */
    public enum Algorithm
    {
        case MD2, MD4, MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    }
    
    var engine: DigestEngine
    /**
       Create an algorithm-specific digest calculator
       :param: alrgorithm the desired message digest algorithm
     */
    public init(algorithm: Algorithm)
    {
        switch algorithm {
        case .MD2:
            engine = DigestEngineCC<CC_MD2_CTX>(initializer:CC_MD2_Init, updater:CC_MD2_Update, finalizer:CC_MD2_Final, length:CC_MD2_DIGEST_LENGTH)
        case .MD4:
            engine = DigestEngineCC<CC_MD4_CTX>(initializer:CC_MD4_Init, updater:CC_MD4_Update, finalizer:CC_MD4_Final, length:CC_MD4_DIGEST_LENGTH)
        case .MD5:
            engine = DigestEngineCC<CC_MD5_CTX>(initializer:CC_MD5_Init, updater:CC_MD5_Update, finalizer:CC_MD5_Final, length:CC_MD5_DIGEST_LENGTH)
        case .SHA1:
            engine = DigestEngineCC<CC_SHA1_CTX>(initializer:CC_SHA1_Init, updater:CC_SHA1_Update, finalizer:CC_SHA1_Final, length:CC_SHA1_DIGEST_LENGTH)
        case .SHA224:
            engine = DigestEngineCC<CC_SHA256_CTX>(initializer:CC_SHA224_Init, updater:CC_SHA224_Update, finalizer:CC_SHA224_Final, length:CC_SHA224_DIGEST_LENGTH)
        case .SHA256:
            engine = DigestEngineCC<CC_SHA256_CTX>(initializer:CC_SHA256_Init, updater:CC_SHA256_Update, finalizer:CC_SHA256_Final, length:CC_SHA256_DIGEST_LENGTH)
        case .SHA384:
            engine = DigestEngineCC<CC_SHA512_CTX>(initializer:CC_SHA384_Init, updater:CC_SHA384_Update, finalizer:CC_SHA384_Final, length:CC_SHA384_DIGEST_LENGTH)
        case .SHA512:
            engine = DigestEngineCC<CC_SHA512_CTX>(initializer:CC_SHA512_Init, updater:CC_SHA512_Update, finalizer:CC_SHA512_Final, length:CC_SHA512_DIGEST_LENGTH)
        }
    }
    /**
        Low-level update routine. Updates the message digest calculation with
        the contents of a byte buffer.
        
        :param: buffer the buffer
        :returns: this Digest object (for optional chaining)
    */
    public func update(buffer: UnsafePointer<UInt8>, _ byteCount: CC_LONG) -> Digest?
    {
        engine.update(buffer, byteCount)
        return self
    }
    /**
        Updates the message digest with a byte buffer.
    
        :param: buffer the buffer
        :returns: this Digest object (for optional chaining)
    */
    public func update(buffer : [UInt8]) -> Digest?
    {
        engine.update(buffer, CC_LONG(buffer.count))
        return self
    }
    
    /**
       Updates the message digest being calculated with the contents
       of a string interpreted as UTF8.
    
       :param: s the string
       :returns: this Digest object (for optional chaining)
    */
    public func update(s : String) -> Digest?
    {
        engine.update(s, CC_LONG(s.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        return self
    }
    
    /**
       Completes the calculate of the messge digest
       :returns: the message digest
     */
    public func final() -> [UInt8]
    {
        return engine.final()
    }
}

// MARK: Internal Classes

/**
 * Defines the interface between the Digest class and an
 * algorithm specific DigestEngine
 */
protocol DigestEngine
{
    func update(buffer: UnsafePointer<Void>, _ byteCount: CC_LONG)
    func final() -> [UInt8]
}
/**
 * Wraps the underlying algorithm specific structures and calls
 * in a generic interface.
 */
class DigestEngineCC<C> : DigestEngine {
    typealias Context = UnsafeMutablePointer<C>
    typealias Buffer = UnsafePointer<Void>
    typealias Digest = UnsafeMutablePointer<UInt8>
    typealias Initializer = (Context) -> (Int32)
    typealias Updater = (Context, Buffer, CC_LONG) -> (Int32)
    typealias Finalizer = (Digest, Context) -> (Int32)
    
    let context = Context.alloc(1)
    var initializer : Initializer
    var updater : Updater
    var finalizer : Finalizer
    var length : Int32
    
    init(initializer : Initializer, updater : Updater, finalizer : Finalizer, length : Int32)
    {
        self.initializer = initializer
        self.updater = updater
        self.finalizer = finalizer
        self.length = length
        initializer(context)
    }
    
    deinit
    {
        context.dealloc(1)
    }
    
    func update(buffer: Buffer, _ byteCount: CC_LONG)
    {
        updater(context, buffer, byteCount)
    }
    
    func final() -> [UInt8]
    {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        var digest = Array<UInt8>(count:digestLength, repeatedValue: 0)
        finalizer(&digest, context)
        return digest
    }
}





