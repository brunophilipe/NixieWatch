//
//  InterfaceController.swift
//  NixieWatch WatchKit Extension
//
//  Created by Bruno Philipe on 05/03/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController
{
	@IBOutlet var imageView: WKInterfaceImage!
	private var use24h = NSUserDefaults.standardUserDefaults().boolForKey("User24hClock")
	
	var showingTime = false
	var waitingDoubleTap = false
	let watchRenderer = WatchFaceRenderer()
	
	override func awakeWithContext(context: AnyObject?)
	{
		super.awakeWithContext(context)
		
		// Configure interface objects here.
		let faceImage: UIImage = self.watchRenderer.renderAllOffFace()
		self.imageView.setImage(faceImage)
	}
	
	private func showTimeAnimation()
	{
		if showingTime
		{
			return
		}
		
		showingTime = true
		
		Wait.nsec(UInt64(500))
		{ () in
			let faceImage: UIImage = self.watchRenderer.renderHourFace(using24hClock: self.use24h)
			self.imageView.setImage(faceImage)
			
			Wait.sec(UInt64(1))
			{ () in
				let faceImage: UIImage = self.watchRenderer.renderMinuteFace()
				self.imageView.setImage(faceImage)
				
				Wait.sec(UInt64(1))
				{ () in
					let faceImage: UIImage = self.watchRenderer.renderAllOffFace()
					self.imageView.setImage(faceImage)
					self.showingTime = false
				}
			}
		}
	}
	
	override func willActivate()
	{
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()		
		showTimeAnimation()
	}
	
	override func didDeactivate()
	{
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	@IBAction func didTapScreen()
	{
		if waitingDoubleTap
		{
			toggle24hClock()
		}
		
		waitingDoubleTap = true
		Wait.nsec(300)
		{ () in
			self.waitingDoubleTap = false
			self.showTimeAnimation()
		}
	}
	
	private func toggle24hClock()
	{
		use24h = !use24h
		NSUserDefaults.standardUserDefaults().setBool(use24h, forKey: "User24hClock")
	}
}

class Wait
{
	static func nsec(time: UInt64, block: Void -> Void)
	{
		let when = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * time))
		dispatch_after(when, dispatch_get_main_queue(), block)
	}
	
	static func sec(time: UInt64, block: Void -> Void)
	{
		let when = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * time))
		dispatch_after(when, dispatch_get_main_queue(), block)
	}
}
