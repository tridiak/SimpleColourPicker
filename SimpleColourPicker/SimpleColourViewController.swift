//
//  SimpleColourViewController.swift
//  SimpleColourPicker
//
//  Created by tridiak on 22/08/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import UIKit

class SimpleColourViewController: UIViewController {
	
	@IBOutlet var RGB : BevelButton!
	@IBOutlet var CYMK : BevelButton!
	@IBOutlet var gray : BevelButton!
	
	@IBOutlet var redCyanSlider : UISlider!
	@IBOutlet var greenMagentaSlider : UISlider!
	@IBOutlet var blueYellowSlider : UISlider!
	@IBOutlet var blackSlider : UISlider!
	
	// 0-255 values of each slider for the color mode
	@IBOutlet var colourBlab : UILabel!
	@IBOutlet var colourBox : UIView!
	
	// Lets us do radio group type operation for bevels
	private let bevelGroup : BevelGroup = BevelGroup.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
        RGB.onText = "RGB"
        RGB.offText = "RGB"
        RGB.onColour = UIColor.darkGray
        RGB.offColour = UIColor.lightGray
		
        CYMK.onText = "CYMK"
        CYMK.offText = "CYMK"
        CYMK.onColour = UIColor.darkGray
        CYMK.offColour = UIColor.lightGray
		
        gray.onText = "Gray"
        gray.offText = "Gray"
        gray.onColour = UIColor.darkGray
        gray.offColour = UIColor.lightGray
		
        bevelGroup.add(bevel: RGB)
        bevelGroup.add(bevel: CYMK)
        bevelGroup.add(bevel: gray)
        bevelGroup.selectFirst()
		bevelGroup.ownerCallback = {(bevel,ID) in
			if bevel == nil {
			 	self.bevelGroup.selectFirst()
			 	// Doing this will call the callback again
			}
			else {
				switch bevel!.tag {
					case 0: self.colourMode = .RGB
					case 1: self.colourMode = .CMYK
					case 2: self.colourMode = .gray
					default: fatalError("Unexpected bevel tag")
				}
				//self.colourSpacedChange() 
			}
		} // closure
		
		colourMode = .RGB
		colourBox.backgroundColor = colour
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//--------------------------------------
	// MARK:-
	
	private func colourSpacedChange() {
		if redCyanSlider == nil {return}
		switch colourMode {
			case .RGB:
				redCyanSlider.isHidden = false
				greenMagentaSlider.isHidden = false
				blueYellowSlider.isHidden = false
				blackSlider.isHidden = true
				
				redCyanSlider.tintColor = .red
				redCyanSlider.thumbTintColor = .red
				greenMagentaSlider.tintColor = .green
				greenMagentaSlider.thumbTintColor = .green
				blueYellowSlider.tintColor = .blue
				blueYellowSlider.thumbTintColor = .blue
			
				// convert the slider values
				if oldSpace == .CMYK {
					let oldCol = SimpleColourViewController.CMYKToRGB(cyan: C(redCyan), magenta: C(greenMagenta), yellow: C(blueYellow), black: C(black))
					redCyan = UInt8(oldCol.R * 255)
					greenMagenta = UInt8(oldCol.G * 255)
					blueYellow = UInt8(oldCol.B * 255)
				}
				else if oldSpace == .gray {
					redCyan = black
					greenMagenta = black
					blueYellow = black
				}
//				blackSlider.tintColor = .black
//				blackSlider.thumbTintColor = .black
			
			case .CMYK:
				redCyanSlider.isHidden = false
				greenMagentaSlider.isHidden = false
				blueYellowSlider.isHidden = false
				blackSlider.isHidden = false
			
				redCyanSlider.tintColor = .cyan
				redCyanSlider.thumbTintColor = .cyan
				greenMagentaSlider.tintColor = .magenta
				greenMagentaSlider.thumbTintColor = .magenta
				blueYellowSlider.tintColor = .yellow
				blueYellowSlider.thumbTintColor = .yellow
				blackSlider.tintColor = .lightGray
				blackSlider.thumbTintColor = .lightGray
			
				// convert the slider values
				if oldSpace == .RGB {
					let oldCol = SimpleColourViewController.RGBToCMYK(red: C(redCyan), green: C(greenMagenta), blue: C(blueYellow))
					redCyan = UInt8(oldCol.C * 255)
					greenMagenta = UInt8(oldCol.M * 255)
					blueYellow = UInt8(oldCol.Y * 255)
					black = UInt8(oldCol.B * 255)
				}
				else if oldSpace == .gray {
					redCyan = 0
					greenMagenta = 0
					blueYellow = 0
				}
			
			case .gray:
				redCyanSlider.isHidden = true
				greenMagentaSlider.isHidden = true
				blueYellowSlider.isHidden = true
				blackSlider.isHidden = false
			
//				redSlider.tintColor = .lightGray
//				redSlider.thumbTintColor = .lightGray
//				greenSlider.tintColor = .lightGray
//				greenSlider.thumbTintColor = .lightGray
//				blueSlider.tintColor = .lightGray
//				blueSlider.thumbTintColor = .lightGray
				blackSlider.tintColor = .darkGray
				blackSlider.thumbTintColor = .darkGray
			
				// convert the slider values
				// Important for RGB : if values are not exactly the same, an average will be used
				if oldSpace == .RGB {
					black = UInt8( (UInt16(redCyan) + UInt16(greenMagenta) + UInt16(blueYellow)) / 3 )
				}
				else if oldSpace == .CMYK {
					// black = black
				}
		}
		syncSliders()
		colourBox.backgroundColor = colour
	}
	
	enum SCPColourSpace {
		case RGB
		case CMYK
		case gray
	}
	
	private var oldSpace : SCPColourSpace = .RGB
	/// Current colour select mode. Important: colour below returns CMYK in RGB color space.
	private(set) var colourMode : SCPColourSpace = .RGB {
		willSet { oldSpace = colourMode }
		didSet {
			colourSpacedChange()
		}
	}
	
	// MARK:-
	/// Callback whenever the slider changes.
	typealias ColourChangeProc = (UIColor, SCPColourSpace) -> Void
	
	/// Listener closure callback
	var colourChanged : ColourChangeProc? = nil
	
	//-----------------------------------------------------
	// MARK:-
	
	static func RGBToCMYK(red : CGFloat, green : CGFloat, blue : CGFloat) -> (C:CGFloat, M:CGFloat, Y: CGFloat, B: CGFloat) {
		let black = 1 - max(red, green, blue)
		let cyan = (1 - red - black) / (1 - black)
		let magenta = (1 - green - black) / (1 - black)
		let yellow = (1 - blue - black) / (1 - black)
		return (cyan, magenta, yellow, black)
	}
	
	static func CMYKToRGB(cyan : CGFloat, magenta : CGFloat, yellow : CGFloat, black : CGFloat) -> (R:CGFloat, G:CGFloat, B:CGFloat) {
		let B = 1 - black
		return ((1 - cyan) * B, (1 - magenta) * B, (1 - yellow) * B)
	}
	
	/// Returns (gray,gray,gray)
	static func GrayToRGB(gray : CGFloat) -> (R:CGFloat, G:CGFloat, B:CGFloat) {
		return (gray, gray, gray)
	}
	
	/// Returns (0,0,0,gray)
	static func GrayToCMYK(gray : CGFloat) -> (C:CGFloat, M:CGFloat, Y: CGFloat, B: CGFloat) {
		return (0,0,0,gray)
	}
	
	// Also used for Cyan
	private var redCyan : UInt8 = 127
	// Also used for Magenta
	private var greenMagenta : UInt8 = 127
	// Also used for Yellow
	private var blueYellow : UInt8 = 127
	// Used for Black, Gray
	private var black : UInt8 = 127
	
	private func C(_ c : UInt8) -> CGFloat {
		return CGFloat(c) / 255
	}
	
	/// Return colour based on current colour mode. Important : colour return for CMYK mode will be RGB colour space.
	/// Setter will try and convert the passed colour to RGB colour space. Colour mode will be set to RGB.
    var colour : UIColor {
		get {
			switch colourMode {
				case .RGB:
					return UIColor(red: C(redCyan), green: C(greenMagenta), blue: C(blueYellow), alpha: 1)
				case .CMYK:
					return UIColor(red: (1 - C(redCyan)) * (1 - C(black)), green:(1 - C(greenMagenta)) * (1 - C(black)), blue:(1 - C(blueYellow)) * (1 - C(black)), alpha:1)
				case .gray:
					return UIColor(white: C(black), alpha: 1)
			}
			
		}
		set(C) {
			guard let col = C.ConverTo(colourSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!) else {return}
			redCyan = UInt8(col.redComponent! * 255)
			greenMagenta = UInt8(col.greenComponent! * 255)
			blueYellow = UInt8(col.blueComponent! * 255)
			colourMode = .RGB
		}
	}
	
	/// Set colour using an UIColor with RGB colour space. If it is not, an exception will be raised.
	/// This will also convert the colour space mode to RGB.
	func setColour(RGB: UIColor) {
		redCyan = UInt8(RGB.redComponent! * 255)
		greenMagenta = UInt8(RGB.greenComponent! * 255)
		blueYellow = UInt8(RGB.blueComponent! * 255)
		colourMode = .RGB
	}
	
	/// Set colour using an UIColor with gray(white) colour space. If it is not, an exception will be raised.
	/// This will also convert the colour space mode to gray.
	func setColour(gray: UIColor) {
		black = UInt8(gray.greenComponent! * 255)
		colourMode = .gray
	}
	
	/// Set colour 0 to 1 gray scale. If the value is outside of this range, nothing wil happen.
	/// This will also convert the colour space mode to gray.
	func setColour(grayScale : CGFloat) {
		if grayScale < 0 || grayScale > 1 {return}
		black = UInt8(grayScale * 255)
		colourMode = .gray
	}
	
	private func syncSliders() {
		redCyanSlider.value = Float(redCyan)
		greenMagentaSlider.value = Float(greenMagenta)
		blueYellowSlider.value = Float(blueYellow)
		blackSlider.value = Float(black)
	}
	
	//--------------------------------------------------------
	// MARK:-
	
	@IBAction func colourSlider(_ sender : UISlider) {
		redCyan = UInt8(redCyanSlider.value)
		greenMagenta = UInt8(greenMagentaSlider.value)
		blueYellow = UInt8(blueYellowSlider.value)
		black = UInt8(blackSlider.value)
		
		switch colourMode {
			case .RGB:
				colourBlab.text = "R\(redCyan), G\(greenMagenta), B\(blueYellow)"
			case .CMYK:
				colourBlab.text = "C\(redCyan), M\(greenMagenta), Y\(blueYellow) B\(black)"
			case .gray:
				colourBlab.text = "Gray \(black)"
		}
		
		colourBox.backgroundColor = colour
		if colourChanged != nil {
			colourChanged!(colour, colourMode)
		}
		
	} // colourSlider()
	
	@IBAction func closeBtn(_ sender : UIButton) {
		self.dismiss(animated: true) {
			
		}
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
}

//-------------------------------------------
// MARK:-

/// Some NSColor methods & properties implemented for iOS.
extension UIColor {
	/// This is a UIColor implementation of an NSColor method.
	func ConverTo(colourSpace : CGColorSpace) -> UIColor? {
		if let newCol = cgColor.converted(to: colourSpace, intent: CGColorRenderingIntent.defaultIntent, options: nil) {
			return UIColor.init(cgColor: newCol)
		}
		return nil
	}
	
	// Partially duplicated NSColor version so we don't have lots of #if os(XXX).
	// Exception is not raised if incorrect colour space.
	
	/// Returns red component if possible otherwise nil
	var redComponent : CGFloat? {
		var R : CGFloat = 0
		if !getRed(&R, green: nil, blue: nil, alpha: nil) {return nil}
		return R
	}
	
	/// Returns green component if possible otherwise nil
	var greenComponent : CGFloat? {
		var R : CGFloat = 0
		if !getRed(nil, green: &R, blue: nil, alpha: nil) {return nil}
		return R
	}
	
	/// Returns blue component if possible otherwise nil
	var blueComponent : CGFloat? {
		var R : CGFloat = 0
		if !getRed(nil, green: nil, blue: &R, alpha: nil) {return nil}
		return R
	}
	
	/// Returns alpha component if possible otherwise nil
	var alphaComponent : CGFloat? {
		var R : CGFloat = 1
		if !getRed(nil, green: nil, blue: nil, alpha: &R) {
			if !getHue(nil, saturation: nil, brightness: nil, alpha: &R) {
				if !getWhite(nil, alpha: &R) {return nil}
			}
		}
		return R
	}
	
	/// Returns gray scale value if possible otherwise nil
	var gray : CGFloat? {
		var G : CGFloat = 0
		if !getWhite(&G, alpha: nil) {return nil}
		return G
	}
}

