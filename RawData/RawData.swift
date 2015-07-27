//
//  RawData.swift
//  RawData
//
//  Created by Marcin Krzyzanowski on 26/07/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

class RawData: CustomStringConvertible, ArrayLiteralConvertible {
    typealias Byte = UInt8
    typealias Element = Byte
    
    let pointer:UnsafeMutablePointer<Element>
    let count:Int
    
    var description: String {
        return "<\(toHex())>"
    }
    
    required init() {
        self.count = 0
        self.pointer = UnsafeMutablePointer.alloc(count)
    }
    
    required init(count: Int) {
        self.count = count
        self.pointer = UnsafeMutablePointer.alloc(count)
    }
    
    required init(arrayLiteral elements: Element...) {
        self.pointer = UnsafeMutablePointer.alloc(elements.count)
        self.count = elements.count
        
        for (idx, element) in elements.enumerate() {
            (pointer + idx).memory = element
        }
    }
    
    deinit {
        pointer.dealloc(count)
    }
    
    private func toHex() -> String {
        var hex = String()
        for var idx = 0; idx < count; ++idx {
            hex += String(format:"%02x", (pointer + idx).memory)
        }
        return hex
    }
}

extension RawData: Indexable {
    typealias Index = Int
    
    var startIndex: Index {
        return 0
    }
    
    var endIndex: Index {
        // The collection's "past the end" position.
        return max(count,1)
    }
}

extension RawData: SequenceType {
    typealias Generator = AnyGenerator<Byte>
    
    func generate() -> Generator {
        var idx = 0
        return anyGenerator {
            let nextIdx = idx++
            
            
            if nextIdx > self.endIndex - 1 {
                return nil
            }
            
            return self[nextIdx]
        }
    }
}

extension RawData: MutableCollectionType, RangeReplaceableCollectionType {
    subscript (position: Index) -> Generator.Element {
        get {
            if position >= endIndex {
                fatalError("index out of range")
            }
            
            return (pointer + position).memory
        }
        set(newValue) {
            if position >= endIndex {
                fatalError("index out of range")
            }
            
            (pointer + position).memory = newValue
        }
    }
    
    func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Index>, with newElements: C) {
        var generator = newElements.generate()
        for var idx = subRange.startIndex; idx < subRange.endIndex - 1; idx++ {
            
            guard let nextElement = generator.next() else {
                break
            }
            
            (pointer + idx).memory = nextElement
        }
    }
}
