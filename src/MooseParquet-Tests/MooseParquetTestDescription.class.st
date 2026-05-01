Class {
	#name : 'MooseParquetTestDescription',
	#superclass : 'Object',
	#instVars : [
		'fullName',
		'properties'
	],
	#category : 'MooseParquet-Tests-Support',
	#package : 'MooseParquet-Tests',
	#tag : 'Support'
}

{ #category : 'instance creation' }
MooseParquetTestDescription class >> fullName: aString [
	^ self new
		fullName: aString;
		yourself
]

{ #category : 'accessing' }
MooseParquetTestDescription >> addProperty: aProperty [
	properties at: aProperty name asSymbol put: aProperty
]

{ #category : 'instance creation' }
MooseParquetTestDescription >> createInstance [

	^ MooseParquetTestEntity new
		  mooseDescription: self;
		  yourself
]

{ #category : 'accessing' }
MooseParquetTestDescription >> fullName [
	^ fullName
]

{ #category : 'accessing' }
MooseParquetTestDescription >> fullName: aString [
	fullName := aString
]

{ #category : 'initialization' }
MooseParquetTestDescription >> initialize [
	super initialize.
	properties := Dictionary new
]

{ #category : 'accessing' }
MooseParquetTestDescription >> propertyNamed: aSymbol [
	^ properties at: aSymbol asSymbol
]
