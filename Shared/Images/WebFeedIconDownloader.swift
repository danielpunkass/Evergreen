//
//  FeedIconDownloader.swift
//  NetNewsWire
//
//  Created by Brent Simmons on 11/26/17.
//  Copyright © 2017 Ranchero Software. All rights reserved.
//

import Foundation
import Articles
import Account
import RSCore
import RSWeb
import RSParser

extension Notification.Name {

	static let WebFeedIconDidBecomeAvailable = Notification.Name("WebFeedIconDidBecomeAvailableNotification") // UserInfoKey.feed
}

public final class WebFeedIconDownloader {

	private static let saveQueue = CoalescingQueue(name: "Cache Save Queue", interval: 1.0)

	private let imageDownloader: ImageDownloader

	private var homePageToIconURLCache = [String: String]()
	private var homePageToIconURLCachePath: String
	private var homePageToIconURLCacheDirty = false {
		didSet {
			queueSaveHomePageToIconURLCacheIfNeeded()
		}
	}
	
	private var homePagesWithNoIconURLCache = Set<String>()
	private var homePagesWithNoIconURLCachePath: String
	private var homePagesWithNoIconURLCacheDirty = false {
		didSet {
			queueHomePagesWithNoIconURLCacheIfNeeded()
		}
	}

	private var homePagesWithUglyIcons: Set<String> = {
		return Set(["https://www.macsparky.com/"])
	}()
	
	private var urlsInProgress = Set<String>()
	private var cache = [WebFeed: IconImage]()
	private var waitingForFeedURLs = [String: WebFeed]()

	init(imageDownloader: ImageDownloader, folder: String) {
		self.imageDownloader = imageDownloader
		self.homePageToIconURLCachePath = (folder as NSString).appendingPathComponent("HomePageToIconURLCache.plist")
		self.homePagesWithNoIconURLCachePath = (folder as NSString).appendingPathComponent("HomePagesWithNoIconURLCache.plist")
		loadHomePageToIconURLCache()
		loadHomePagesWithNoIconURLCache()
		NotificationCenter.default.addObserver(self, selector: #selector(imageDidBecomeAvailable(_:)), name: .ImageDidBecomeAvailable, object: imageDownloader)
	}

	func resetCache() {
		cache = [WebFeed: IconImage]()
	}

	func icon(for feed: WebFeed) -> IconImage? {

		if let cachedImage = cache[feed] {
			return cachedImage
		}
		
		func checkHomePageURL() {
			guard let homePageURL = feed.homePageURL else {
				return
			}
			icon(forHomePageURL: homePageURL, feed: feed) { (image) in
				if let image = image {
					self.postFeedIconDidBecomeAvailableNotification(feed)
					self.cache[feed] = IconImage(image)
				}
			}
		}

		if let iconURL = feed.iconURL {
			icon(forURL: iconURL, feed: feed) { (image) in
				if let image = image {
					self.postFeedIconDidBecomeAvailableNotification(feed)
					self.cache[feed] = IconImage(image)
				}
				else {
					checkHomePageURL()
				}
			}
		}
		else {
			checkHomePageURL()
		}


		return nil
	}

	@objc func imageDidBecomeAvailable(_ note: Notification) {
		guard let url = note.userInfo?[UserInfoKey.url] as? String, let feed = waitingForFeedURLs[url]  else {
			return
		}
		waitingForFeedURLs[url] = nil
		_ = icon(for: feed)
	}
	
	@objc func saveHomePageToIconURLCacheIfNeeded() {
		if homePageToIconURLCacheDirty {
			saveHomePageToIconURLCache()
		}
	}
	
	@objc func saveHomePagesWithNoIconURLCacheIfNeeded() {
		if homePagesWithNoIconURLCacheDirty {
			saveHomePagesWithNoIconURLCache()
		}
	}
	
}

private extension WebFeedIconDownloader {

	func icon(forHomePageURL homePageURL: String, feed: WebFeed, _ imageResultBlock: @escaping (RSImage?) -> Void) {

		if homePagesWithNoIconURLCache.contains(homePageURL) || homePagesWithUglyIcons.contains(homePageURL) {
			imageResultBlock(nil)
			return
		}

		if let iconURL = cachedIconURL(for: homePageURL) {
			icon(forURL: iconURL, feed: feed, imageResultBlock)
			return
		}

		findIconURLForHomePageURL(homePageURL, feed: feed)
	}

	func icon(forURL url: String, feed: WebFeed, _ imageResultBlock: @escaping (RSImage?) -> Void) {
		waitingForFeedURLs[url] = feed
		guard let imageData = imageDownloader.image(for: url) else {
			imageResultBlock(nil)
			return
		}
		RSImage.scaledForIcon(imageData, imageResultBlock: imageResultBlock)
	}

	func postFeedIconDidBecomeAvailableNotification(_ feed: WebFeed) {

		DispatchQueue.main.async {
			let userInfo: [AnyHashable: Any] = [UserInfoKey.webFeed: feed]
			NotificationCenter.default.post(name: .WebFeedIconDidBecomeAvailable, object: self, userInfo: userInfo)
		}
	}

	func cachedIconURL(for homePageURL: String) -> String? {

		return homePageToIconURLCache[homePageURL]
	}

	func cacheIconURL(for homePageURL: String, _ iconURL: String) {
		homePagesWithNoIconURLCache.remove(homePageURL)
		homePagesWithNoIconURLCacheDirty = true
		homePageToIconURLCache[homePageURL] = iconURL
		homePageToIconURLCacheDirty = true
	}

	func findIconURLForHomePageURL(_ homePageURL: String, feed: WebFeed) {

		guard !urlsInProgress.contains(homePageURL) else {
			return
		}
		urlsInProgress.insert(homePageURL)

		HTMLMetadataDownloader.downloadMetadata(for: homePageURL) { (metadata) in

			self.urlsInProgress.remove(homePageURL)
			guard let metadata = metadata else {
				return
			}
			self.pullIconURL(from: metadata, homePageURL: homePageURL, feed: feed)
		}
	}

	func pullIconURL(from metadata: RSHTMLMetadata, homePageURL: String, feed: WebFeed) {

		if let url = metadata.bestWebsiteIconURL() {
			cacheIconURL(for: homePageURL, url)
			icon(forURL: url, feed: feed) { (image) in
			}
			return
		}

		homePagesWithNoIconURLCache.insert(homePageURL)
		homePagesWithNoIconURLCacheDirty = true
	}
	
	func loadHomePageToIconURLCache() {
		let url = URL(fileURLWithPath: homePageToIconURLCachePath)
		guard let data = try? Data(contentsOf: url) else {
			return
		}
		let decoder = PropertyListDecoder()
		homePageToIconURLCache = (try? decoder.decode([String: String].self, from: data)) ?? [String: String]()
	}

	func loadHomePagesWithNoIconURLCache() {
		let url = URL(fileURLWithPath: homePagesWithNoIconURLCachePath)
		guard let data = try? Data(contentsOf: url) else {
			return
		}
		let decoder = PropertyListDecoder()
		let decoded = (try? decoder.decode([String].self, from: data)) ?? [String]()
		homePagesWithNoIconURLCache = Set(decoded)
	}

	func queueSaveHomePageToIconURLCacheIfNeeded() {
		WebFeedIconDownloader.saveQueue.add(self, #selector(saveHomePageToIconURLCacheIfNeeded))
	}

	func queueHomePagesWithNoIconURLCacheIfNeeded() {
		WebFeedIconDownloader.saveQueue.add(self, #selector(saveHomePagesWithNoIconURLCacheIfNeeded))
	}

	func saveHomePageToIconURLCache() {
		homePageToIconURLCacheDirty = false

		let encoder = PropertyListEncoder()
		encoder.outputFormat = .binary
		let url = URL(fileURLWithPath: homePageToIconURLCachePath)
		do {
			let data = try encoder.encode(homePageToIconURLCache)
			try data.write(to: url)
		} catch {
			assertionFailure(error.localizedDescription)
		}
	}
	
	func saveHomePagesWithNoIconURLCache() {
		homePagesWithNoIconURLCacheDirty = false

		let encoder = PropertyListEncoder()
		encoder.outputFormat = .binary
		let url = URL(fileURLWithPath: homePagesWithNoIconURLCachePath)
		do {
			let data = try encoder.encode(Array(homePagesWithNoIconURLCache))
			try data.write(to: url)
		} catch {
			assertionFailure(error.localizedDescription)
		}
	}
	
}
