Class {
	#name : 'MooseParquetImportOrderRecorder',
	#superclass : 'MooseParquetImporter',
	#instVars : [
		'steps'
	],
	#category : 'MooseParquet-Tests-Support',
	#package : 'MooseParquet-Tests',
	#tag : 'Support'
}

{ #category : 'importing' }
MooseParquetImportOrderRecorder >> importEntities [
	steps add: #entities
]

{ #category : 'importing' }
MooseParquetImportOrderRecorder >> importEntitiesProperties [
	steps add: #properties
]

{ #category : 'importing' }
MooseParquetImportOrderRecorder >> importEntitiesRelationships [
	steps add: #relationships
]

{ #category : 'importing' }
MooseParquetImportOrderRecorder >> importMetadata [
	steps add: #metadata
]

{ #category : 'initialization' }
MooseParquetImportOrderRecorder >> initialize [
	super initialize.
	steps := OrderedCollection new
]

{ #category : 'accessing' }
MooseParquetImportOrderRecorder >> steps [
	^ steps asArray
]
