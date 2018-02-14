/*
 
 AppInfo.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-06-23.
 
 ------------------------------------------------------------------------------
 
 © 2016-2017 1024jp
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

import Foundation


struct DocumentType {
    
    let UTType: String
    let extensions: [String]
    
    
    static let theme = DocumentType(UTType: "com.coteditor.CotEditor.theme", extensions: ["cottheme"])
}
