"
Classes that use traits with explicit requirement methods should either implement the method or inherit it.
"
Class {
	#name : #RBExplicitRequirementMethodsRule,
	#superclass : #ReAbstractRule,
	#category : #GeneralRules-Migrated
}

{ #category : #testing }
RBExplicitRequirementMethodsRule class >> checksClass [
	^ true
]

{ #category : #accessing }
RBExplicitRequirementMethodsRule class >> uniqueIdentifierName [

	^ 'ExplicitRequirementMethodsRule'
]

{ #category : #running }
RBExplicitRequirementMethodsRule >> check: aClass forCritiquesDo: aCritiqueBlock [

	| explicitRequirementMethods |
	
	
	aClass isTrait 
		ifTrue: [ ^ self ].
		
	explicitRequirementMethods := aClass traitComposition allSelectors
		collect: [ :selector |
			aClass>>selector ]
		thenSelect: [ :method |
			method isRequired and: [ method isSubclassResponsibility not ] ].
	
	explicitRequirementMethods
		select: [ :method |
      		aClass withAllSuperclasses noneSatisfy: [ :superclass |
				superclass canPerform: method selector ] ]
		thenDo: [ :method |
			aCritiqueBlock cull: (
				(self critiqueFor: aClass)
  					tinyHint: method selector;
  					yourself) ]
]

{ #category : #'as yet unclassified' }
RBExplicitRequirementMethodsRule >> criticueFor: aClass withMissing: aSelector [
    ^ (ReMissingMethodCritique for: aClass by: self class: aClass selector: aSelector) beShouldBeImplemented
]

{ #category : #'as yet unclassified' }
RBExplicitRequirementMethodsRule >> group [
	^ 'Coding Idiom Violation'
]

{ #category : #accessing }
RBExplicitRequirementMethodsRule >> name [
	^ 'Explicit requirement methods'
]
