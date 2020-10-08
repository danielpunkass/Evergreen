//
//  SidebarToolbarModel.swift
//  NetNewsWire
//
//  Created by Stuart Breckenridge on 4/7/20.
//  Copyright © 2020 Ranchero Software. All rights reserved.
//

import Foundation

enum SidebarSheets {
	case none, web, twitter, reddit, folder, settings, fixCredentials
}

class SidebarToolbarModel: ObservableObject {
	
	@Published var showSheet: Bool = false
	@Published var sheetToShow: SidebarSheets = .none {
		didSet {
			sheetToShow != .none ? (showSheet = true) : (showSheet = false)
		}
	}
	@Published var showAddSheet: Bool = false
	
}
