//
//  ViewController.swift
//  NixieWatch
//
//  Created by Bruno Philipe on 05/03/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle
	{
		return .LightContent
	}

	@IBAction func didTapVisitRepoButton(sender: AnyObject)
	{
		if let url = NSURL(string: "https://github.com/brunophilipe/NixieWatch")
		{
			UIApplication.sharedApplication().openURL(url)
		}
	}
}

