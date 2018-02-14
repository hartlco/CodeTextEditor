/*
 
 FilePermissionsFormatter.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-06-02.
 
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

final class FilePermissionsFormatter: Formatter {
    
    // MARK: Formatter Function
    
    /// format permission number to human readable permission expression
    override func string(for obj: Any?) -> String? {
        
        guard let permission = obj as? UInt else { return nil }
        
        return String(format: "%lo (%@)", permission, humanReadable(permission: permission))
    }
    
    
    /// disable backwards formatting
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        return false
    }
    
}



// MARK: - Private Function

/// create human-readable permission expression from integer
private func humanReadable(permission: UInt) -> String {
    
    let units = ["---", "--x", "-w-", "-wx", "r--", "r-x", "rw-", "rwx"]
    
    return (0...2).reversed()
        .map { (index: Int) -> Int in (Int(permission) >> (index * 3)) & 0x7 }
        .reduce("-") { $0 + units[$1] }  // document is always file.
}
