//
//  BevelButton.swift
//  GameBoardM
//
//  Created by tridiak on 17/08/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import UIKit

class BevelButton: UIView {
	
	fileprivate var groupID : Int = -1
	
	var on : Bool = false {
		didSet {
			label.backgroundColor = on ? onColour :offColour
			label.text = on ? onText : offText
		}
	}
	
	var onColour : UIColor = UIColor.lightGray {
		didSet {
			if on { label.backgroundColor = onColour }
		}
	}
	
	var offColour : UIColor = UIColor.white {
		didSet {
			if !on { label.backgroundColor = offColour }
		}
	}
	
	var onText : String = "On" {
		didSet {
			if on { label.text = onText }
		}
	}
	
	var offText : String = "Off" {
		didSet {
			if !on { label.text = offText }
		}
	}
	
	private var label : UILabel!
	
	private func createLabel() {
		label = UILabel(frame: CGRect(origin: .zero, size: frame.size))
		label.backgroundColor = offColour
		label.text = offText
		label.textAlignment = .center
		self.addSubview(label)
		self.isUserInteractionEnabled = true
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		createLabel()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		createLabel()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		label.frame = CGRect(origin: .zero, size: frame.size)
	}
	
	//---------------------------
	/*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		on = !on
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let loc = touches.first!.location(in: self)
		if !self.bounds.contains(loc) {
			on = !on
			
		}
		if notifyMe != nil { notifyMe!(self.tag, on) }
		if groupNotify != nil { groupNotify!(self) }
	}
	
	//-----------------
	
	/// Param 1 : control tag, Param 2 : on/off state
	typealias BevelChangedProc = (Int,Bool) -> Void
	var notifyMe : BevelChangedProc? = nil
	
	// For use by BevelGroup class
	fileprivate typealias GroupBevelProc = (BevelButton) -> Void
	fileprivate var groupNotify : GroupBevelProc? = nil
}

//-------------------------------------------

class BevelGroup {
	private var bevels : [BevelButton] = []
	private var IDs : Int = 1
	private var selectedID : Int = -1
	
	private func onlyOne() {
		for b in bevels {
			b.on = b.groupID == selectedID
		}
	}
	
	func add(bevel : BevelButton) {
		bevel.groupID = IDs
		IDs += 1
		bevels.append(bevel)
		bevel.groupNotify = {(bevel) in
			self.groupNotification(bevel: bevel)
		} // closure
	}
	
	private func groupNotification(bevel : BevelButton) {
		selectedID = bevel.on ? bevel.groupID : -1
		onlyOne()
		if ownerCallback != nil {
			if selectedID < 0 { ownerCallback!(nil, -1) }
			else { ownerCallback!(bevel, bevel.groupID) }
		}
	}
	
	func getSelectedID() -> Int? {
		return selectedID < 0 ? nil : selectedID
	}
	
	func removeBevel(withID: UInt) {
		if withID > Int.max {return}
		if let idx = bevels.index(where: { (bevel) -> Bool in
			return bevel.groupID == withID
		}) {
			if withID == selectedID  { selectedID = -1 }
			bevels[idx].groupNotify = nil
			bevels.remove(at: idx)
		}
		
		onlyOne()
	}
	
	/// Select the first bevel
	func selectFirst() {
		if bevels.count == 0 {return}
		bevels[0].on = true
		if ownerCallback != nil {
			ownerCallback!(bevels[0], bevels[0].groupID)
		}
	}
	
	/// Closure definition. Selected bevel or nil if no bevel is selected.
	/// Second parameter is selected bevel group ID. If no bevel is selected, this will be -1.
	typealias SelectedBevelProc = (BevelButton?, Int) -> Void
	var ownerCallback : SelectedBevelProc? = nil
}
