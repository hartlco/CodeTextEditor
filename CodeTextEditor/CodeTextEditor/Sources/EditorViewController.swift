/*
 
 EditorViewController.swift
 
 CotEditor
 https://coteditor.com
 
 Created by nakamuxu on 2006-03-18.
 
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
 © 2014-2017 1024jp
 Modifications copyright (C) 2018 Martin Hartl
 
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

public final class EditorViewController: NSSplitViewController {
    
    // MARK: Public Properties
    
    var textStorage: NSTextStorage? {
        
        didSet {
            guard let textStorage = textStorage else { return }
            
            self.textView?.layoutManager?.replaceTextStorage(textStorage)
        }
    }
    
    public var textView: EditorTextView? {
        
        return self.textViewController?.textView
    }
    
    var navigationBarController: NavigationBarController? {
        
        return self.navigationBarItem?.viewController as? NavigationBarController
    }

    var syntaxStyle: SyntaxStyle!
    
    // MARK: Private Properties
    
    @IBOutlet private weak var navigationBarItem: NSSplitViewItem?
    @IBOutlet private weak var textViewItem: NSSplitViewItem?
    
    
    
    // MARK: -
    // MARK: Split View Controller Methods
    
    /// setup UI
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationBarController?.textView = self.textView

        SyntaxManager.shared.loadUserSettings()
    }

    public func applySyntax(for filename: String) {
        guard let settingName = SyntaxManager.shared.settingName(documentFileName: filename),
            let style = SyntaxManager.shared.style(name: settingName) else { return }

        apply(syntax: style)
    }
    
    
    /// avoid showing draggable cursor
    override public func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        
        // -> must call super's delegate method anyway.
        super.splitView(splitView, effectiveRect: proposedEffectiveRect, forDrawnRect: drawnRect, ofDividerAt: dividerIndex)
        
        return .zero
    }
    
    
    /// validate actions
    override public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        
        guard let action = item.action else { return false }
        
        switch action {
        case #selector(selectPrevItemOfOutlineMenu):
            return self.navigationBarController?.canSelectPrevItem ?? false
            
        case #selector(selectNextItemOfOutlineMenu):
            return self.navigationBarController?.canSelectNextItem ?? false
            
        default: break
        }
        
        return super.validateUserInterfaceItem(item)
    }
    
    
    
    // MARK: Public Methods
    
    
    /// Whether navigation bar is visible
    var showsNavigationBar: Bool {
        
        get {
            return !(self.navigationBarItem?.isCollapsed ?? true)
        }
        set {
            self.navigationBarItem?.isCollapsed = !newValue
        }
    }
    
    
    /// apply syntax style to inner text view
    func apply(syntax: SyntaxStyle) {
        if syntax.canParse {
            self.syntaxStyle = syntax
            textView?.textStorage?.delegate = self
            syntax.delegate = self
            syntax.textStorage = textView?.textStorage
            syntax.invalidateOutline()
            self.textViewController?.syntaxStyle = syntax
            navigationBarController?.showOutlineIndicator()
        }
    }
    
    
    
    // MARK: Action Messages
    
    /// select previous outline menu item (bridge action from menu bar)
    @IBAction func selectPrevItemOfOutlineMenu(_ sender: Any?) {
        
        self.navigationBarController?.selectPrevItemOfOutlineMenu(sender)
    }
    
    
    /// select next outline menu item (bridge action from menu bar)
    @IBAction func selectNextItemOfOutlineMenu(_ sender: Any?) {
        
        self.navigationBarController?.selectNextItemOfOutlineMenu(sender)
    }
    
    
    
    // MARK: Private Methods
    
    /// split view item to view controller
    private var textViewController: EditorTextViewController? {
        
        return self.textViewItem?.viewController as? EditorTextViewController
    }
    
}

extension EditorViewController: SyntaxStyleDelegate {
    /// update outline menu in navigation bar
    func syntaxStyle(_ syntaxStyle: SyntaxStyle, didParseOutline outlineItems: [OutlineItem]) {
        navigationBarController?.outlineItems = outlineItems
    }
}

extension EditorViewController: NSTextStorageDelegate {
    /// text did edit
    override public func textStorageDidProcessEditing(_ notification: Notification) {

        // ignore if only attributes did change
        guard let textStorage = notification.object as? NSTextStorage,
            textStorage.editedMask.contains(.editedCharacters) else { return }

        // don't update when input text is not yet fixed.
        guard !(self.textView?.hasMarkedText() ?? false) else { return }


        // parse syntax
        self.syntaxStyle?.invalidateOutline()
        if let syntaxStyle = self.syntaxStyle, syntaxStyle.canParse {
            // perform highlight in the next run loop to give layoutManager time to update temporary attribute
            let editedRange = textStorage.editedRange
            DispatchQueue.main.async {
                syntaxStyle.highlight(around: editedRange)
            }
        }
    }
}
