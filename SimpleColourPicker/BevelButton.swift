//
//  BevelButton.swift
//  GameBoardM
//
//  Created by tridiak on 17/08/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import UIKit

/*
Simple bevel button implementation.
*/

class BevelButton: UIView {
	/// Used by BevelGroup. ID inside the bevel group or -1 if it is not in a group.
	/// Do not use for persistent storage.
	/// The ID is specific to the associated BevelGroup.
	fileprivate(set) var groupID : Int = -1
	
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
	
	// Lets have the system do all the text drawing
	private var label : UILabel!
	
	private func createLabel() {
		label = UILabel(frame: CGRect(origin: .zero, size: frame.size))
		label.backgroundColor = offColour
		label.text = offText
		label.textAlignment = .center
		self.addSubview(label)
		self.isUserInteractionEnabled = true
	}
	
	/// Required init()
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		createLabel()
	}
	
	/// Required init()
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		createLabel()
	}
	
	/// So we can resize the UILable
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
	
	// Button pressing
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		on = !on
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
	
	// Button released
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let loc = touches.first!.location(in: self)
		// If release is outside button, change back to original value
		if !self.bounds.contains(loc) {
			on = !on
		}
		// Tell listener
		if notifyMe != nil { notifyMe!(self.tag, on) }
		// Tell bevel group
		if groupNotify != nil { groupNotify!(self) }
	}
	
	//-----------------
	
	/// Param 1 : UIView tag, Param 2 : on/off state
	typealias BevelChangedProc = (Int,Bool) -> Void
	var notifyMe : BevelChangedProc? = nil
	
	// For use by BevelGroup class
	fileprivate typealias GroupBevelProc = (BevelButton) -> Void
	fileprivate var groupNotify : GroupBevelProc? = nil
}

//-------------------------------------------

/*
Allows radio group type of control. Only one bevel on.
No bevels on is allowed.
*/
class BevelGroup {
	private var bevels : [BevelButton] = []
	// Internal IDs used by BevelGroup
	private var IDs : Int = 1
	// Which bevel is selected. < 0 means none.
	private var selectedID : Int = -1
	
	// Only one bevel to be in the on state.
	private func onlyOne() {
		for b in bevels {
			b.on = b.groupID == selectedID
		}
	}
	
	/// Add a bevel to the group. False is only returned if the bevel already belongs to another group.
	/// A bevel can only belong to one group.
	func add(bevel : BevelButton) -> Bool {
		if bevel.groupID >= 0 {return false}
		bevel.groupID = IDs
		IDs += 1
		bevels.append(bevel)
		bevel.groupNotify = {(bevel) in
			self.groupNotification(bevel: bevel)
		} // closure
		return true
	}
	
	// Notification that a bevel has changed state.
	private func groupNotification(bevel : BevelButton) {
		selectedID = bevel.on ? bevel.groupID : -1
		onlyOne()
		if ownerCallback != nil {
			if selectedID < 0 { ownerCallback!(nil, -1) }
			else { ownerCallback!(bevel, bevel.groupID) }
		}
	}
	
	/// Get selected bevel ID. Valid IDs are 0+. nil if no bevel is selected.
	func getSelectedID() -> Int? {
		return selectedID < 0 ? nil : selectedID
	}
	
	/// Return bevel with ID or nil if ID is unknown.
	func getBevel(withID: Int) -> BevelButton? {
		if withID < 0 { return nil }
		if let idx = bevels.index(where: { (bevel) -> Bool in
			return bevel.groupID == withID
		}) {
			return bevels[idx]
		}
		return nil
	}
	
	/// Remove bevel with ID
	func removeBevel(withID: Int) {
		if withID < 0 {return}
		if let idx = bevels.index(where: { (bevel) -> Bool in
			return bevel.groupID == withID
		}) {
			if withID == selectedID  { selectedID = -1 }
			bevels[idx].groupNotify = nil
			bevels[idx].groupID = -1
			bevels.remove(at: idx)
		}
		
		onlyOne()
	}
	
	/// Select the first bevel. ownerCallback is called.
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
