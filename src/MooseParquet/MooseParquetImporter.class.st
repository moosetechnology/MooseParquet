Class {
	#name : 'MooseParquetImporter',
	#superclass : 'Object',
	#instVars : [
		'model',
		'entitiesMap'
	],
	#category : 'MooseParquet-ParquetImporter',
	#package : 'MooseParquet',
	#tag : 'ParquetImporter'
}

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

{ #category : 'initialization' }
MooseParquetImporter >> initialize [

	super initialize.
	entitiesMap := Dictionary new
]

{ #category : 'accessing' }
MooseParquetImporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetImporter >> model: anObject [

	model := anObject
]
