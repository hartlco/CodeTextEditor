/*
 
 EditorScrollView.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2015-01-15.
 
 ------------------------------------------------------------------------------
 
 © 2015-2017 1024jp
 
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

final class EditorScrollView: NSScrollView {
    
    // MARK: Private Properties
    
    private var layoutOrientationObserver: NSKeyValueObservation?
    
    
    
    // MARK: -
    // MARK: Scroll View Methods
    
    /// use custom ruler view
    override class var rulerViewClass: AnyClass! {
        
        set {
            super.rulerViewClass = LineNumberView.self
        }
        get {
            return LineNumberView.self
        }
    }
    
    
    /// set text view
    override var documentView: NSView? {
        
        willSet {
            guard let documentView = newValue as? NSTextView else { return }
            
            self.layoutOrientationObserver = documentView.observe(\.layoutOrientation, options: .initial) { [unowned self] (textView, _) in
                switch textView.layoutOrientation {
                case .horizontal:
                    self.hasVerticalRuler = true
                    self.hasHorizontalRuler = false
                case .vertical:
                    self.hasVerticalRuler = false
                    self.hasHorizontalRuler = true
                }
                
                // invalidate line number view background
                self.window?.viewsNeedDisplay = true
            }
        }
    }
    
    
    
    // MARK: Public Methods
    
    func invalidateLineNumber() {
        
        self.lineNumberView?.needsDisplay = true
    }
    
    
    
    // MARK: Private Methods
    
    /// return layout orientation of document text view
    private var layoutOrientation: NSLayoutManager.TextLayoutOrientation {
        
        guard let documentView = self.documentView as? NSTextView else {
            return .horizontal
        }
        
        return documentView.layoutOrientation
    }
    
    
    /// return current line number view
    private var lineNumberView: NSRulerView? {
    
        switch self.layoutOrientation {
        case .horizontal:
            return self.verticalRulerView
            
        case .vertical:
            return self.horizontalRulerView
        }
    }
    
}
