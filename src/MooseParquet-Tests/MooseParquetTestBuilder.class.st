Class {
	#name : 'MooseParquetTestBuilder',
	#superclass : 'Object',
	#instVars : [
		'values'
	],
	#category : 'MooseParquet-Tests-Support',
	#package : 'MooseParquet-Tests',
	#tag : 'Support'
}

{ #category : 'recording' }
MooseParquetTestBuilder >> append: anObject [
	values add: anObject
]

{ #category : 'recording' }
MooseParquetTestBuilder >> appendNull [
	values add: nil
]

{ #category : 'recording' }
MooseParquetTestBuilder >> finish [
	^ self values
]

{ #category : 'initialization' }
MooseParquetTestBuilder >> initialize [
	super initialize.
	values := OrderedCollection new
]

{ #category : 'accessing' }
MooseParquetTestBuilder >> size [
	^ values size
]

{ #category : 'accessing' }
MooseParquetTestBuilder >> values [
	^ values asArray
]
