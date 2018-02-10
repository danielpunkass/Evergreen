//
//  MainWindowController+Scriptability.swift
//  Evergreen
//
//  Created by Olof Hellman on 2/7/18.
//  Copyright © 2018 Ranchero Software. All rights reserved.
//

import Foundation
import Data

protocol ScriptingMainWindowController {
    var scriptingCurrentArticle: Article? { get }
    var scriptingSelectedArticles: [Article] { get }
}

