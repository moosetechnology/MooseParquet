Class {
	#name : 'MooseParquetEntitiesPropertiesExporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'exporter',
		'nodeIDBuilder',
		'keyBuilder',
		'valueTypeBuilder',
		'valueStrBuilder',
		'valueIntBuilder',
		'valueFloatBuilder',
		'valueBoolBuilder',
		'entity',
		'stringProperty',
		'numberProperty',
		'booleanProperty'
	],
	#category : 'MooseParquet-Tests-Exporters',
	#package : 'MooseParquet-Tests',
	#tag : 'Exporters'
}

{ #category : 'helpers' }
MooseParquetEntitiesPropertiesExporterTest >> propertyNamesExportedFrom: anEntity [
	^ (exporter propertiesOfToExport: anEntity) collect: [ :each | each name ]
]

{ #category : 'running' }
MooseParquetEntitiesPropertiesExporterTest >> setUp [
	super setUp.
	exporter := MooseParquetEntitiesPropertiesExporter new.
	nodeIDBuilder := MooseParquetTestBuilder new.
	keyBuilder := MooseParquetTestBuilder new.
	valueTypeBuilder := MooseParquetTestBuilder new.
	valueStrBuilder := MooseParquetTestBuilder new.
	valueIntBuilder := MooseParquetTestBuilder new.
	valueFloatBuilder := MooseParquetTestBuilder new.
	valueBoolBuilder := MooseParquetTestBuilder new.
	exporter instVarNamed: 'nodeIDBuilder' put: nodeIDBuilder.
	exporter instVarNamed: 'keyBuilder' put: keyBuilder.
	exporter instVarNamed: 'valueTypeBuilder' put: valueTypeBuilder.
	exporter instVarNamed: 'valueStrBuilder' put: valueStrBuilder.
	exporter instVarNamed: 'valueIntBuilder' put: valueIntBuilder.
	exporter instVarNamed: 'valueFloatBuilder' put: valueFloatBuilder.
	exporter instVarNamed: 'valueBoolBuilder' put: valueBoolBuilder.
	stringProperty := MooseParquetTestProperty named: #name type: MooseParquetTestType string.
	numberProperty := MooseParquetTestProperty named: #size type: MooseParquetTestType number.
	booleanProperty := MooseParquetTestProperty named: #stub type: MooseParquetTestType boolean.
	entity := MooseParquetTestEntity id: 7 label: 'FamixJavaMethod'.
	entity addProperty: stringProperty value: 'parse'.
	entity addProperty: numberProperty value: 12.5.
	entity addProperty: booleanProperty value: true
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testExportEntityAppendsNodeIdsAndPropertyNames [
	exporter exportEntity: entity.
	self assert: nodeIDBuilder values equals: #(7 7 7).
	self assert: keyBuilder values equals: #(name size stub)
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testExportEntityRoutesValuesByType [
	exporter exportEntity: entity.
	self assert: valueTypeBuilder values equals: #(0 2 3).
	self assert: valueStrBuilder values equals: { 'parse'. nil. nil }.
	self assert: valueFloatBuilder values equals: { nil. 12.5. nil }.
	self assert: valueBoolBuilder values equals: { nil. nil. true }
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testFillBooleanPropertyAppendsBooleanTypeAndNulls [
	exporter fillBooleanProperty: booleanProperty forEntity: entity.
	self assert: valueTypeBuilder values equals: #(3).
	self assert: valueStrBuilder values equals: { nil }.
	self assert: valueIntBuilder values equals: { nil }.
	self assert: valueFloatBuilder values equals: { nil }.
	self assert: valueBoolBuilder values equals: #(true)
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testFillFloatPropertyAppendsFloatTypeAndNulls [
	exporter fillFloatProperty: numberProperty forEntity: entity.
	self assert: valueTypeBuilder values equals: #(2).
	self assert: valueStrBuilder values equals: { nil }.
	self assert: valueIntBuilder values equals: { nil }.
	self assert: valueFloatBuilder values equals: #(12.5).
	self assert: valueBoolBuilder values equals: { nil }
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testFillStringPropertyAppendsStringTypeAndNulls [
	exporter fillStringProperty: stringProperty forEntity: entity.
	self assert: valueTypeBuilder values equals: #(0).
	self assert: valueStrBuilder values equals: #('parse').
	self assert: valueIntBuilder values equals: { nil }.
	self assert: valueFloatBuilder values equals: { nil }.
	self assert: valueBoolBuilder values equals: { nil }
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testModelAccessor [
	| model |
	model := Object new.
	exporter model: model.
	self assert: exporter model identicalTo: model
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testPropertiesOfToExportIncludesScalarProperties [
	self assert: (self propertyNamesExportedFrom: entity) equals: #(name size stub)
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testPropertiesOfToExportRejectsDerivedProperties [
	| derivedEntity derivedProperty |
	derivedEntity := MooseParquetTestEntity id: 1 label: 'Entity'.
	derivedProperty := MooseParquetTestProperty named: #derivedName type: MooseParquetTestType string.
	derivedProperty isDerived: true.
	derivedEntity addProperty: derivedProperty value: 'computed'.
	self assert: (exporter propertiesOfToExport: derivedEntity) isEmpty
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testPropertiesOfToExportRejectsEmptyCollections [
	| collectionEntity collectionProperty |
	collectionEntity := MooseParquetTestEntity id: 1 label: 'Entity'.
	collectionProperty := MooseParquetTestProperty named: #tags type: MooseParquetTestType string.
	collectionEntity addProperty: collectionProperty value: #().
	self assert: (exporter propertiesOfToExport: collectionEntity) isEmpty
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testPropertiesOfToExportRejectsMissingValues [
	| missingEntity missingProperty |
	missingEntity := MooseParquetTestEntity id: 1 label: 'Entity'.
	missingProperty := MooseParquetTestProperty named: #missing type: MooseParquetTestType string.
	missingEntity declareProperty: missingProperty.
	self assert: (exporter propertiesOfToExport: missingEntity) isEmpty
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testPropertiesOfToExportRejectsObjectType [
	| objectEntity objectProperty |
	objectEntity := MooseParquetTestEntity id: 1 label: 'Entity'.
	objectProperty := MooseParquetTestProperty named: #rawObject type: MooseParquetTestType object.
	objectEntity addProperty: objectProperty value: Object new.
	self assert: (exporter propertiesOfToExport: objectEntity) isEmpty
]

{ #category : 'tests' }
MooseParquetEntitiesPropertiesExporterTest >> testPropertiesOfToExportRejectsOppositeProperties [
	| relationEntity relationProperty |
	relationEntity := MooseParquetTestEntity id: 1 label: 'Entity'.
	relationProperty := MooseParquetTestProperty named: #parent type: MooseParquetTestType object.
	relationProperty hasOpposite: true.
	relationEntity addProperty: relationProperty value: Object new.
	self assert: (exporter propertiesOfToExport: relationEntity) isEmpty
]
