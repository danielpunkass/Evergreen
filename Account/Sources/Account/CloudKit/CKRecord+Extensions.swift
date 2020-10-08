//
//  CKRecord+Extensions.swift
//  Account
//
//  Created by Maurice Parker on 3/29/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
	
	var externalID: String {
		return recordID.externalID
	}
	
}

extension CKRecord.ID {
	
	var externalID: String {
		return recordName
	}
	
}
