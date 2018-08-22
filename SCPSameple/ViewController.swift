//
//  ViewController.swift
//  SCPSameple
//
//  Created by tridiak on 22/08/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		colourBox.backgroundColor = currentColour
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private var colourPopCtrl : SimpleColourViewController!
	private var currentColour : UIColor = .red {
		didSet { colourBox.backgroundColor = currentColour }
	}
	
	@IBOutlet var colourBox : UIView!
	
	@IBAction func colourBtn(_ sender : UIButton) {
		colourPopCtrl = SimpleColourViewController(nibName: "SimpleColourViewController", bundle: nil)
		colourPopCtrl.modalPresentationStyle = .popover
	//	colourPopCtrl.preferredContentSize = CGSize(width: 280, height: 198)
		
		if let pop = colourPopCtrl.popoverPresentationController {
			pop.delegate = self
			pop.sourceRect = sender.bounds
			pop.sourceView = sender
			colourPopCtrl.colour = currentColour
			colourPopCtrl.colourChanged = {(colour, colourSpace) in
				self.currentColour = colour
			}
			
			self.present(colourPopCtrl!, animated: true, completion: nil)
		}
	} // colourBtn()
}

