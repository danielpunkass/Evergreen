//
//  TimelineCellData.swift
//  NetNewsWire
//
//  Created by Brent Simmons on 2/6/16.
//  Copyright © 2016 Ranchero Software, LLC. All rights reserved.
//

import AppKit
import Articles

struct TimelineCellData {
	
	private static let noText = NSLocalizedString("(No Text)", comment: "No Text")
	
	let title: String
	let attributedTitle: NSAttributedString
	let text: String
	let dateString: String
	let feedName: String
	let byline: String
	let showFeedName: TimelineShowFeedName
	let iconImage: IconImage? // feed icon, user avatar, or favicon
	let showIcon: Bool // Make space even when icon is nil
	let featuredImage: NSImage? // image from within the article
	let read: Bool
	let starred: Bool

	init(article: Article, showFeedName: TimelineShowFeedName, feedName: String?, byline: String?, iconImage: IconImage?, showIcon: Bool, featuredImage: NSImage?) {

		self.title = ArticleStringFormatter.truncatedTitle(article)
		self.attributedTitle = ArticleStringFormatter.attributedTruncatedTitle(article)

		let truncatedSummary = ArticleStringFormatter.truncatedSummary(article)
		if self.title.isEmpty && truncatedSummary.isEmpty {
			self.text = Self.noText
		} else {
			self.text = truncatedSummary
		}
		
		self.dateString = ArticleStringFormatter.dateString(article.logicalDatePublished)

		if let feedName = feedName {
			self.feedName = ArticleStringFormatter.truncatedFeedName(feedName)
		} else {
			self.feedName = ""
		}
		
		if let byline = byline {
			self.byline = byline
		} else {
			self.byline = ""
		}

		self.showFeedName = showFeedName

		self.showIcon = showIcon
		self.iconImage = iconImage
		self.featuredImage = featuredImage
		
		self.read = article.status.read
		self.starred = article.status.starred
	}

	init() { //Empty
		self.title = ""
		self.text = ""
		self.dateString = ""
		self.feedName = ""
		self.byline = ""
		self.showFeedName = .none
		self.showIcon = false
		self.iconImage = nil
		self.featuredImage = nil
		self.read = true
		self.starred = false
		self.attributedTitle = NSAttributedString()
	}
}
