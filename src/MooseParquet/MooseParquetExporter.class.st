"
I am a utility that takes as input a Moose Model and ouput `.parquet` files.

I export two files

- `entities.parquet` that contains all the Nodes (including reified association)
- `relationships.parquet` that contains the link between the Nodes

## Generate a moose model

```st
exporter := MooseParquetExporter new.
exporter model: MooseModel root anyOne.
exporter export.

```
"
Class {
	#name : 'MooseParquetExporter',
	#superclass : 'Object',
	#instVars : [
		'model',
		'arrowLibrary',
		'gLibrary',
		'parquetLibrary',
		'listStringType'
	],
	#category : 'MooseParquet-ParquetExporter',
	#package : 'MooseParquet',
	#tag : 'ParquetExporter'
}

{ #category : 'public' }
MooseParquetExporter >> export [

	self preparedExporters do: [ :exporter | exporter outputTable ]
]

{ #category : 'public' }
MooseParquetExporter >> exportTo: aMooseModelFileReference [

	| stagingRoot preparedExporters |
	stagingRoot := FileSystem memory / 'moosemodel'.
	stagingRoot ensureCreateDirectory.
	MooseParquetArchive
		writeString: MooseParquetArchive manifestJSON
		toMember: MooseParquetArchive manifestFileName
		in: stagingRoot.
	MooseParquetArchive
		writeString: self metadataJSON
		toMember: MooseParquetArchive metadataFileName
		in: stagingRoot.
	preparedExporters := self preparedExporters.
	preparedExporters do: [ :exporter |
		MooseParquetArchive
			writeBytes: exporter parquetBytes
			toMember: exporter archiveMemberName
			in: stagingRoot ].
	^ MooseParquetArchive
		  writeStaging: stagingRoot
		  to: aMooseModelFileReference
]

{ #category : 'exporting' }
MooseParquetExporter >> exporters [

	^ {
		  (MooseParquetEntitiesExporter new
			   model: self model;
			   yourself).
		  (MooseParquetEntitiesPropertiesExporter new
			   model: self model;
			   yourself).
		  (MooseParquetRelationshipsExporter new
			   model: self model;
			   yourself) }
]

{ #category : 'metadata' }
MooseParquetExporter >> metadataDictionary [

	| dictionary |
	dictionary := Dictionary new.
	(model notNil and: [ model respondsTo: #name ]) ifTrue: [
		model name ifNotNil: [ :modelName |
			dictionary at: 'name' put: modelName ] ].
	dictionary
		at: 'version'
		put: MooseParquetArchive formatVersion asString.
	dictionary at: 'date' put: DateAndTime now asString.
	^ dictionary
]

{ #category : 'metadata' }
MooseParquetExporter >> metadataJSON [

	^ NeoJSONWriter toString: self metadataDictionary
]

{ #category : 'accessing' }
MooseParquetExporter >> model [
	^ model
]

{ #category : 'accessing' }
MooseParquetExporter >> model: aModel [

	model := aModel
]

{ #category : 'exporting' }
MooseParquetExporter >> preparedExporters [

	| preparedExporters |
	preparedExporters := self exporters.
	preparedExporters do: [ :exporter |
		exporter prepareSchema.
		exporter prepareBuilder ].
	self model entities do: [ :entity |
		preparedExporters do: [ :exporter | exporter exportEntity: entity ] ].
	preparedExporters do: [ :exporter | exporter finishBuilder ].
	^ preparedExporters
]
