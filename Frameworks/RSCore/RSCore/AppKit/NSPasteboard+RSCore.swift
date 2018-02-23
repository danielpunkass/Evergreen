//
//  NSPasteboard+RSCore.swift
//  RSCore
//
//  Created by Brent Simmons on 2/11/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

import AppKit

public extension NSPasteboard {

	func copyObjects(_ objects: [Any]) {

		guard let writers = writersFor(objects) else {
			return
		}

		clearContents()
		writeObjects(writers)
	}

	func canCopyAtLeastOneObject(_ objects: [Any]) -> Bool {

		for object in objects {
			if object is PasteboardWriterOwner {
				return true
			}
		}
		return false
	}
}

private extension NSPasteboard {

	func writersFor(_ objects: [Any]) -> [NSPasteboardWriting]? {

		let writers = objects.compactMap { ($0 as? PasteboardWriterOwner)?.pasteboardWriter }
		return writers.isEmpty ? nil : writers
	}
}
