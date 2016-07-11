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

class WatchFaceRenderer
{
	func renderHourFace(using24hClock use24h: Bool) -> UIImage
	{
		let currentDevice = WKInterfaceDevice.currentDevice()
		let screenWidth = currentDevice.screenBounds.width
		let digitScale: CGFloat = screenWidth > 155 ? 1.2 : 1.0
		let imageSize = CGSizeMake(screenWidth, 100)
		
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		let components = NSDate().getFaceReadyTimeComponents(use24h)
		
		WatchFaceRenderer.drawDigit(components.hour1, posX: 0, digitScale: digitScale)
		WatchFaceRenderer.drawDigit(components.hour2, posX: 1, digitScale: digitScale)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage
	}
	
	func renderMinuteFace() -> UIImage
	{
		let currentDevice = WKInterfaceDevice.currentDevice()
		let screenWidth = currentDevice.screenBounds.width
		let digitScale: CGFloat = screenWidth > 155 ? 1.2 : 1.0
		let imageSize = CGSizeMake(screenWidth, 100)
		
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		let components = NSDate().getFaceReadyTimeComponents(true)
		
		WatchFaceRenderer.drawDigit(components.minute1, posX: 0, digitScale: digitScale)
		WatchFaceRenderer.drawDigit(components.minute2, posX: 1, digitScale: digitScale)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage
	}
	
	func renderAllOffFace() -> UIImage
	{
		let currentDevice = WKInterfaceDevice.currentDevice()
		let screenWidth = currentDevice.screenBounds.width
		
		let imageSize = CGSizeMake(screenWidth, 100)
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		WatchFaceRenderer.drawDigit(kDigitAllOff, posX: 0, digitScale: 1.2)
		WatchFaceRenderer.drawDigit(kDigitAllOff, posX: 1, digitScale: 1.2)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage
	}
	
	func renderTimeFace(using24hClock use24h: Bool) -> UIImage
	{
		let currentDevice = WKInterfaceDevice.currentDevice()
		let screenWidth = currentDevice.screenBounds.width
		
		let imageSize = CGSizeMake(screenWidth, 100)
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		let components = NSDate().getFaceReadyTimeComponents(use24h)
		
		WatchFaceRenderer.drawDigit(components.hour1, posX: 0)
		WatchFaceRenderer.drawDigit(components.hour2, posX: 1)
		WatchFaceRenderer.drawDigit(kDigitDot, posX: 1)
		WatchFaceRenderer.drawDigit(components.minute1, posX: 2)
		WatchFaceRenderer.drawDigit(components.minute2, posX: 3)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage
	}
	
	func renderDateFace(using24hClock use24h: Bool) -> UIImage
	{
		let currentDevice = WKInterfaceDevice.currentDevice()
		let screenWidth = currentDevice.screenBounds.width
		
		let imageSize = CGSizeMake(screenWidth, 90)
		UIGraphicsBeginImageContextWithOptions(imageSize, true, 2.0)
		
		let components = NSDate().getFaceReadyDateComponents(use24h)
		
		WatchFaceRenderer.drawDigit(components.digit1, posX: 0)
		WatchFaceRenderer.drawDigit(components.digit2, posX: 1)
		WatchFaceRenderer.drawDigit(kDigitDot, posX: 1)
		WatchFaceRenderer.drawDigit(components.digit3, posX: 2)
		WatchFaceRenderer.drawDigit(components.digit4, posX: 3)
		
		let faceImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return faceImage
	}
	
	static private func drawDigit(digit: Int8, posX: CGFloat, digitScale: CGFloat = 0.7)
	{
		//// General Declarations
		let context = UIGraphicsGetCurrentContext()
		
		//// Color Declarations
		let colorEnabled = UIColor(red: 0.910, green: 0.431, blue: 0.118, alpha: 1.000)
		let colorDisabled = UIColor(red: 0.279, green: 0.279, blue: 0.279, alpha: 0.1)
		
		//// Shadow Declarations
		let shadowEnabled = NSShadow(shadowOffset: CGSizeMake(0.1, -0.1), shadowBlurRadius: 8, shadowColor: colorEnabled)
		let shadowDisabled = NSShadow(shadowOffset: CGSizeMake(0, 0), shadowBlurRadius: 0, shadowColor: UIColor.blackColor())
		
		//// Variable Declarations
		let scale: CGFloat = digitScale
		let posXPadded: CGFloat = ((posX * 49) + 0) * scale
		
		//// Group
		CGContextSaveGState(context)
		CGContextTranslateCTM(context, posXPadded, 0)
		CGContextScaleCTM(context, scale, scale)
		
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
		
		CGContextRestoreGState(context)
	}
	
	static private func renderDigit(digit: Int8, onContext context: CGContextRef?, withColor color: UIColor, andShadow shadow: NSShadow)
	{
		if digit == -1
		{
			//// Dot Drawing
			let dotPath = UIBezierPath(ovalInRect: CGRectMake(57.3, 60.2, 4.8, 5.1))
			color.setFill()
			dotPath.fill()
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			color.setStroke()
			dotPath.lineWidth = 3
			dotPath.stroke()
			CGContextRestoreGState(context)
		}
		else if digit == 1
		{
			//// Digit 1 Drawing
			let digit1Path = UIBezierPath()
			digit1Path.moveToPoint(CGPointMake(35, 25.53))
			digit1Path.addLineToPoint(CGPointMake(42.41, 21.21))
			digit1Path.addLineToPoint(CGPointMake(42.41, 66.81))
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			color.setStroke()
			digit1Path.lineWidth = 2.9
			digit1Path.stroke()
			CGContextRestoreGState(context)
		}
		else if digit == 0
		{
			//// Digit 0 Drawing
			let digit0Path = UIBezierPath(ovalInRect: CGRectMake(26.05, 19.95, 29, 45.5))
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			color.setStroke()
			digit0Path.lineWidth = 3
			digit0Path.stroke()
			CGContextRestoreGState(context)
		}
		else if digit == 2
		{
			//// Digit 2
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			CGContextBeginTransparencyLayer(context, nil)
			
			
			//// Bezier 9 Drawing
			let bezier9Path = UIBezierPath()
			bezier9Path.moveToPoint(CGPointMake(28.35, 37.9))
			bezier9Path.addCurveToPoint(CGPointMake(36.73, 20.28), controlPoint1: CGPointMake(25.76, 30.74), controlPoint2: CGPointMake(29.52, 22.85))
			bezier9Path.addCurveToPoint(CGPointMake(54.47, 28.6), controlPoint1: CGPointMake(43.94, 17.71), controlPoint2: CGPointMake(51.89, 21.44))
			bezier9Path.addCurveToPoint(CGPointMake(51.3, 42.92), controlPoint1: CGPointMake(56.27, 33.59), controlPoint2: CGPointMake(55.04, 39.15))
			color.setStroke()
			bezier9Path.lineWidth = 3
			bezier9Path.stroke()
			
			
			//// Bezier 10 Drawing
			let bezier10Path = UIBezierPath()
			bezier10Path.moveToPoint(CGPointMake(51.38, 42.84))
			bezier10Path.addLineToPoint(CGPointMake(30.19, 64.97))
			bezier10Path.addLineToPoint(CGPointMake(55.24, 64.97))
			color.setStroke()
			bezier10Path.lineWidth = 3
			bezier10Path.stroke()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
		}
		else if digit == 9
		{
			//// Digit 9
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			CGContextBeginTransparencyLayer(context, nil)
			
			
			//// Oval 2 Drawing
			let oval2Path = UIBezierPath(ovalInRect: CGRectMake(27.8, 20.65, 28.3, 27.2))
			color.setStroke()
			oval2Path.lineWidth = 3
			oval2Path.stroke()
			
			
			//// Bezier 8 Drawing
			let bezier8Path = UIBezierPath()
			bezier8Path.moveToPoint(CGPointMake(53.11, 42.59))
			bezier8Path.addLineToPoint(CGPointMake(34.41, 65.75))
			color.setStroke()
			bezier8Path.lineWidth = 3
			bezier8Path.stroke()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
		}
		else if digit == 3
		{
			//// Digit 3
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			CGContextBeginTransparencyLayer(context, nil)
			
			
			//// Bezier 11 Drawing
			let bezier11Path = UIBezierPath()
			bezier11Path.moveToPoint(CGPointMake(40.15, 41.59))
			bezier11Path.addCurveToPoint(CGPointMake(53.62, 53.08), controlPoint1: CGPointMake(47.33, 41.35), controlPoint2: CGPointMake(53.36, 46.5))
			bezier11Path.addCurveToPoint(CGPointMake(41.1, 65.44), controlPoint1: CGPointMake(53.88, 59.67), controlPoint2: CGPointMake(48.27, 65.2))
			bezier11Path.addCurveToPoint(CGPointMake(28.55, 57.94), controlPoint1: CGPointMake(35.61, 65.62), controlPoint2: CGPointMake(30.59, 62.62))
			color.setStroke()
			bezier11Path.lineWidth = 3
			bezier11Path.stroke()
			
			
			//// Bezier 12 Drawing
			let bezier12Path = UIBezierPath()
			bezier12Path.moveToPoint(CGPointMake(40.36, 41.59))
			bezier12Path.addCurveToPoint(CGPointMake(52.31, 30.96), controlPoint1: CGPointMake(46.84, 41.69), controlPoint2: CGPointMake(52.2, 36.93))
			bezier12Path.addCurveToPoint(CGPointMake(40.77, 19.95), controlPoint1: CGPointMake(52.43, 24.98), controlPoint2: CGPointMake(47.26, 20.05))
			bezier12Path.addCurveToPoint(CGPointMake(29.65, 26.75), controlPoint1: CGPointMake(35.89, 19.87), controlPoint2: CGPointMake(31.46, 22.58))
			color.setStroke()
			bezier12Path.lineWidth = 3
			bezier12Path.stroke()
			
			
			//// Bezier 13 Drawing
			let bezier13Path = UIBezierPath()
			bezier13Path.moveToPoint(CGPointMake(40.21, 41.59))
			bezier13Path.addLineToPoint(CGPointMake(36.88, 41.62))
			color.setStroke()
			bezier13Path.lineWidth = 3
			bezier13Path.stroke()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
		}
		else if digit == 4
		{
			
			//// Digit 4 Drawing
			let digit4Path = UIBezierPath()
			digit4Path.moveToPoint(CGPointMake(47, 67))
			digit4Path.addLineToPoint(CGPointMake(47, 21.5))
			digit4Path.addLineToPoint(CGPointMake(27.99, 52.29))
			digit4Path.addLineToPoint(CGPointMake(56, 52.29))
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			color.setStroke()
			digit4Path.lineWidth = 3
			digit4Path.stroke()
			CGContextRestoreGState(context)
		}
		else if digit == 8
		{
			
			//// Digit 8
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			CGContextBeginTransparencyLayer(context, nil)
			
			
			//// Oval 3 Drawing
			let oval3Path = UIBezierPath(ovalInRect: CGRectMake(28.1, 40.75, 26, 23.9))
			color.setStroke()
			oval3Path.lineWidth = 3
			oval3Path.stroke()
			
			
			//// Oval 4 Drawing
			let oval4Path = UIBezierPath(ovalInRect: CGRectMake(29.3, 19.1, 23.5, 21.7))
			color.setStroke()
			oval4Path.lineWidth = 3
			oval4Path.stroke()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
		}
		else if digit == 5
		{
			//// Digit 5
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			CGContextBeginTransparencyLayer(context, nil)
			
			
			//// Bezier 2 Drawing
			let bezier2Path = UIBezierPath()
			bezier2Path.moveToPoint(CGPointMake(32.55, 39.07))
			bezier2Path.addCurveToPoint(CGPointMake(51.61, 43.77), controlPoint1: CGPointMake(39.1, 35.06), controlPoint2: CGPointMake(47.63, 37.16))
			bezier2Path.addCurveToPoint(CGPointMake(46.95, 63.01), controlPoint1: CGPointMake(55.59, 50.39), controlPoint2: CGPointMake(53.5, 59))
			bezier2Path.addCurveToPoint(CGPointMake(28.21, 58.81), controlPoint1: CGPointMake(40.6, 66.91), controlPoint2: CGPointMake(32.33, 65.05))
			color.setStroke()
			bezier2Path.lineWidth = 3
			bezier2Path.stroke()
			
			
			//// Bezier 3 Drawing
			let bezier3Path = UIBezierPath()
			bezier3Path.moveToPoint(CGPointMake(31.81, 40.37))
			bezier3Path.addLineToPoint(CGPointMake(31.81, 19.55))
			bezier3Path.addLineToPoint(CGPointMake(49.84, 19.63))
			color.setStroke()
			bezier3Path.lineWidth = 3
			bezier3Path.stroke()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
		}
		else if digit == 7
		{
			
			//// Digit 7
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			CGContextBeginTransparencyLayer(context, nil)
			
			
			//// Bezier 5 Drawing
			let bezier5Path = UIBezierPath()
			bezier5Path.moveToPoint(CGPointMake(28.06, 20.06))
			bezier5Path.addLineToPoint(CGPointMake(55.12, 20.06))
			bezier5Path.addLineToPoint(CGPointMake(38, 65.57))
			bezier5Path.addLineToPoint(CGPointMake(36.95, 65.57))
			color.setStroke()
			bezier5Path.lineWidth = 3
			bezier5Path.stroke()
			
			
			//// Group 3
			CGContextSaveGState(context)
			CGContextBeginTransparencyLayer(context, nil)
			
			//// Clip Clip
			let clipPath = UIBezierPath()
			clipPath.moveToPoint(CGPointMake(36.84, 64.53))
			clipPath.addLineToPoint(CGPointMake(35.89, 67.01))
			clipPath.addLineToPoint(CGPointMake(37.39, 67.01))
			clipPath.addLineToPoint(CGPointMake(36.84, 64.53))
			clipPath.closePath()
			clipPath.usesEvenOddFillRule = true;
			
			clipPath.addClip()
			
			
			//// Rectangle Drawing
			let rectanglePath = UIBezierPath(rect: CGRectMake(30.9, 59.5, 11.5, 12.5))
			color.setFill()
			rectanglePath.fill()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
			
			
			//// Bezier 7 Drawing
			let bezier7Path = UIBezierPath()
			bezier7Path.moveToPoint(CGPointMake(37.15, 64.3))
			bezier7Path.addLineToPoint(CGPointMake(36.2, 66.78))
			bezier7Path.addLineToPoint(CGPointMake(37.71, 66.78))
			bezier7Path.addLineToPoint(CGPointMake(37.15, 64.3))
			bezier7Path.closePath()
			color.setStroke()
			bezier7Path.lineWidth = 0.5
			bezier7Path.stroke()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
		}
		else if digit == 6
		{
			//// Digit 6
			CGContextSaveGState(context)
			CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.CGColor)
			CGContextBeginTransparencyLayer(context, nil)
			
			
			//// Oval Drawing
			let ovalPath = UIBezierPath(ovalInRect: CGRectMake(28.05, 38.45, 28.3, 27.5))
			color.setStroke()
			ovalPath.lineWidth = 3
			ovalPath.stroke()
			
			
			//// Bezier 4 Drawing
			let bezier4Path = UIBezierPath()
			bezier4Path.moveToPoint(CGPointMake(31.03, 43.77))
			bezier4Path.addLineToPoint(CGPointMake(49.72, 20.38))
			color.setStroke()
			bezier4Path.lineWidth = 3
			bezier4Path.stroke()
			
			
			CGContextEndTransparencyLayer(context)
			CGContextRestoreGState(context)
		}
	}
}

private extension NSDate
{
	func getTimeComponents() -> (hours: Int, minutes: Int, seconds: Int)
	{
		let calendar = NSCalendar.autoupdatingCurrentCalendar()
		let unitFlags: NSCalendarUnit = [.Hour, .Minute, .Second]
		let components = calendar.components(unitFlags, fromDate: self)
		return (components.hour, components.minute, components.second)
	}
	
	func getDateComponents() -> (day: Int, month: Int, year: Int)
	{
		let calendar = NSCalendar.autoupdatingCurrentCalendar()
		let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
		let components = calendar.components(unitFlags, fromDate: self)
		return (components.day, components.month, components.year)
	}
	
	func getFaceReadyTimeComponents(use24h: Bool) -> (hour1: Int8, hour2: Int8, minute1: Int8, minute2: Int8)
	{
		let components = self.getTimeComponents()
		
		let hours = use24h ? components.hours : components.hours%12
		
		return (Int8(hours/10),
				Int8(hours%10),
				Int8(components.minutes/10),
				Int8(components.minutes%10))
	}
	
	func getFaceReadyDateComponents(use24h: Bool) -> (digit1: Int8, digit2: Int8, digit3: Int8, digit4: Int8)
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