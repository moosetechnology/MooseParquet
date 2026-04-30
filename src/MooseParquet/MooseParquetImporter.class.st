Class {
	#name : 'MooseParquetImporter',
	#superclass : 'Object',
	#instVars : [
		'model',
		'entitiesMap',
		'metadata'
	],
	#category : 'MooseParquet-ParquetImporter',
	#package : 'MooseParquet',
	#tag : 'ParquetImporter'
}

{ #category : 'metadata' }
MooseParquetImporter >> applyMetadata [
	self metadataName ifNotNil: [ :modelName |
		(model notNil and: [ model respondsTo: #name: ]) ifTrue: [
			model name: modelName ] ]
]

{ #category : 'api' }
MooseParquetImporter >> import [
	self importMetadata.
	self importEntities.
	self importEntitiesProperties.
	self importEntitiesRelationships
]

{ #category : 'as yet unclassified' }
MooseParquetImporter >> importEntities [

	| reader table idArray labelArray |
	reader := GParquetArrowFileReader
		          on: '/Users/benoit.verhaeghe/Documents/entities.parquet'
		          error: nil.
	table := reader readTableWithError: nil.
	idArray := (table dataOfColumns: 0) chunk: 0.
	labelArray := (table dataOfColumns: 1) chunk: 0.
	0 to: table numberOfRows - 1 do: [ :index |
		| entity |
		entity := (self model metamodel elementNamed: (labelArray at: index))
			          createInstance.
		self model add: entity.
		entitiesMap at: (idArray at: index) put: entity ]
]

{ #category : 'as yet unclassified' }
MooseParquetImporter >> importEntitiesProperties [

	| reader table nodeIdArray keyArray valTypeArray valuesArray |
	reader := GParquetArrowFileReader
		          on:
		          '/Users/benoit.verhaeghe/Documents/entities_properties.parquet'
		          error: nil.
	table := reader readTableWithError: nil.
	nodeIdArray := (table dataOfColumns: 0) chunk: 0.
	keyArray := (table dataOfColumns: 1) chunk: 0.
	valTypeArray := (table dataOfColumns: 2) chunk: 0.
	valuesArray := {
		               (0 -> ((table dataOfColumns: 3) chunk: 0)).
		               (1 -> ((table dataOfColumns: 4) chunk: 0)).
		               (2 -> ((table dataOfColumns: 5) chunk: 0)).
		               (3 -> ((table dataOfColumns: 6) chunk: 0)) }
		               asDictionary.
	0 to: table numberOfRows - 1 do: [ :index |
		| entity |
		entity := entitiesMap at: (nodeIdArray at: index).
		entity
			perform: (keyArray at: index) asSymbol asMutator
			with: ((valuesArray at: (valTypeArray at: index)) at: index) ]
]

{ #category : 'as yet unclassified' }
MooseParquetImporter >> importEntitiesRelationships [

	| reader table typeArray startNodeArray endNodeArray |
	reader := GParquetArrowFileReader
		          on:
		          '/Users/benoit.verhaeghe/Documents/relationships.parquet'
		          error: nil.
	table := reader readTableWithError: nil.
	typeArray := (table dataOfColumns: 0) chunk: 0.
	startNodeArray := (table dataOfColumns: 1) chunk: 0.
	endNodeArray := (table dataOfColumns: 2) chunk: 0.

	FMShouldCheckForDuplicatedEntitiesInMultivalueLinks
		value: false
		during: [
			0 to: table numberOfRows - 1 do: [ :index |
				((entitiesMap at: (startNodeArray at: index)) mooseDescription
					 propertyNamed: (typeArray at: index) asSymbol) isMultivalued
					ifTrue: [
						((entitiesMap at: (startNodeArray at: index)) perform:
							 (typeArray at: index) asSymbol) add:
							(entitiesMap at: (endNodeArray at: index)) ]
					ifFalse: [
						(entitiesMap at: (startNodeArray at: index))
							perform: (typeArray at: index) asSymbol asMutator
							with: (entitiesMap at: (endNodeArray at: index)) ] ] ]
]

{ #category : 'metadata' }
MooseParquetImporter >> importMetadata [
	^ self importMetadataFrom: self metadataFileReference
]

{ #category : 'metadata' }
MooseParquetImporter >> importMetadataFrom: aFileReference [
	| fileReference |
	fileReference := aFileReference asFileReference.
	fileReference exists ifFalse: [
		metadata := Dictionary new.
		^ metadata ].
	metadata := self parseMetadataFrom: fileReference contents.
	self applyMetadata.
	^ metadata
]

{ #category : 'initialization' }
MooseParquetImporter >> initialize [
	super initialize.
	entitiesMap := Dictionary new.
	metadata := Dictionary new
]

{ #category : 'accessing' }
MooseParquetImporter >> metadata [
	^ metadata
]

{ #category : 'accessing' }
MooseParquetImporter >> metadata: aDictionary [
	metadata := self normalizedMetadataFrom: aDictionary.
	self applyMetadata
]

{ #category : 'accessing' }
MooseParquetImporter >> metadataAt: aSymbol [
	^ metadata at: aSymbol ifAbsent: [ nil ]
]

{ #category : 'accessing' }
MooseParquetImporter >> metadataDate [
	^ self metadataAt: #date
]

{ #category : 'metadata' }
MooseParquetImporter >> metadataFields [
	^ #(name importer date version)
]

{ #category : 'metadata' }
MooseParquetImporter >> metadataFileReference [
	^ FileLocator documents / 'metadata.json'
]

{ #category : 'accessing' }
MooseParquetImporter >> metadataImporter [
	^ self metadataAt: #importer
]

{ #category : 'accessing' }
MooseParquetImporter >> metadataName [
	^ self metadataAt: #name
]

{ #category : 'accessing' }
MooseParquetImporter >> metadataVersion [
	^ self metadataAt: #version
]

{ #category : 'accessing' }
MooseParquetImporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetImporter >> model: anObject [

	model := anObject
]

{ #category : 'metadata' }
MooseParquetImporter >> normalizedMetadataFrom: anObject [
	| normalized |
	normalized := Dictionary new.
	(anObject respondsTo: #at:ifPresent:ifAbsent:) ifFalse: [ ^ normalized ].
	self metadataFields do: [ :field |
		anObject
			at: field asString
			ifPresent: [ :value | normalized at: field put: value ]
			ifAbsent: [
				anObject
					at: field
					ifPresent: [ :value | normalized at: field put: value ]
					ifAbsent: [ ] ] ].
	^ normalized
]

{ #category : 'metadata' }
MooseParquetImporter >> parseMetadataFrom: aString [
	| parsed |
	aString ifNil: [ ^ Dictionary new ].
	aString trimBoth ifEmpty: [ ^ Dictionary new ].
	parsed := NeoJSONReader fromString: aString.
	^ self normalizedMetadataFrom: parsed
]
