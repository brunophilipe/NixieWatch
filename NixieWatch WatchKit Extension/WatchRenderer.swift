//
//  WatchRenderer.swift
//  NixieWatch
//
//  Created by Bruno Philipe on 06/03/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

import WatchKit
import Foundation
import UIKit

let kDigitDot: Int8 = -1
let kDigitAllOff: Int8 = 99

typealias TimeComponents = (hour1: Int8, hour2: Int8, minute1: Int8, minute2: Int8)

class WatchFaceRenderer
{
	func renderHourFace(_ components: TimeComponents) -> UIImage
	{
		let currentDevice = WKInterfaceDevice.current()
		let screenWidth = currentDevice.screenBounds.width
		let digitScale: CGFloat = screenWidth > 155 ? 1.2 : 1.0
		let imageSize = CGSize(width: screenWidth, height: 100)
		
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		WatchFaceRenderer.drawDigit(components.hour1, posX: 0, digitScale: digitScale)
		WatchFaceRenderer.drawDigit(components.hour2, posX: 1, digitScale: digitScale)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage!
	}
	
	func renderMinuteFace(_ components: TimeComponents) -> UIImage
	{
		let currentDevice = WKInterfaceDevice.current()
		let screenWidth = currentDevice.screenBounds.width
		let digitScale: CGFloat = screenWidth > 155 ? 1.2 : 1.0
		let imageSize = CGSize(width: screenWidth, height: 100)
		
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		WatchFaceRenderer.drawDigit(components.minute1, posX: 0, digitScale: digitScale)
		WatchFaceRenderer.drawDigit(components.minute2, posX: 1, digitScale: digitScale)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage!
	}
	
	func renderAllOffFace() -> UIImage
	{
		let currentDevice = WKInterfaceDevice.current()
		let screenWidth = currentDevice.screenBounds.width
		let digitScale: CGFloat = screenWidth > 155 ? 1.2 : 1.0
		let imageSize = CGSize(width: screenWidth, height: 100)
		
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		WatchFaceRenderer.drawDigit(kDigitAllOff, posX: 0, digitScale: digitScale)
		WatchFaceRenderer.drawDigit(kDigitAllOff, posX: 1, digitScale: digitScale)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage!
	}
	
	func renderTimeFace(_ components: TimeComponents) -> UIImage
	{
		let currentDevice = WKInterfaceDevice.current()
		let screenWidth = currentDevice.screenBounds.width
		
		let imageSize = CGSize(width: screenWidth, height: 100)
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		WatchFaceRenderer.drawDigit(components.hour1, posX: 0)
		WatchFaceRenderer.drawDigit(components.hour2, posX: 1)
		WatchFaceRenderer.drawDigit(kDigitDot, posX: 1)
		WatchFaceRenderer.drawDigit(components.minute1, posX: 2)
		WatchFaceRenderer.drawDigit(components.minute2, posX: 3)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage!
	}
	
	func renderDateFace(using24hClock use24h: Bool) -> UIImage
	{
		let currentDevice = WKInterfaceDevice.current()
		let screenWidth = currentDevice.screenBounds.width
		
		let imageSize = CGSize(width: screenWidth, height: 90)
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		let components = Date().getFaceReadyDateComponents(use24h)
		
		WatchFaceRenderer.drawDigit(components.digit1, posX: 0)
		WatchFaceRenderer.drawDigit(components.digit2, posX: 1)
		WatchFaceRenderer.drawDigit(kDigitDot, posX: 1)
		WatchFaceRenderer.drawDigit(components.digit3, posX: 2)
		WatchFaceRenderer.drawDigit(components.digit4, posX: 3)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage!
	}
	
	static fileprivate func drawDigit(_ digit: Int8, posX: CGFloat, digitScale: CGFloat = 0.7)
	{
		//// General Declarations
		let context = UIGraphicsGetCurrentContext()
		
		//// Color Declarations
		let colorEnabled = UIColor(red: 0.910, green: 0.431, blue: 0.118, alpha: 1.000)
		let colorDisabled = UIColor(red: 0.279, green: 0.279, blue: 0.279, alpha: 0.1)
		
		//// Shadow Declarations
		let shadowEnabled = NSShadow(shadowOffset: CGSize(width: 0.1, height: -0.1), shadowBlurRadius: 16, shadowColor: colorEnabled)
		let shadowDisabled = NSShadow(shadowOffset: CGSize(width: 0, height: 0), shadowBlurRadius: 0, shadowColor: UIColor.black)
		
		//// Variable Declarations
		let scale: CGFloat = digitScale
		let posXPadded: CGFloat = ((posX * 49) + 0) * scale
		
		//// Group
		context?.saveGState()
		context?.translateBy(x: posXPadded, y: 0)
		context?.scaleBy(x: scale, y: scale)
		
		if digit == kDigitDot
		{
			// Renders dot
			renderDigit(digit, onContext: context, withColor: colorEnabled, andShadow: shadowEnabled)
		}
		else
		{
			// Renders each Nixie layer
			for i: Int8 in [1,0,2,9,3,4,8,5,7,6]
			{
				if i == digit
				{
					renderDigit(i, onContext: context, withColor: colorEnabled, andShadow: shadowEnabled)
				}
				else
				{
					renderDigit(i, onContext: context, withColor: colorDisabled, andShadow: shadowDisabled)
				}
			}
		}
		
		context?.restoreGState()
	}
	
	static fileprivate func renderDigit(_ digit: Int8, onContext context: CGContext?, withColor color: UIColor, andShadow shadow: NSShadow)
	{
		if digit == -1
		{
			//// Dot Drawing
			let dotPath = UIBezierPath(ovalIn: CGRect(x: 57.3, y: 60.2, width: 4.8, height: 5.1))
			color.setFill()
			dotPath.fill()
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			color.setStroke()
			dotPath.lineWidth = 3
			dotPath.stroke()
			context?.restoreGState()
		}
		else if digit == 1
		{
			//// Digit 1 Drawing
			let digit1Path = UIBezierPath()
			digit1Path.move(to: CGPoint(x: 35, y: 25.53))
			digit1Path.addLine(to: CGPoint(x: 42.41, y: 21.21))
			digit1Path.addLine(to: CGPoint(x: 42.41, y: 66.81))
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			color.setStroke()
			digit1Path.lineWidth = 2.9
			digit1Path.stroke()
			context?.restoreGState()
		}
		else if digit == 0
		{
			//// Digit 0 Drawing
			let digit0Path = UIBezierPath(ovalIn: CGRect(x: 26.05, y: 19.95, width: 29, height: 45.5))
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			color.setStroke()
			digit0Path.lineWidth = 3
			digit0Path.stroke()
			context?.restoreGState()
		}
		else if digit == 2
		{
			//// Digit 2
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			
			//// Bezier 9 Drawing
			let bezier9Path = UIBezierPath()
			bezier9Path.move(to: CGPoint(x: 28.35, y: 37.9))
			bezier9Path.addCurve(to: CGPoint(x: 36.73, y: 20.28), controlPoint1: CGPoint(x: 25.76, y: 30.74), controlPoint2: CGPoint(x: 29.52, y: 22.85))
			bezier9Path.addCurve(to: CGPoint(x: 54.47, y: 28.6), controlPoint1: CGPoint(x: 43.94, y: 17.71), controlPoint2: CGPoint(x: 51.89, y: 21.44))
			bezier9Path.addCurve(to: CGPoint(x: 51.3, y: 42.92), controlPoint1: CGPoint(x: 56.27, y: 33.59), controlPoint2: CGPoint(x: 55.04, y: 39.15))
			color.setStroke()
			bezier9Path.lineWidth = 3
			bezier9Path.stroke()
			
			
			//// Bezier 10 Drawing
			let bezier10Path = UIBezierPath()
			bezier10Path.move(to: CGPoint(x: 51.38, y: 42.84))
			bezier10Path.addLine(to: CGPoint(x: 30.19, y: 64.97))
			bezier10Path.addLine(to: CGPoint(x: 55.24, y: 64.97))
			color.setStroke()
			bezier10Path.lineWidth = 3
			bezier10Path.stroke()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
		}
		else if digit == 9
		{
			//// Digit 9
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			
			//// Oval 2 Drawing
			let oval2Path = UIBezierPath(ovalIn: CGRect(x: 27.8, y: 20.65, width: 28.3, height: 27.2))
			color.setStroke()
			oval2Path.lineWidth = 3
			oval2Path.stroke()
			
			
			//// Bezier 8 Drawing
			let bezier8Path = UIBezierPath()
			bezier8Path.move(to: CGPoint(x: 53.11, y: 42.59))
			bezier8Path.addLine(to: CGPoint(x: 34.41, y: 65.75))
			color.setStroke()
			bezier8Path.lineWidth = 3
			bezier8Path.stroke()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
		}
		else if digit == 3
		{
			//// Digit 3
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			
			//// Bezier 11 Drawing
			let bezier11Path = UIBezierPath()
			bezier11Path.move(to: CGPoint(x: 40.15, y: 41.59))
			bezier11Path.addCurve(to: CGPoint(x: 53.62, y: 53.08), controlPoint1: CGPoint(x: 47.33, y: 41.35), controlPoint2: CGPoint(x: 53.36, y: 46.5))
			bezier11Path.addCurve(to: CGPoint(x: 41.1, y: 65.44), controlPoint1: CGPoint(x: 53.88, y: 59.67), controlPoint2: CGPoint(x: 48.27, y: 65.2))
			bezier11Path.addCurve(to: CGPoint(x: 28.55, y: 57.94), controlPoint1: CGPoint(x: 35.61, y: 65.62), controlPoint2: CGPoint(x: 30.59, y: 62.62))
			color.setStroke()
			bezier11Path.lineWidth = 3
			bezier11Path.stroke()
			
			
			//// Bezier 12 Drawing
			let bezier12Path = UIBezierPath()
			bezier12Path.move(to: CGPoint(x: 40.36, y: 41.59))
			bezier12Path.addCurve(to: CGPoint(x: 52.31, y: 30.96), controlPoint1: CGPoint(x: 46.84, y: 41.69), controlPoint2: CGPoint(x: 52.2, y: 36.93))
			bezier12Path.addCurve(to: CGPoint(x: 40.77, y: 19.95), controlPoint1: CGPoint(x: 52.43, y: 24.98), controlPoint2: CGPoint(x: 47.26, y: 20.05))
			bezier12Path.addCurve(to: CGPoint(x: 29.65, y: 26.75), controlPoint1: CGPoint(x: 35.89, y: 19.87), controlPoint2: CGPoint(x: 31.46, y: 22.58))
			color.setStroke()
			bezier12Path.lineWidth = 3
			bezier12Path.stroke()
			
			
			//// Bezier 13 Drawing
			let bezier13Path = UIBezierPath()
			bezier13Path.move(to: CGPoint(x: 40.21, y: 41.59))
			bezier13Path.addLine(to: CGPoint(x: 36.88, y: 41.62))
			color.setStroke()
			bezier13Path.lineWidth = 3
			bezier13Path.stroke()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
		}
		else if digit == 4
		{
			
			//// Digit 4 Drawing
			let digit4Path = UIBezierPath()
			digit4Path.move(to: CGPoint(x: 47, y: 67))
			digit4Path.addLine(to: CGPoint(x: 47, y: 21.5))
			digit4Path.addLine(to: CGPoint(x: 27.99, y: 52.29))
			digit4Path.addLine(to: CGPoint(x: 56, y: 52.29))
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			color.setStroke()
			digit4Path.lineWidth = 3
			digit4Path.stroke()
			context?.restoreGState()
		}
		else if digit == 8
		{
			
			//// Digit 8
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			
			//// Oval 3 Drawing
			let oval3Path = UIBezierPath(ovalIn: CGRect(x: 28.1, y: 40.75, width: 26, height: 23.9))
			color.setStroke()
			oval3Path.lineWidth = 3
			oval3Path.stroke()
			
			
			//// Oval 4 Drawing
			let oval4Path = UIBezierPath(ovalIn: CGRect(x: 29.3, y: 19.1, width: 23.5, height: 21.7))
			color.setStroke()
			oval4Path.lineWidth = 3
			oval4Path.stroke()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
		}
		else if digit == 5
		{
			//// Digit 5
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			
			//// Bezier 2 Drawing
			let bezier2Path = UIBezierPath()
			bezier2Path.move(to: CGPoint(x: 32.55, y: 39.07))
			bezier2Path.addCurve(to: CGPoint(x: 51.61, y: 43.77), controlPoint1: CGPoint(x: 39.1, y: 35.06), controlPoint2: CGPoint(x: 47.63, y: 37.16))
			bezier2Path.addCurve(to: CGPoint(x: 46.95, y: 63.01), controlPoint1: CGPoint(x: 55.59, y: 50.39), controlPoint2: CGPoint(x: 53.5, y: 59))
			bezier2Path.addCurve(to: CGPoint(x: 28.21, y: 58.81), controlPoint1: CGPoint(x: 40.6, y: 66.91), controlPoint2: CGPoint(x: 32.33, y: 65.05))
			color.setStroke()
			bezier2Path.lineWidth = 3
			bezier2Path.stroke()
			
			
			//// Bezier 3 Drawing
			let bezier3Path = UIBezierPath()
			bezier3Path.move(to: CGPoint(x: 31.81, y: 40.37))
			bezier3Path.addLine(to: CGPoint(x: 31.81, y: 19.55))
			bezier3Path.addLine(to: CGPoint(x: 49.84, y: 19.63))
			color.setStroke()
			bezier3Path.lineWidth = 3
			bezier3Path.stroke()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
		}
		else if digit == 7
		{
			
			//// Digit 7
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			
			//// Bezier 5 Drawing
			let bezier5Path = UIBezierPath()
			bezier5Path.move(to: CGPoint(x: 28.06, y: 20.06))
			bezier5Path.addLine(to: CGPoint(x: 55.12, y: 20.06))
			bezier5Path.addLine(to: CGPoint(x: 38, y: 65.57))
			bezier5Path.addLine(to: CGPoint(x: 36.95, y: 65.57))
			color.setStroke()
			bezier5Path.lineWidth = 3
			bezier5Path.stroke()
			
			
			//// Group 3
			context?.saveGState()
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			//// Clip Clip
			let clipPath = UIBezierPath()
			clipPath.move(to: CGPoint(x: 36.84, y: 64.53))
			clipPath.addLine(to: CGPoint(x: 35.89, y: 67.01))
			clipPath.addLine(to: CGPoint(x: 37.39, y: 67.01))
			clipPath.addLine(to: CGPoint(x: 36.84, y: 64.53))
			clipPath.close()
			clipPath.usesEvenOddFillRule = true;
			
			clipPath.addClip()
			
			
			//// Rectangle Drawing
			let rectanglePath = UIBezierPath(rect: CGRect(x: 30.9, y: 59.5, width: 11.5, height: 12.5))
			color.setFill()
			rectanglePath.fill()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
			
			
			//// Bezier 7 Drawing
			let bezier7Path = UIBezierPath()
			bezier7Path.move(to: CGPoint(x: 37.15, y: 64.3))
			bezier7Path.addLine(to: CGPoint(x: 36.2, y: 66.78))
			bezier7Path.addLine(to: CGPoint(x: 37.71, y: 66.78))
			bezier7Path.addLine(to: CGPoint(x: 37.15, y: 64.3))
			bezier7Path.close()
			color.setStroke()
			bezier7Path.lineWidth = 0.5
			bezier7Path.stroke()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
		}
		else if digit == 6
		{
			//// Digit 6
			context?.saveGState()
			context?.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadow.shadowColor.cgColor)
			context?.beginTransparencyLayer(auxiliaryInfo: nil)
			
			
			//// Oval Drawing
			let ovalPath = UIBezierPath(ovalIn: CGRect(x: 28.05, y: 38.45, width: 28.3, height: 27.5))
			color.setStroke()
			ovalPath.lineWidth = 3
			ovalPath.stroke()
			
			
			//// Bezier 4 Drawing
			let bezier4Path = UIBezierPath()
			bezier4Path.move(to: CGPoint(x: 31.03, y: 43.77))
			bezier4Path.addLine(to: CGPoint(x: 49.72, y: 20.38))
			color.setStroke()
			bezier4Path.lineWidth = 3
			bezier4Path.stroke()
			
			
			context?.endTransparencyLayer()
			context?.restoreGState()
		}
	}
}

internal extension Date
{
	func getTimeComponents() -> (hours: Int, minutes: Int, seconds: Int)
	{
		let calendar = Calendar.autoupdatingCurrent
		let unitFlags: NSCalendar.Unit = [.hour, .minute, .second]
		let components = (calendar as NSCalendar).components(unitFlags, from: self)
		return (components.hour!, components.minute!, components.second!)
	}
	
	func getDateComponents() -> (day: Int, month: Int, year: Int)
	{
		let calendar = Calendar.autoupdatingCurrent
		let unitFlags: NSCalendar.Unit = [.day, .month, .year]
		let components = (calendar as NSCalendar).components(unitFlags, from: self)
		return (components.day!, components.month!, components.year!)
	}
	
	func getFaceReadyTimeComponents(_ use24h: Bool) -> TimeComponents
	{
		let components = self.getTimeComponents()
		var hours = use24h ? components.hours : components.hours%12
		
		if !use24h && hours == 0
		{
			hours = 12
		}
		
		return (Int8(hours/10),
				Int8(hours%10),
				Int8(components.minutes/10),
				Int8(components.minutes%10))
	}
	
	func getFaceReadyDateComponents(_ use24h: Bool) -> (digit1: Int8, digit2: Int8, digit3: Int8, digit4: Int8)
	{
		let components = self.getDateComponents()
		
		if use24h
		{
			return (Int8(components.day/10),
					Int8(components.day%10),
					Int8(components.month/10),
					Int8(components.month%10))
		}
		else
		{
			return (Int8(components.month/10),
					Int8(components.month%10),
					Int8(components.day/10),
					Int8(components.day%10))
		}
	}
}

private struct NSShadow
{
	var shadowOffset: CGSize
	var shadowBlurRadius: CGFloat
	var shadowColor: UIColor
}
