"
Tests for the .moosemodel ZIP container export and import.
"
Class {
	#name : 'MooseParquetModelFileTest',
	#superclass : 'TestCase',
	#instVars : [
		'tmpDirectory'
	],
	#category : 'MooseParquet-Tests-Archive',
	#package : 'MooseParquet-Tests',
	#tag : 'Archive'
}

{ #category : 'helpers' }
MooseParquetModelFileTest >> archiveFromSampleExport [

	^ MooseParquetArchive readFrom: self exportSampleModel
]

{ #category : 'helpers' }
MooseParquetModelFileTest >> exportSampleModel [

	| exporter |
	exporter := MooseParquetExporter new.
	exporter model: self sampleModel.
	^ exporter exportTo: self mooseModelFile
]

{ #category : 'helpers' }
MooseParquetModelFileTest >> mooseModelFile [

	^ tmpDirectory / 'sample.moosemodel'
]

{ #category : 'helpers' }
MooseParquetModelFileTest >> sampleModel [

	| model entity nameProperty |
	model := MooseParquetTestModel new.
	model name: 'Sample model'.
	entity := MooseParquetTestEntity id: 1 label: 'Sample.Entity'.
	nameProperty := MooseParquetTestProperty
		                named: #name
		                type: MooseParquetTestType string.
	entity addProperty: nameProperty value: 'alpha'.
	model add: entity.
	^ model
]

{ #category : 'running' }
MooseParquetModelFileTest >> setUp [

	super setUp.
	tmpDirectory := FileLocator temp
	                / ('moosemodel_test_' , UUID new asString).
	tmpDirectory ensureCreateDirectory
]

{ #category : 'running' }
MooseParquetModelFileTest >> tearDown [

	tmpDirectory ifNotNil: [ tmpDirectory ensureDeleteAll ].
	super tearDown
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testExportToCreatesExpectedZipEntries [

	| archive |
	archive := self archiveFromSampleExport.
	self assert: self mooseModelFile exists.
	self
		assert: archive memberNames asSet
		equals: MooseParquetArchive requiredMemberNames asSet
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testExportToDoesNotCreateParquetFilesNextToArchive [

	self exportSampleModel.
	self assert:
		(tmpDirectory children select: [ :each | each extension = 'parquet' ])
			isEmpty
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testExportedParquetsAreReadableFromMemory [

	| archive entitiesTable propertiesTable relationshipsTable |
	archive := self archiveFromSampleExport.
	entitiesTable := MooseParquetArrowMemory tableFromParquetBytes:
		                 (MooseParquetArchive
			                  binaryContentsOf:
			                  MooseParquetArchive entitiesMemberName
			                  in: archive).
	propertiesTable := MooseParquetArrowMemory tableFromParquetBytes:
		                   (MooseParquetArchive
			                    binaryContentsOf:
			                    MooseParquetArchive
				                    entitiesPropertiesMemberName
			                    in: archive).
	relationshipsTable := MooseParquetArrowMemory tableFromParquetBytes:
		                      (MooseParquetArchive
			                       binaryContentsOf:
			                       MooseParquetArchive relationshipsMemberName
			                       in: archive).
	self assert: entitiesTable numberOfRows equals: 1.
	self assert: propertiesTable numberOfRows equals: 1.
	self assert: relationshipsTable numberOfRows equals: 0
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testImportFromSignalsInvalidMetadata [

	| archive file importer exception |
	archive := self archiveFromSampleExport.
	archive setContentsOf: MooseParquetArchive metadataFileName to: '{'.
	file := tmpDirectory / 'invalid-metadata.moosemodel'.
	archive writeToFile: file.
	importer := MooseParquetImporter new.
	importer model: MooseParquetTestModel new.
	exception := [
	             importer importFrom: file.
	             nil ]
		             on: Error
		             do: [ :error | error ].
	self assert:
		(exception messageText includesSubstring: 'metadata.json')
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testImportFromSignalsInvalidZip [

	| file importer exception |
	file := tmpDirectory / 'invalid.moosemodel'.
	file writeStreamDo: [ :stream | stream nextPutAll: 'not a zip' ].
	importer := MooseParquetImporter new.
	importer model: MooseParquetTestModel new.
	exception := [
	             importer importFrom: file.
	             nil ]
		             on: Error
		             do: [ :error | error ].
	self assert:
		(exception messageText includesSubstring: 'Invalid .moosemodel ZIP')
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testImportFromSignalsMissingManifest [

	| archive file importer exception |
	file := tmpDirectory / 'missing-manifest.moosemodel'.
	archive := ZipArchive new.
	archive addString: '{}' as: MooseParquetArchive metadataFileName.
	archive writeToFile: file.
	importer := MooseParquetImporter new.
	importer model: MooseParquetTestModel new.
	exception := [
	             importer importFrom: file.
	             nil ]
		             on: Error
		             do: [ :error | error ].
	self assert:
		(exception messageText includesSubstring: 'manifest.json')
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testImportFromSignalsMissingParquetEntry [

	| archive file importer exception |
	file := tmpDirectory / 'missing-parquet.moosemodel'.
	archive := ZipArchive new.
	archive
		addString: MooseParquetArchive manifestJSON
		as: MooseParquetArchive manifestFileName.
	archive addString: '{}' as: MooseParquetArchive metadataFileName.
	archive addString: '' as: MooseParquetArchive entitiesMemberName.
	archive
		addString: ''
		as: MooseParquetArchive entitiesPropertiesMemberName.
	archive writeToFile: file.
	importer := MooseParquetImporter new.
	importer model: MooseParquetTestModel new.
	exception := [
	             importer importFrom: file.
	             nil ]
		             on: Error
		             do: [ :error | error ].
	self assert: (exception messageText includesSubstring:
			 MooseParquetArchive relationshipsMemberName)
]

{ #category : 'tests' }
MooseParquetModelFileTest >> testRoundTripSmallModel [

	| importedModel importer importedEntity |
	importedModel := MooseParquetTestModel new.
	importer := MooseParquetImporter new.
	importer model: importedModel.
	importer importFrom: self exportSampleModel.
	self assert: importedModel name equals: 'Sample model'.
	self assert: importedModel entities size equals: 1.
	importedEntity := importedModel entities first.
	self assert: (importedEntity propertyNamed: #name) equals: 'alpha'
]
