Class {
	#name : 'MooseParquetTestType',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'typeName'
	],
	#category : 'MooseParquet-Tests-Support',
	#package : 'MooseParquet-Tests',
	#tag : 'Support'
}

{ #category : 'instance creation' }
MooseParquetTestType class >> boolean [
	^ self kind: #boolean name: #Boolean
]

{ #category : 'instance creation' }
MooseParquetTestType class >> kind: aSymbol name: aName [
	^ self new
		kind: aSymbol name: aName;
		yourself
]

{ #category : 'instance creation' }
MooseParquetTestType class >> number [
	^ self kind: #number name: #Number
]

{ #category : 'instance creation' }
MooseParquetTestType class >> object [
	^ self kind: #object name: #Object
]

{ #category : 'instance creation' }
MooseParquetTestType class >> string [
	^ self kind: #string name: #String
]

{ #category : 'testing' }
MooseParquetTestType >> isKindOf: aClass [
	((aClass name = #FM3String) and: [ kind = #string ]) ifTrue: [ ^ true ].
	((aClass name = #FM3Number) and: [ kind = #number ]) ifTrue: [ ^ true ].
	((aClass name = #FM3Boolean) and: [ kind = #boolean ]) ifTrue: [ ^ true ].
	^ super isKindOf: aClass
]

{ #category : 'accessing' }
MooseParquetTestType >> kind [
	^ kind
]

{ #category : 'accessing' }
MooseParquetTestType >> kind: aSymbol name: aName [
	kind := aSymbol.
	typeName := aName
]

{ #category : 'accessing' }
MooseParquetTestType >> name [
	^ typeName
]
