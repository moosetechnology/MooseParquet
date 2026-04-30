Class {
	#name : 'MooseParquetTestProperty',
	#superclass : 'Object',
	#instVars : [
		'name',
		'type',
		'derived',
		'opposite',
		'multivalued'
	],
	#category : 'MooseParquet-Tests-Support',
	#package : 'MooseParquet-Tests',
	#tag : 'Support'
}

{ #category : 'instance creation' }
MooseParquetTestProperty class >> named: aName type: aType [
	^ self new
		name: aName;
		type: aType;
		yourself
]

{ #category : 'testing' }
MooseParquetTestProperty >> hasOpposite [
	^ opposite
]

{ #category : 'accessing' }
MooseParquetTestProperty >> hasOpposite: aBoolean [
	opposite := aBoolean
]

{ #category : 'initialization' }
MooseParquetTestProperty >> initialize [
	super initialize.
	derived := false.
	opposite := false.
	multivalued := false
]

{ #category : 'testing' }
MooseParquetTestProperty >> isDerived [
	^ derived
]

{ #category : 'accessing' }
MooseParquetTestProperty >> isDerived: aBoolean [
	derived := aBoolean
]

{ #category : 'testing' }
MooseParquetTestProperty >> isMultivalued [
	^ multivalued
]

{ #category : 'accessing' }
MooseParquetTestProperty >> isMultivalued: aBoolean [
	multivalued := aBoolean
]

{ #category : 'accessing' }
MooseParquetTestProperty >> name [
	^ name
]

{ #category : 'accessing' }
MooseParquetTestProperty >> name: anObject [
	name := anObject
]

{ #category : 'accessing' }
MooseParquetTestProperty >> type [
	^ type
]

{ #category : 'accessing' }
MooseParquetTestProperty >> type: anObject [
	type := anObject
]
