Class {
	#name : 'MooseParquetRelationshipsExporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'exporter',
		'typeBuilder',
		'startNodeBuilder',
		'endNodeBuilder',
		'sourceEntity',
		'targetEntity',
		'otherEntity',
		'relationshipProperty',
		'singleRelationshipProperty',
		'scalarProperty',
		'missingRelationshipProperty',
		'derivedRelationshipProperty'
	],
	#category : 'MooseParquet-Tests-Exporters',
	#package : 'MooseParquet-Tests',
	#tag : 'Exporters'
}

{ #category : 'helpers' }
MooseParquetRelationshipsExporterTest >> relationNamesExportedFrom: anEntity [
	^ (exporter relationsToExport: anEntity) collect: [ :each | each second name ]
]

{ #category : 'running' }
MooseParquetRelationshipsExporterTest >> setUp [
	super setUp.
	exporter := MooseParquetRelationshipsExporter new.
	typeBuilder := MooseParquetTestBuilder new.
	startNodeBuilder := MooseParquetTestBuilder new.
	endNodeBuilder := MooseParquetTestBuilder new.
	exporter instVarNamed: 'typeBuilder' put: typeBuilder.
	exporter instVarNamed: 'startNodeBuilder' put: startNodeBuilder.
	exporter instVarNamed: 'endNodeBuilder' put: endNodeBuilder.
	sourceEntity := MooseParquetTestEntity id: 1 label: 'Source'.
	targetEntity := MooseParquetTestEntity id: 2 label: 'Target'.
	otherEntity := MooseParquetTestEntity id: 3 label: 'Other'.
	relationshipProperty := MooseParquetTestProperty named: #children type: MooseParquetTestType object.
	relationshipProperty hasOpposite: true.
	relationshipProperty isMultivalued: true.
	singleRelationshipProperty := MooseParquetTestProperty named: #parent type: MooseParquetTestType object.
	singleRelationshipProperty hasOpposite: true.
	scalarProperty := MooseParquetTestProperty named: #name type: MooseParquetTestType string.
	missingRelationshipProperty := MooseParquetTestProperty named: #missingRelation type: MooseParquetTestType object.
	missingRelationshipProperty hasOpposite: true.
	derivedRelationshipProperty := MooseParquetTestProperty named: #computedRelation type: MooseParquetTestType object.
	derivedRelationshipProperty hasOpposite: true.
	derivedRelationshipProperty isDerived: true
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testExportEntityAppendsRelationshipTypeAndNodeIds [
	sourceEntity addProperty: relationshipProperty value: { targetEntity. otherEntity }.
	exporter exportEntity: sourceEntity.
	self assert: typeBuilder values equals: #(children children).
	self assert: startNodeBuilder values equals: #(1 1).
	self assert: endNodeBuilder values equals: #(2 3)
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testModelAccessor [
	| model |
	model := Object new.
	exporter model: model.
	self assert: exporter model identicalTo: model
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testRelationsToExportExpandsCollectionRelationships [
	| relations targets |
	sourceEntity addProperty: relationshipProperty value: { targetEntity. otherEntity }.
	relations := exporter relationsToExport: sourceEntity.
	targets := relations collect: [ :each | each third ].
	self assert: relations size equals: 2.
	self assert: targets asArray equals: { targetEntity. otherEntity }
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testRelationsToExportIncludesSingleRelationship [
	| relations |
	sourceEntity addProperty: singleRelationshipProperty value: targetEntity.
	relations := exporter relationsToExport: sourceEntity.
	self assert: relations size equals: 1.
	self assert: relations first first identicalTo: sourceEntity.
	self assert: relations first second identicalTo: singleRelationshipProperty.
	self assert: relations first third identicalTo: targetEntity
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testRelationsToExportKeepsRelationshipNames [
	sourceEntity addProperty: relationshipProperty value: { targetEntity. otherEntity }.
	self assert: (self relationNamesExportedFrom: sourceEntity) asArray equals: #(children children)
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testRelationsToExportRejectsDerivedRelationships [
	sourceEntity addProperty: derivedRelationshipProperty value: targetEntity.
	self assert: (exporter relationsToExport: sourceEntity) isEmpty
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testRelationsToExportRejectsMissingValues [
	sourceEntity declareProperty: missingRelationshipProperty.
	self assert: (exporter relationsToExport: sourceEntity) isEmpty
]

{ #category : 'tests' }
MooseParquetRelationshipsExporterTest >> testRelationsToExportRejectsScalarProperties [
	sourceEntity addProperty: scalarProperty value: 'Source'.
	self assert: (exporter relationsToExport: sourceEntity) isEmpty
]
