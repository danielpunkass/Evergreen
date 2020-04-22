//
//  AccountMetadata.swift
//  Account
//
//  Created by Brent Simmons on 3/3/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import RSWeb

protocol AccountMetadataDelegate: class {
	func valueDidChange(_ accountMetadata: AccountMetadata, key: AccountMetadata.CodingKeys)
}

final class AccountMetadata: Codable {

	enum CodingKeys: String, CodingKey {
		case name
		case isActive
		case username
		case conditionalGetInfo
		case lastArticleFetchStartTime = "lastArticleFetch"
		case lastArticleFetchEndTime
		case endpointURL
		case externalID
		case lastCredentialRenewTime = "lastCredentialRenewTime"
		case performedApril2020RetentionPolicyChange
	}

	var name: String? {
		didSet {
			if name != oldValue {
				valueDidChange(.name)
			}
		}
	}
	
	var isActive: Bool = true {
		didSet {
			if isActive != oldValue {
				valueDidChange(.isActive)
			}
		}
	}
	
	var username: String? {
		didSet {
			if username != oldValue {
				valueDidChange(.username)
			}
		}
	}
	
	var conditionalGetInfo = [String: HTTPConditionalGetInfo]() {
		didSet {
			if conditionalGetInfo != oldValue {
				valueDidChange(.conditionalGetInfo)
			}
		}
	}
	
	var lastArticleFetchStartTime: Date? {
		didSet {
			if lastArticleFetchStartTime != oldValue {
				valueDidChange(.lastArticleFetchStartTime)
			}
		}
	}
	
	var lastArticleFetchEndTime: Date? {
		didSet {
			if lastArticleFetchEndTime != oldValue {
				valueDidChange(.lastArticleFetchEndTime)
			}
		}
	}
	
	var endpointURL: URL? {
		didSet {
			if endpointURL != oldValue {
				valueDidChange(.endpointURL)
			}
		}
	}
	
	/// The last moment an account successfully renewed its credentials, or `nil` if no such moment exists.
	/// An account delegate can use this value to decide when to next ask the service provider to renew credentials.
	var lastCredentialRenewTime: Date? {
		didSet {
			if lastCredentialRenewTime != oldValue {
				valueDidChange(.lastCredentialRenewTime)
			}
		}
	}

	var performedApril2020RetentionPolicyChange: Bool? {
		didSet {
			if performedApril2020RetentionPolicyChange != oldValue {
				valueDidChange(.performedApril2020RetentionPolicyChange)
			}
		}
	}

	var externalID: String? {
		didSet {
			if externalID != oldValue {
				valueDidChange(.externalID)
			}
		}
	}

	weak var delegate: AccountMetadataDelegate?
	
	func valueDidChange(_ key: CodingKeys) {
		delegate?.valueDidChange(self, key: key)
	}
}
