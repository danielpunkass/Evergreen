//
//  IntentHandler.swift
//  NetNewsWire iOS Intents Extension
//
//  Created by Maurice Parker on 10/18/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
	override func handler(for intent: INIntent) -> Any {
		switch intent {
		case is AddFeedIntent:
			return AddFeedIntentHandler()
		default:
			fatalError("Unhandled intent type: \(intent)")
		}
	}
    
}
