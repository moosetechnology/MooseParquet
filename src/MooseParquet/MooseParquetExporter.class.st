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

	| exporters |
	exporters := {
		             MooseParquetEntitiesExporter new.
		             MooseParquetEntitiesPropertiesExporter new.
		             MooseParquetRelationshipsExporter new }.
	exporters do: [ :exporter |
		exporter prepareSchema.
		exporter prepareBuilder ].
	self model entities do: [ :entity |
		exporters do: [ :exporter | exporter exportEntity: entity ] ].
	exporters do: [ :exporter |
		exporter
			finishBuilder;
			outputTable ]
]

{ #category : 'accessing' }
MooseParquetExporter >> model [
	^ model
]

{ #category : 'accessing' }
MooseParquetExporter >> model: aModel [

	model := aModel
]
