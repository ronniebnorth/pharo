Extension { #name : #Morph }

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> activate [
	"Mark the receiver and submorphs as active (foreground)."

	self submorphsDo: [:m | m activate]
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> collapse [
	CollapsedMorph new beReplacementFor: self
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> containingWindow [
	"Answer a window that contains the receiver"

	^ self ownerThatIsA: SystemWindow
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> dialogWindow [
	"Answer the receiver's dialog window."

	^self ownerThatIsA: DialogWindow
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> embedInWindow [

	| window worldToUse |

	worldToUse := self world.		"I'm assuming we are already in a world"
	window := (SystemWindow labelled: self defaultLabel) model: nil.
	window bounds: ((self position - ((0@window labelHeight) + window borderWidth))
						corner: self bottomRight + window borderWidth).
	window addMorph: self frame: (0@0 extent: 1@1).
	window updatePaneColors.
	worldToUse addMorph: window.
	window activate
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> embeddedInMorphicWindowLabeled: labelString [
	| window |
	window := (SystemWindow labelled: labelString) model: nil.
	window setStripeColorsFrom:  (self theme windowColorFor: self).
	window addMorph: self frame: (0@0 extent: 1@1).
	^ window
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> initialColorInSystemWindow: aSystemWindow [
	"Answer the colour the receiver should be when added to a SystemWindow."

	^Color white
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> isInSystemWindow [
	"answer if the receiver is in a system window"
	^ owner isMorph and:[owner isSystemWindow or:[owner isInSystemWindow]]
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> isWindowActive: aSystemWindow [
	"Answer whether the given window is active.
	Implement in morphs that are designed to embed system windows.
	Delegate to owner."
	
	^self owner ifNil: [true] ifNotNil: [:o | o isWindowActive: aSystemWindow]
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> modalLockTo: aSystemWindow [
	"Lock the receiver as a modal owner of the given window."

	self lock
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> nextMorphAcrossInWindow [
	"Answer the next morph in the window. Traverse
	from the receiver to its next sibling or owner's next sibling etc."

	^self submorphAfter ifNil: [
		(self owner ifNil: [^self]) nextMorphAcrossInWindow]
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> nextMorphInWindow [
	"Answer the next morph in the window. Traverse
	from the receiver to its first child or next sibling or owner's next sibling etc."

	^self hasSubmorphs
		ifTrue: [self submorphs first]
		ifFalse: [self nextMorphAcrossInWindow]
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> nextMorphWantingFocus [
	"Answer the next morph that wants keyboard focus."

	|m|
	m := self nextMorphInWindow ifNil: [^nil].
	[m = self or: [m wantsKeyboardFocusNavigation]]
		whileFalse: [m := m nextMorphInWindow].
	^m wantsKeyboardFocusNavigation
		ifTrue: [m]
	
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> openInWindow [

	^self openInWindowLabeled: self defaultLabel

]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> openInWindowLabeled: aString [

	^self openInWindowLabeled: aString inWorld: self currentWorld
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> openInWindowLabeled: aString inWorld: aWorld [
	"Changed to include the inset margin in the bound calculation."

	| window extent |
	window := (SystemWindow labelled: aString) model: nil.
	window 
		" guess at initial extent"
		bounds:  (RealEstateAgent initialFrameFor: window initialExtent: self fullBounds extent world: aWorld);
		addMorph: self frame: (0@0 extent: 1@1);
		updatePaneColors.
	" calculate extent after adding in case any size related attributes were changed.  Use
	fullBounds in order to trigger re-layout of layout morphs"
	extent := self fullBounds extent + 
			(window borderWidth@window labelHeight) + window borderWidth +
			(window class borderWidth * 2 @ (window class borderWidth + 1)). "include inset margin"
	window extent: extent.
	aWorld addMorph: window.
	window activate.
	aWorld startSteppingSubmorphsOf: window.
	
	window announceOpened.
	^window

]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> openModal: aSystemWindow [
	"Open the given window locking the receiver until it is dismissed.
	Answer the system window.
	Restore the original keyboard focus when closed."

	|area mySysWin keyboardFocus|
	
	keyboardFocus := self activeHand keyboardFocus.
	
	mySysWin := self isSystemWindow ifTrue: [self] ifFalse: [self ownerThatIsA: SystemWindow].
	mySysWin ifNil: [mySysWin := self].
	mySysWin modalLockTo: aSystemWindow.
	
	area := RealEstateAgent maximumUsableArea.
	
	aSystemWindow extent: aSystemWindow initialExtent.
	aSystemWindow position = (0@0) ifTrue: [
			aSystemWindow position: self activeHand position - (aSystemWindow extent // 2)
	].
	aSystemWindow bounds: (aSystemWindow bounds translatedToBeWithin: area).
	
	[  
		|aWidget| 
		
		aWidget := aSystemWindow openAsIs.
		
		self activeHand mouseFocus: aWidget.
		
		[aWidget world notNil] whileTrue: [
			aWidget outermostWorldMorph doOneCycle
		]
		
	] ensure: [
		mySysWin modalUnlockFrom: aSystemWindow.
		self activeHand newKeyboardFocus: keyboardFocus
	].

	^aSystemWindow
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> previousMorphInWindow [
	"Answer the next morph in the window. Traverse
	from the receiver to its previous sibling's last submorph (recursive)
	or owner's previous sibling's last submorph (recursive) etc."

	^self submorphBefore notNil
		ifTrue: [self submorphBefore lastSubmorphRecursive]
		ifFalse: [self owner]
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> previousMorphWantingFocus [
	"Answer the previous morph that wants keyboard focus."

	|m|
	m := self previousMorphInWindow ifNil: [^nil].
	[m = self or: [m wantsKeyboardFocusNavigation]]
		whileFalse: [m := m previousMorphInWindow ifNil: [^nil]].
	^m wantsKeyboardFocusNavigation
		ifTrue: [m]
	
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> shadowOffsetRectangle [
	"Answer a rectangle describing the offsets to the
	receiver's bounds for a drop shadow."

	^self shadowOffset negated corner: self shadowOffset
]

{ #category : #'*Morphic-Widgets-Windows' }
Morph >> window [
	"Answer the receiver's window."

	^self ownerThatIsA: SystemWindow
]
