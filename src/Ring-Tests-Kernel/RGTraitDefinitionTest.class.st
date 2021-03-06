"
SUnit tests for trait definitions
"
Class {
	#name : #RGTraitDefinitionTest,
	#superclass : #TestCase,
	#category : #Ring-Tests-Kernel
}

{ #category : #testing }
RGTraitDefinitionTest >> testAddingMethods [
	| newMethod newClass |
	
	newClass:= RGTraitDefinition named:  #TSortable.
	newMethod:= (RGMethodDefinition named: #sort) parent: newClass;
					protocol: 'sorting'; 
					sourceCode: 'sort
									self sort: [:a :b | a <= b]'.
	
	self assert: (newMethod isMetaSide not).
	self assert: (newClass hasMethods not).

	newClass addMethod: newMethod.
	newClass addSelector: #size 
			   classified: 'accessing' 
			   sourced: 'foo
							^lastIndex - firstIndex + 1'.
	
	self assert: (newClass hasMethods).
	self assert: (newClass selectors asSet = #(sort size) asSet).
	self assert: (newClass includesSelector: #sort).
	self assert: ((newClass methodNamed: #sort) = newMethod).
	self assert: (newClass methods size = 2).
	self assert: (newClass selectors size = 2).
	self assert: (newClass allSelectors size = 2).  "no hierarchy"

	newMethod:= newClass methodNamed: #size.
	self assert: (newMethod parent = newClass).
	
	self assert: ((newClass compiledMethodNamed: #sort) notNil).
	self assert: ((newClass compiledMethodNamed: #foo) isNil)
]

{ #category : #testing }
RGTraitDefinitionTest >> testAsTraitDefinition [

	| newTrait |
	newTrait:= TBehavior asRingDefinition.
	self assert: (newTrait isRingObject).
	self assert: (newTrait isTrait).  
	self assert: (newTrait name == #TBehavior).  
	self assert: (newTrait category notNil).
	self assert: (newTrait superclassName notNil).
	
	
	self assert: (newTrait theMetaClass isRingObject).
	self assert: (newTrait theMetaClass isTrait).
	self assert: (newTrait theMetaClass traitCompositionSource = '{}').
]

{ #category : #testing }
RGTraitDefinitionTest >> testAsTraitDefinition2 [

	| newTrait newClass newSlice |
	newClass := MOPTestClassC asRingDefinitionWithMethods: false withSuperclasses: false withSubclasses: true withPackages: false.
	newSlice := newClass environment.
	self assert: (newClass allSubclasses size = 0).
	self assert: newClass traitNames size = 1.
	self assert: newClass traits first = (newSlice traitNamed: #Trait2).
	
	newTrait := MOPTestClassA asRingDefinitionWithMethods: true withSuperclasses: true withSubclasses: false withPackages: true.
	newSlice := newTrait environment.
	self assert: newTrait superclass = (newSlice classNamed: #Object).
	self assert: newTrait methods size < newSlice methods size.
	self assert: newTrait category = #'Tests-Traits-MOP'.
	self assert: newTrait subclasses isEmpty.
]

{ #category : #testing }
RGTraitDefinitionTest >> testExistingTrait [
	| newClass metaClass |
	
	newClass:= RGTraitDefinition named:  #TSortable.
	self assert: (newClass isTrait).
	self assert: (newClass isDefined).
	self assert: (newClass realClass = TSortable).
	self assert: (newClass isMeta not).
	
	newClass withMetaclass.
	self assert: (newClass hasMetaclass).
	metaClass:= newClass theMetaClass.
	self assert: (metaClass isMeta).
	self assert: (metaClass name = 'TSortable classTrait').
	self assert: (metaClass theNonMetaClass = newClass).
	self assert: (metaClass realClass = TSortable theMetaClass).
]

{ #category : #testing }
RGTraitDefinitionTest >> testNonExistingClass [
	| newClass |
	
	newClass:= RGTraitDefinition named:  #TConnection.
	self assert: (newClass isTrait).
	self assert: (newClass hasMetaclass not).
	self assert: (newClass hasComment not).
	self assert: (newClass hasStamp not).
	self assert: (newClass parent = Smalltalk globals).
	self assert: (newClass package isNil).
	self assert: (newClass category isNil).
	self assert: (newClass hasMethods not).
	self assert: (newClass hasSuperclass not).
	self assert: (newClass hasTraitComposition not).
	self assert: (newClass isDefined not).
	self assert: (newClass hasProtocols not).
]

{ #category : #testing }
RGTraitDefinitionTest >> testTraitEquality [

	| newClass |
	self assert: TSortable asRingDefinition = TSortable asRingDefinition.
	
	newClass := (TSortable asRingDefinition)
		category: #Kernel.
	self assert: (TSortable asRingDefinition = newClass) 
]
