Class {
	#name : 'MooseParquetImporterTest',
	#superclass : 'TestCase',
	#category : 'MooseParquet-Tests-Importers',
	#package : 'MooseParquet-Tests',
	#tag : 'Importers'
}

{ #category : 'tests' }
MooseParquetImporterTest >> testImporterExposesImportSteps [
	| importer |
	importer := MooseParquetImporter new.
	self assert: (importer respondsTo: #importEntities).
	self assert: (importer respondsTo: #importEntitiesProperties).
	self assert: (importer respondsTo: #importEntitiesRelationships)
]

{ #category : 'tests' }
MooseParquetImporterTest >> testInitializeCreatesEmptyEntityMap [
	| importer entitiesMap |
	importer := MooseParquetImporter new.
	entitiesMap := importer instVarNamed: 'entitiesMap'.
	self assert: entitiesMap isDictionary.
	self assert: entitiesMap isEmpty
]

{ #category : 'tests' }
MooseParquetImporterTest >> testModelAccessor [
	| importer model |
	importer := MooseParquetImporter new.
	model := Object new.
	importer model: model.
	self assert: importer model identicalTo: model
]
