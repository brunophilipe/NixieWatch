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
	
	override var preferredStatusBarStyle : UIStatusBarStyle
	{
		return .lightContent
	}

	@IBAction func didTapVisitRepoButton(_ sender: AnyObject)
	{
		if let url = URL(string: "https://github.com/brunophilipe/NixieWatch")
		{
			UIApplication.shared.openURL(url)
		}
	}
}

