Class {
	#name : 'MooseParquetTestEntity',
	#superclass : 'Object',
	#instVars : [
		'mooseID',
		'mooseDescription',
		'properties',
		'values'
	],
	#category : 'MooseParquet-Tests-Support',
	#package : 'MooseParquet-Tests',
	#tag : 'Support'
}

{ #category : 'instance creation' }
MooseParquetTestEntity class >> id: anInteger label: aString [
	^ self new
		mooseID: anInteger;
		mooseDescription: (MooseParquetTestDescription fullName: aString);
		yourself
]

{ #category : 'accessing' }
MooseParquetTestEntity >> addProperty: aProperty value: anObject [
	self declareProperty: aProperty.
	values at: aProperty name asSymbol put: anObject
]

{ #category : 'accessing' }
MooseParquetTestEntity >> allDeclaredProperties [
	^ properties asArray
]

{ #category : 'accessing' }
MooseParquetTestEntity >> declareProperty: aProperty [
	properties add: aProperty.
	mooseDescription ifNotNil: [ mooseDescription addProperty: aProperty ]
]

{ #category : 'accessing' }
MooseParquetTestEntity >> doesNotUnderstand: aMessage [

	| selector key |
	selector := aMessage selector.
	(selector numArgs = 1 and: [ selector asString last = $: ]) ifTrue: [
		key := selector asString allButLast asSymbol.
		values at: key put: aMessage arguments first.
		^ aMessage arguments first ].
	(selector numArgs = 0 and: [ values includesKey: selector ]) ifTrue: [
		^ values at: selector ].
	^ super doesNotUnderstand: aMessage
]

{ #category : 'initialization' }
MooseParquetTestEntity >> initialize [
	super initialize.
	properties := OrderedCollection new.
	values := Dictionary new
]

{ #category : 'accessing' }
MooseParquetTestEntity >> mooseDescription [
	^ mooseDescription
]

{ #category : 'accessing' }
MooseParquetTestEntity >> mooseDescription: aDescription [
	mooseDescription := aDescription
]

{ #category : 'accessing' }
MooseParquetTestEntity >> mooseID [
	^ mooseID
]

{ #category : 'accessing' }
MooseParquetTestEntity >> mooseID: anInteger [
	mooseID := anInteger
]

{ #category : 'accessing' }
MooseParquetTestEntity >> propertyNamed: aName [
	^ values at: aName asSymbol
]

{ #category : 'accessing' }
MooseParquetTestEntity >> propertyNamed: aName ifAbsent: aBlock [
	^ values at: aName asSymbol ifAbsent: aBlock
]
