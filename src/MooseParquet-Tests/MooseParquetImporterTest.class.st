Class {
	#name : 'MooseParquetImporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'tmpDirectory'
	],
	#category : 'MooseParquet-Tests-Importers',
	#package : 'MooseParquet-Tests',
	#tag : 'Importers'
}

{ #category : 'helpers' }
MooseParquetImporterTest >> metadataFile [
	^ tmpDirectory / 'metadata.json'
]

{ #category : 'running' }
MooseParquetImporterTest >> setUp [
	super setUp.
	tmpDirectory := FileLocator temp / ('mooseparquet_test_' , UUID new asString).
	tmpDirectory ensureCreateDirectory
]

{ #category : 'running' }
MooseParquetImporterTest >> tearDown [
	tmpDirectory ifNotNil: [ tmpDirectory ensureDeleteAll ].
	super tearDown
]

{ #category : 'tests' }
MooseParquetImporterTest >> testImportMetadataAppliesNameToModelWhenPresent [
	| importer model |
	self writeMetadata: '{"name":"Serialized model"}'.
	model := MooseParquetTestModel new.
	importer := MooseParquetImporter new.
	importer model: model.
	importer importMetadataFrom: self metadataFile.
	self assert: model name equals: 'Serialized model'
]

{ #category : 'tests' }
MooseParquetImporterTest >> testImportMetadataDoesNotRequireModelNameSupport [
	| importer model |
	self writeMetadata: '{"name":"Serialized model"}'.
	model := Object new.
	importer := MooseParquetImporter new.
	importer model: model.
	self shouldnt: [ importer importMetadataFrom: self metadataFile ] raise: Error.
	self assert: importer metadataName equals: 'Serialized model'
]

{ #category : 'tests' }
MooseParquetImporterTest >> testImportMetadataReadsMetadataJsonFile [
	| importer metadata |
	self writeMetadata: '{"name":"Demo","version":"1.0"}'.
	importer := MooseParquetImporter new.
	metadata := importer importMetadataFrom: self metadataFile.
	self assert: (metadata at: #name) equals: 'Demo'.
	self assert: (metadata at: #version) equals: '1.0'.
	self assert: importer metadata equals: metadata
]

{ #category : 'tests' }
MooseParquetImporterTest >> testImportMetadataUsesEmptyDictionaryWhenFileIsMissing [
	| importer metadata |
	importer := MooseParquetImporter new.
	metadata := importer importMetadataFrom: self metadataFile.
	self assert: metadata isEmpty.
	self assert: importer metadata isEmpty
]

{ #category : 'tests' }
MooseParquetImporterTest >> testImportRunsMetadataBeforeParquetSteps [
	| importer |
	importer := MooseParquetImportOrderRecorder new.
	importer import.
	self assert: importer steps equals: #(metadata entities properties relationships)
]

{ #category : 'tests' }
MooseParquetImporterTest >> testImporterExposesImportSteps [
	| importer |
	importer := MooseParquetImporter new.
	self assert: (importer respondsTo: #import).
	self assert: (importer respondsTo: #importMetadata).
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
MooseParquetImporterTest >> testInitializeCreatesEmptyMetadata [
	| importer |
	importer := MooseParquetImporter new.
	self assert: importer metadata isDictionary.
	self assert: importer metadata isEmpty
]

{ #category : 'tests' }
MooseParquetImporterTest >> testMetadataAccessorsExposeStoredFields [
	| importer |
	importer := MooseParquetImporter new.
	importer metadata: (Dictionary newFrom: {
		#name -> 'Demo'.
		#importer -> 'FamixJava'.
		#date -> '2026-04-30'.
		#version -> '1.0' }).
	self assert: importer metadataName equals: 'Demo'.
	self assert: importer metadataImporter equals: 'FamixJava'.
	self assert: importer metadataDate equals: '2026-04-30'.
	self assert: importer metadataVersion equals: '1.0'
]

{ #category : 'tests' }
MooseParquetImporterTest >> testMetadataFieldsContainsExpectedOptionalFields [
	self assert: MooseParquetImporter new metadataFields equals: #(name importer date version)
]

{ #category : 'tests' }
MooseParquetImporterTest >> testMetadataSetterAppliesNameToModel [
	| importer model |
	model := MooseParquetTestModel new.
	importer := MooseParquetImporter new.
	importer model: model.
	importer metadata: (Dictionary newFrom: { #name -> 'Named by metadata' }).
	self assert: model name equals: 'Named by metadata'
]

{ #category : 'tests' }
MooseParquetImporterTest >> testModelAccessor [
	| importer model |
	importer := MooseParquetImporter new.
	model := Object new.
	importer model: model.
	self assert: importer model identicalTo: model
]

{ #category : 'tests' }
MooseParquetImporterTest >> testParseMetadataAllowsEveryFieldToBeAbsent [
	| importer metadata |
	importer := MooseParquetImporter new.
	metadata := importer parseMetadataFrom: '{}'.
	self assert: metadata isEmpty
]

{ #category : 'tests' }
MooseParquetImporterTest >> testParseMetadataFromBlankStringReturnsEmptyDictionary [
	| importer |
	importer := MooseParquetImporter new.
	self assert: (importer parseMetadataFrom: '') isEmpty.
	self assert: (importer parseMetadataFrom: '   ') isEmpty
]

{ #category : 'tests' }
MooseParquetImporterTest >> testParseMetadataIgnoresUnknownFields [
	| importer metadata |
	importer := MooseParquetImporter new.
	metadata := importer parseMetadataFrom: '{"name":"Demo","unknown":"ignored"}'.
	self assert: metadata size equals: 1.
	self assert: (metadata at: #name) equals: 'Demo'.
	self deny: (metadata includesKey: #unknown)
]

{ #category : 'tests' }
MooseParquetImporterTest >> testParseMetadataKeepsAllSupportedFields [
	| importer metadata |
	importer := MooseParquetImporter new.
	metadata := importer parseMetadataFrom: '{"name":"Demo","importer":"FamixJava","date":"2026-04-30","version":"1.0"}'.
	self assert: (metadata at: #name) equals: 'Demo'.
	self assert: (metadata at: #importer) equals: 'FamixJava'.
	self assert: (metadata at: #date) equals: '2026-04-30'.
	self assert: (metadata at: #version) equals: '1.0'
]

{ #category : 'helpers' }
MooseParquetImporterTest >> writeMetadata: aString [
	self metadataFile writeStreamDo: [ :stream |
		stream nextPutAll: aString ]
]
