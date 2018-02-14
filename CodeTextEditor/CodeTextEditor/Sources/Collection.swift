/*
 
 Collection.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-06-27.
 
 ------------------------------------------------------------------------------
 
 © 2016-2017 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Foundation

extension Array where Element: Equatable {
    
    /// Remove first collection element that is equal to the given `element`
    mutating func remove(_ element: Element) {
        
        if let index = index(of: element) {
            self.remove(at: index)
        }
    }
    
}


extension Collection {

    /// Return the element at the specified index only if it is within bounds, otherwise nil.
    public subscript(safe index: Index) -> Element? {
        
        return indices.contains(index) ? self[index] : nil
    }
    
}



extension Dictionary {
    
    /// Return a new dictionary containing the keys transformed by the given closure with the values of this dictionary.
    ///
    /// - Parameter transform: A closure that transforms a key. Every transformed key must be unique.
    /// - Returns: A dictionary containing transformed keys and the values of this dictionary.
    func mapKeys<T>(transform: (Key) throws -> T) rethrows -> [T: Value] {
        
        let keysWithValues = try self.map { (key, value) -> (T, Value) in
             (try transform(key), value)
        }
        
        return [T: Value](uniqueKeysWithValues: keysWithValues)
    }
    
}



extension Sequence {
    
    /// Build a dictionary from (key, value) tuple.
    func flatDictionary<K, V>(transform: ((Element) -> (K, V)?)) -> [K: V] {
        
        return [K: V](self.flatMap(transform), uniquingKeysWith: { $1 })
    }
    
}



// MARK: - Count

extension Sequence {
    
    /// Count up elements that satisfy the given predicate.
    ///
    /// - Parameters:
    ///    - predicate: A closure that takes an element of the sequence as its argument
    ///                 and returns a Boolean value indicating whether the element should be counted.
    /// - Returns: The number of elements that satisfies the given predicate.
    func count(_ predicate: (Element) -> Bool) -> Int {
        
        var count = 0
        for element in self where predicate(element) {
            count += 1
        }
        return count
    }
    
    
    /// Count up elements by enumerating collection until a element shows up that doesn't satisfy the given predicate.
    ///
    /// - Parameters:
    ///    - predicate: A closure that takes an element of the sequence as its argument
    ///                 and returns a Boolean value indicating whether the element should be counted.
    /// - Returns: The number of elements that satisfies the given predicate and are sequentially from the first index.
    func countPrefix(while predicate: (Element) -> Bool) -> Int {
        
        var count = 0
        for element in self {
            guard predicate(element) else { break }
            
            count += 1
        }
        return count
    }
    
}



// MARK: - IndexSet

extension Array {
    
    /// Remove elements with IndexSet
    mutating func remove(in indexes: IndexSet) {
        
        for index in indexes.reversed() {
            self.remove(at: index)
        }
    }
    
    
    /// Return subset at IndexSet
    func elements(at indexes: IndexSet) -> [Element] {
        
        return indexes.flatMap { index in
            guard index < self.count else { return nil }
            
            return self[index]
        }
    }
    
}
