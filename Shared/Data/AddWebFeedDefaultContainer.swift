//
//  AddWebFeedDefaultContainer.swift
//  NetNewsWire-iOS
//
//  Created by Maurice Parker on 11/16/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import Foundation
import Account

struct AddWebFeedDefaultContainer {
	
	static var defaultContainer: Container? {
		
		if let accountID = AppDefaults.addWebFeedAccountID, let account = AccountManager.shared.activeAccounts.first(where: { $0.accountID == accountID }) {
			if let folderName = AppDefaults.addWebFeedFolderName, let folder = account.findFolder(withDisplayName: folderName) {
				return folder
			} else {
				return substituteContainerIfNeeded(account: account)
			}
		} else if let account = AccountManager.shared.sortedActiveAccounts.first {
			return substituteContainerIfNeeded(account: account)
		} else {
			return nil
		}
		
	}
	
	static func saveDefaultContainer(_ container: Container) {
		AppDefaults.addWebFeedAccountID = container.account?.accountID
		if let folder = container as? Folder {
			AppDefaults.addWebFeedFolderName = folder.nameForDisplay
		} else {
			AppDefaults.addWebFeedFolderName = nil
		}
	}
	
	private static func substituteContainerIfNeeded(account: Account) -> Container? {
		if !account.behaviors.contains(.disallowFeedInRootFolder) {
			return account
		} else {
			if let folder = account.sortedFolders?.first {
				return folder
			} else {
				return nil
			}
		}
	}
	
}
