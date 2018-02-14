/*
 
 EditorTextView+Transformation.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-01-10.
 
 ------------------------------------------------------------------------------
 
 © 2014-2017 1024jp
 
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

import Cocoa

extension EditorTextView {
    
    // MARK: Action Messages (Transformations)
    
    /// transform all full-width-available half-width characters in selection to full-width
    @IBAction func exchangeFullwidth(_ sender: Any?) {
        
        let actionName = NSLocalizedString("To Fullwidth", comment: "")
        self.transformSelection(actionName: actionName) {
            $0.applyingTransform(.fullwidthToHalfwidth, reverse: true) ?? $0
        }
    }
    
    
    /// transform all full-width characters in selection to half-width
    @IBAction func exchangeHalfwidth(_ sender: Any?) {
        
        let actionName = NSLocalizedString("To Halfwidth", comment: "")
        self.transformSelection(actionName: actionName) {
            $0.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? $0
        }
    }
    
    
    /// transform half-width roman characters in selection to full-width
    @IBAction func exchangeFullwidthRoman(_ sender: Any?) {
        
        let actionName = NSLocalizedString("To Fullwidth Roman", comment: "")
        self.transformSelection(actionName: actionName) {
            $0.fullWidthRoman
        }
    }
    
    
    /// transform full-width roman characters in selection to half-width
    @IBAction func exchangeHalfwidthRoman(_ sender: Any?) {
        
        let actionName = NSLocalizedString("To Halfwidth Roman", comment: "")
        self.transformSelection(actionName: actionName) {
            $0.halfWidthRoman
        }
    }
    
    
    /// transform Hiragana in selection to Katakana
    @IBAction func exchangeKatakana(_ sender: Any?) {
        
        let actionName = NSLocalizedString("Hiragana to Katakana", comment: "")
        self.transformSelection(actionName: actionName) {
            $0.applyingTransform(.hiraganaToKatakana, reverse: false) ?? $0
        }
    }
    
    
    /// transform Katakana in selection to Hiragana
    @IBAction func exchangeHiragana(_ sender: Any?) {
        
        let actionName = NSLocalizedString("Katakana to Hiragana", comment: "")
        self.transformSelection(actionName: actionName) {
            $0.applyingTransform(.hiraganaToKatakana, reverse: true) ?? $0
        }
    }
    
    
    
    // MARK: Action Messages (Unicode Normalizations)
    
    /// Unicode normalization (NFD)
    @IBAction func normalizeUnicodeWithNFD(_ sender: Any?) {
        
        self.transformSelection(actionName: "NFD") { $0.decomposedStringWithCanonicalMapping }
    }
    
    
    /// Unicode normalization (NFC)
    @IBAction func normalizeUnicodeWithNFC(_ sender: Any?) {
        
        self.transformSelection(actionName: "NFC") { $0.precomposedStringWithCanonicalMapping }
    }
    
    
    /// Unicode normalization (NFKD)
    @IBAction func normalizeUnicodeWithNFKD(_ sender: Any?) {
        
        self.transformSelection(actionName: "NFKD") { $0.decomposedStringWithCompatibilityMapping }
    }
    
    
    /// Unicode normalization (NFKC)
    @IBAction func normalizeUnicodeWithNFKC(_ sender: Any?) {
        
        self.transformSelection(actionName: "NFKC") { $0.precomposedStringWithCompatibilityMapping }
    }
    
    
    /// Unicode normalization (NFKC_Casefold)
    @IBAction func normalizeUnicodeWithNFKCCF(_ sender: Any?) {
        
        let actionName = NSLocalizedString("NFKC Casefold", comment: "name of an Uniocode normalization type")
        self.transformSelection(actionName: actionName) { $0.precomposedStringWithCompatibilityMappingWithCasefold }
    }
    
    
    /// Unicode normalization (Modified NFC)
    @IBAction func normalizeUnicodeWithModifiedNFC(_ sender: Any?) {
        
        let actionName = NSLocalizedString("Modified NFC", comment: "name of an Uniocode normalization type")
        self.transformSelection(actionName: actionName) { $0.precomposedStringWithHFSPlusMapping }
    }
    
    
    /// Unicode normalization (Modified NFD)
    @IBAction func normalizeUnicodeWithModifiedNFD(_ sender: Any?) {
        
        let actionName = NSLocalizedString("Modified NFD", comment: "name of an Uniocode normalization type")
        self.transformSelection(actionName: actionName) { $0.decomposedStringWithHFSPlusMapping }
    }
    
}



// MARK: Private NSTextView Extension

private extension NSTextView {
    
    /// transform all selected strings and register to undo manager
    func transformSelection(actionName: String? = nil, block: (String) -> String) {
        
        // transform word contains cursor if nothing is selected
        if self.selectedRange.length == 0 {
            self.selectWord(self)
        }
        
        let selectedRanges = self.selectedRanges as! [NSRange]
        var appliedRanges = [NSRange]()
        var strings = [String]()
        var newSelectedRanges = [NSRange]()
        var success = false
        var deltaLocation = 0
        
        for range in selectedRanges {
            guard range.length > 0 else { continue }
            guard let substring = (self.string as NSString?)?.substring(with: range) else { continue }
            
            let string = block(substring)
            
            let newRange = NSRange(location: range.location - deltaLocation, length: string.utf16.count)
            
            strings.append(string)
            appliedRanges.append(range)
            newSelectedRanges.append(newRange)
            deltaLocation += substring.utf16.count - string.utf16.count
            success = true
        }
        
        guard success else { return }
        
        self.replace(with: strings, ranges: appliedRanges, selectedRanges: newSelectedRanges, actionName: actionName)
        
        self.scrollRangeToVisible(self.selectedRange)
    }
    
}
