//
//  NSTextView+Snippet.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2017-12-29.
//
//  ---------------------------------------------------------------------------
//
//  © 2017 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

extension NSTextView {
    
    func insert(snippet: Snippet) {
        
        let range = self.rangeForUserTextChange
        
        guard self.shouldChangeText(in: range, replacementString: snippet.string) else { return }
        
        self.replaceCharacters(in: range, with: snippet.string)
        self.didChangeText()
        if let selection = snippet.selection {
            self.selectedRange = NSRange(location: range.location + selection.location, length: selection.length)
        }
        self.undoManager?.setActionName(NSLocalizedString("Insert Snippet", comment: "action name"))
    }
    
}
