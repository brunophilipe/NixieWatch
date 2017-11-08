//
//  InterfaceController.swift
//  NixieWatch WatchKit Extension
//
//  Created by Bruno Philipe on 05/03/16.
//  Copyright (C) 2016-2017 Bruno Philipe. All rights reserved.
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import WatchKit
import Foundation
import CoreGraphics

class InterfaceController: WKInterfaceController
{
	@IBOutlet var imageView: WKInterfaceImage!
	fileprivate var use24h = UserDefaults.standard.bool(forKey: "User24hClock")

	private let randomFacesQueue = DispatchQueue(label: "NixieWatch.RandomFaces", qos: .background, attributes: [],
	                                             autoreleaseFrequency: .workItem, target: nil)
	
	fileprivate var allOffCacheImage: UIImage? = nil
	fileprivate var hourCacheImage: UIImage? = nil
	fileprivate var hourCacheImageStamp: UInt8? = nil
	
	var showingTime = false
	var waitingDoubleTap = false
	let watchRenderer = WatchFaceRenderer()

	private var randomFaces: [UIImage] = []
	
	override func awake(withContext context: Any?)
	{
		super.awake(withContext: context)
		
		// Configure interface objects here.
		let faceImage: UIImage = self.watchRenderer.renderAllOffFace()
		self.imageView.setImage(faceImage)

		for _ in 0...8
		{
			randomFacesQueue.async
				{
					[weak self] in

					guard let renderer = self?.watchRenderer else
					{
						return
					}

					self?.randomFaces.append(renderer.renderRandomHourMinuteFace())
				}
		}
	}
	
	fileprivate func showTimeAnimation()
	{
		if showingTime
		{
			return
		}
		
		showingTime = true
		
		let components = Date().getFaceReadyTimeComponents(use24h)
		let hourStamp = UInt8(components.hour1 * 10 + components.hour2)
		
		var faceImage: UIImage!
		
		if hourStamp == hourCacheImageStamp && hourCacheImage != nil
		{
			faceImage = hourCacheImage
		}
		else
		{
			faceImage = self.watchRenderer.renderHourFace(components)
			
			hourCacheImageStamp = hourStamp
			hourCacheImage = faceImage
		}

		if randomFaces.count > 3, let animation = UIImage.animatedImage(with: randomFaces, duration: 0.2)
		{
			imageView.setImage(animation)
			imageView.startAnimating()

			Wait.msec(500)
			{
				self.imageView.setImage(faceImage)

				if self.allOffCacheImage == nil
				{
					self.allOffCacheImage = self.watchRenderer.renderAllOffFace()
				}

				Wait.msec(600)
				{
					self.imageView.setImage(self.allOffCacheImage)

					Wait.msec(50)
					{
						self.imageView.setImage(animation)
						self.imageView.startAnimating()

						Wait.msec(500)
						{
							let faceImage: UIImage = self.watchRenderer.renderMinuteFace(components)
							self.imageView.setImage(faceImage)

							Wait.msec(600)
							{
								self.imageView.setImage(self.allOffCacheImage)
								self.showingTime = false
							}
						}
					}
				}
			}
		}
		else
		{
			self.imageView.setImage(faceImage)

			if self.allOffCacheImage == nil
			{
				self.allOffCacheImage = self.watchRenderer.renderAllOffFace()
			}

			Wait.msec(600)
			{
				self.imageView.setImage(self.allOffCacheImage)

				Wait.msec(50)
				{
					let faceImage: UIImage = self.watchRenderer.renderMinuteFace(components)
					self.imageView.setImage(faceImage)

					Wait.msec(600)
					{
						self.imageView.setImage(self.allOffCacheImage)
						self.showingTime = false
					}
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
		Wait.msec(300)
		{ () in
			self.waitingDoubleTap = false
			self.showTimeAnimation()
		}
	}
	
	fileprivate func toggle24hClock()
	{
		use24h = !use24h
		UserDefaults.standard.set(use24h, forKey: "User24hClock")
	}
}

class Wait
{
	static func msec(_ time: UInt64, block: @escaping () -> Void)
	{
		let when = DispatchTime.now() + Double(Int64(NSEC_PER_MSEC * time)) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: when, execute: block)
	}
	
	static func sec(_ time: UInt64, block: @escaping () -> Void)
	{
		let when = DispatchTime.now() + Double(Int64(NSEC_PER_SEC * time)) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: when, execute: block)
	}
}
