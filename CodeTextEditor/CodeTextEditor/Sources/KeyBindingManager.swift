/*
 
 KeyBindingManager.swift
 
 CotEditor
 https://coteditor.com
 
 Created by nakamuxu on 2005-09-01.
 
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
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

struct InvalidKeySpecCharactersError: LocalizedError {
    
    enum ErrorKind {
        case singleType
        case alreadyTaken
        case lackingCommandKey
        case unwantedCommandKey
    }
    
    let kind: ErrorKind
    let shortcut: Shortcut
    
    
    var errorDescription: String? {
        
        switch self.kind {
        case .singleType:
            return NSLocalizedString("Single type is invalid for a shortcut.", comment: "")
            
        case .alreadyTaken:
            return String(format: NSLocalizedString("“%@” is already taken.", comment: ""), self.shortcut.description)
            
        case .lackingCommandKey:
            return String(format: NSLocalizedString("“%@” does not include the Command key.", comment: ""), self.shortcut.description)
            
        case .unwantedCommandKey:
            return String(format: NSLocalizedString("“%@” includes the Command key.", comment: ""), self.shortcut.description)
        }
    }
    
    
    var recoverySuggestion: String? {
        
        return NSLocalizedString("Please combine with another keys.", comment: "")
    }
    
}



// MARK: -

protocol KeyBindingManagerProtocol: class {
    
    var settingFileName: String { get }
    var keyBindings: Set<KeyBinding> { get }
    var defaultKeyBindings: Set<KeyBinding> { get }
    
    func outlineTree(defaults usesDefaults: Bool) -> [NSTreeNode]
}



class KeyBindingManager: SettingManager, KeyBindingManagerProtocol {
    
    // MARK: Public Properties
    
    private(set) lazy var keyBindings: Set<KeyBinding> = {
        
        guard
            let data = try? Data(contentsOf: self.keyBindingSettingFileURL),
            let customKeyBindings = try? PropertyListDecoder().decode([KeyBinding].self, from: data)
            else {
                return self.defaultKeyBindings
        }
        
        let sortedKeyBindings = Set(customKeyBindings.filter({ $0.shortcut?.isValid ?? true })).sorted()
        let customizedActions = sortedKeyBindings.map { $0.action }
        let customizedShortcuts = sortedKeyBindings.flatMap { $0.shortcut }
        let defaultKeyBindings = self.defaultKeyBindings
            .filter { !customizedActions.contains($0.action) && !customizedShortcuts.contains($0.shortcut!) }
        
        let keyBindings = (defaultKeyBindings + sortedKeyBindings).filter { $0.shortcut != nil }
        
        return Set(keyBindings)
    }()
    
    
    
    // MARK: Setting Manager Methods
    
    /// directory name in both Application Support and bundled Resources
    override var directoryName: String {
        
        return "KeyBindings"
    }
    
    
    
    // MARK: Abstract Properties/Methods
    
    /// name of file to save custom key bindings in the plist file form (without extension)
    var settingFileName: String { preconditionFailure() }
    
    /// default key bindings
    var defaultKeyBindings: Set<KeyBinding> { preconditionFailure() }
    
    
    /// create a KVO-compatible collection for outlineView in preferences from the key binding setting
    /// - parameter usesDefaults:   `true` for default setting and `false` for the current setting
    func outlineTree(defaults usesDefaults: Bool) -> [NSTreeNode] { preconditionFailure() }
    
    
    
    // MARK: Public Methods
    
    /// file URL to save custom key bindings file
    var keyBindingSettingFileURL: URL {
        
        return self.userSettingDirectoryURL.appendingPathComponent(self.settingFileName).appendingPathExtension("plist")
    }
    
    
    /// whether key bindings are not customized
    var usesDefaultKeyBindings: Bool {
        
        return self.keyBindings == self.defaultKeyBindings
    }
    
    
    /// save passed-in key binding settings
    func saveKeyBindings(outlineTree: [NSTreeNode]) throws {
        
        // create directory to save in user domain if not yet exist
        try self.prepareUserSettingDirectory()
        
        let keyBindings = self.keyBindings(from: outlineTree)
        let fileURL = self.keyBindingSettingFileURL
        
        let defaultExistsAction = self.defaultKeyBindings.map { $0.action }
        let diff = keyBindings.subtracting(self.defaultKeyBindings)
            .filter { $0.shortcut != nil || defaultExistsAction.contains($0.action) }
        
        // write to file
        if diff.isEmpty {
            // just remove setting file if the new setting is exactly the same as the default
            if fileURL.isReachable {
                try FileManager.default.removeItem(at: fileURL)
            }
        } else {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(diff.sorted())
            try data.write(to: fileURL, options: .atomic)
        }
        
        // store new values
        self.keyBindings = Set(keyBindings.filter { $0.shortcut != nil })
    }
    
    
    /// validate new key spec chars are settable
    /// - throws: InvalidKeySpecCharactersError
    func validate(shortcut: Shortcut, oldShortcut: Shortcut?) throws {
        
        // blank key is always valid
        if shortcut.isEmpty { return }
        
        // single key is invalid
        guard !shortcut.modifierMask.isEmpty && !shortcut.keyEquivalent.isEmpty else {
            throw InvalidKeySpecCharactersError(kind: .singleType, shortcut: shortcut)
        }
        
        // duplication check
        guard shortcut == oldShortcut || !self.keyBindings.contains(where: { $0.shortcut == shortcut }) else {
            throw InvalidKeySpecCharactersError(kind: .alreadyTaken, shortcut: shortcut)
        }
    }
    
    
    
    // MARK: Private Methods
    
    /// create a plist-compatible collection to save from outlineView data
    private func keyBindings(from outlineTree: [NSTreeNode]) -> Set<KeyBinding> {
        
        let keyBindings: [KeyBinding] = outlineTree
            .map { node -> [KeyBinding] in
                if let children = node.children, !children.isEmpty {
                    return self.keyBindings(from: children).sorted()
                }
                
                guard
                    let keyItem = node.representedObject as? KeyBindingItem,
                    let shortcut = keyItem.shortcut
                    else { return [] }
                
                return [KeyBinding(action: keyItem.action, shortcut: shortcut.isValid ? shortcut : nil)]
            }
            .flatMap { $0 }
        
        return Set(keyBindings)
    }
    
}
