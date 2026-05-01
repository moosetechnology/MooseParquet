Class {
	#name : 'MooseParquetTestModel',
	#superclass : 'Object',
	#instVars : [
		'name',
		'entities'
	],
	#category : 'MooseParquet-Tests-Support',
	#package : 'MooseParquet-Tests',
	#tag : 'Support'
}

{ #category : 'accessing' }
MooseParquetTestModel >> add: anEntity [

	self entities add: anEntity.
	^ anEntity
]

{ #category : 'accessing' }
MooseParquetTestModel >> addEntity: anEntity [

	^ self add: anEntity
]

{ #category : 'accessing' }
MooseParquetTestModel >> elementNamed: aString [

	^ MooseParquetTestDescription fullName: aString
]

{ #category : 'accessing' }
MooseParquetTestModel >> entities [

	^ entities ifNil: [ entities := OrderedCollection new ]
]

{ #category : 'accessing' }
MooseParquetTestModel >> entities: aCollection [

	entities := aCollection asOrderedCollection
]

{ #category : 'initialization' }
MooseParquetTestModel >> initialize [

	super initialize.
	entities := OrderedCollection new
]

{ #category : 'accessing' }
MooseParquetTestModel >> metamodel [

	^ self
]

{ #category : 'accessing' }
MooseParquetTestModel >> name [
	^ name
]

{ #category : 'accessing' }
MooseParquetTestModel >> name: aString [
	name := aString
]
