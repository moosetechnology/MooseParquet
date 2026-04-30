Class {
	#name : 'MooseParquetEntitiesExporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'exporter',
		'idBuilder',
		'labelBuilder',
		'entity'
	],
	#category : 'MooseParquet-Tests-Exporters',
	#package : 'MooseParquet-Tests',
	#tag : 'Exporters'
}

{ #category : 'running' }
MooseParquetEntitiesExporterTest >> setUp [

	super setUp.
	exporter := MooseParquetEntitiesExporter new.
	idBuilder := MooseParquetTestBuilder new.
	labelBuilder := MooseParquetTestBuilder new.
	exporter instVarNamed: 'idBuilder' put: idBuilder.
	exporter instVarNamed: 'labelBuilder' put: labelBuilder.
	entity := MooseParquetTestEntity id: 42 label: 'FamixJavaClass'
]

{ #category : 'tests' }
MooseParquetEntitiesExporterTest >> testExportEntityAppendsEntityFullName [

	exporter exportEntity: entity.
	self assert: labelBuilder values equals: #( 'FamixJavaClass' )
]

{ #category : 'tests' }
MooseParquetEntitiesExporterTest >> testExportEntityAppendsMooseID [

	exporter exportEntity: entity.
	self assert: idBuilder values equals: #( 42 )
]

{ #category : 'tests' }
MooseParquetEntitiesExporterTest >> testExportEntityCanBeCalledForSeveralEntities [

	| second |
	second := MooseParquetTestEntity id: 99 label: 'FamixJavaMethod'.
	exporter exportEntity: entity.
	exporter exportEntity: second.
	self assert: idBuilder values equals: #( 42 99 ).
	self
		assert: labelBuilder values
		equals: #( 'FamixJavaClass' 'FamixJavaMethod' )
]

{ #category : 'tests' }
MooseParquetEntitiesExporterTest >> testModelAccessor [

	| model |
	model := Object new.
	exporter model: model.
	self assert: exporter model identicalTo: model
]
