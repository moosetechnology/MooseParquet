Class {
	#name : 'MooseParquetRelationshipsExporter',
	#superclass : 'Object',
	#traits : 'TMooseParquetExporter',
	#classTraits : 'TMooseParquetExporter classTrait',
	#instVars : [
		'model',
		'typeBuilder',
		'startNodeBuilder',
		'endNodeBuilder',
		'columns',
		'schema'
	],
	#category : 'MooseParquet-ParquetExporter',
	#package : 'MooseParquet',
	#tag : 'ParquetExporter'
}

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> archiveMemberName [

	^ MooseParquetArchive relationshipsMemberName
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> columns [

	^ columns
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> defaultFileReference [

	^ FileLocator documents / 'relationships.parquet'
]

{ #category : 'api' }
MooseParquetRelationshipsExporter >> export [
	"Perform relationships export"

	self prepareSchema.
	self prepareBuilder.
	self model entities do: [ :entity | self exportEntity: entity ].
	self finishBuilder.
	self outputTable
]

{ #category : 'exporting' }
MooseParquetRelationshipsExporter >> exportEntity: entity [

	(self relationsToExport: entity) do: [ :rel |
		typeBuilder append: rel second name.
		startNodeBuilder append: rel first mooseID.
		endNodeBuilder append: rel third mooseID ]
]

{ #category : 'exporting' }
MooseParquetRelationshipsExporter >> finishBuilder [

	| typeArray startNodeArray endNodeArray |
	typeArray := typeBuilder finish.
	startNodeArray := startNodeBuilder finish.
	endNodeArray := endNodeBuilder finish.
	"have columns in my memory"
	columns := nil.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: typeArray.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: startNodeArray.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: endNodeArray.
	^ columns
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> model: anObject [

	model := anObject
]

{ #category : 'exporting' }
MooseParquetRelationshipsExporter >> outputTable [

	^ self outputTableToFile: self defaultFileReference
]

{ #category : 'exporting' }
MooseParquetRelationshipsExporter >> prepareBuilder [

	typeBuilder := PharoArrowLibrary uniqueInstance
		               garrow_string_array_builder_new.

	startNodeBuilder := PharoArrowLibrary uniqueInstance
		                    garrow_int64_array_builder_new.
	endNodeBuilder := PharoArrowLibrary uniqueInstance
		                  garrow_int64_array_builder_new
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> prepareSchema [
	"Perform entities export"

	| strType intType fields type startNode endNode |
	"prepare schema"
	strType := PharoArrowLibrary uniqueInstance
		           garrow_string_data_type_new.
	intType := PharoArrowLibrary uniqueInstance
		           garrow_int64_data_type_new.

	type := PharoArrowLibrary uniqueInstance
		        garrow_field_new: 'type'
		        dataType: strType.
	startNode := PharoArrowLibrary uniqueInstance
		             garrow_field_new: 'startNode'
		             dataType: intType.
	endNode := PharoArrowLibrary uniqueInstance
		           garrow_field_new: 'endNode'
		           dataType: intType.

	fields := nil.
	fields := PharoGLibLibrary uniqueInstance
		          g_list_append: fields
		          with: type.
	fields := PharoGLibLibrary uniqueInstance
		          g_list_append: fields
		          with: startNode.
	fields := PharoGLibLibrary uniqueInstance
		          g_list_append: fields
		          with: endNode.
	"arrow schema from our usage"
	schema := PharoArrowLibrary uniqueInstance garrow_schema_new: fields
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> relationsToExport: entity [

	| col |
	col := OrderedCollection new.

	entity allDeclaredProperties
		reject: [ :property |
			property isDerived or: [
				property hasOpposite not or: [
					(entity propertyNamed: property name ifAbsent: [ nil ]) isNil ] ] ]
		thenDo: [ :property |
			(entity propertyNamed: property name) isCollection
				ifTrue: [
					(entity propertyNamed: property name) do: [ :value |
						col add: {
								entity.
								property.
								value } ] ]
				ifFalse: [
					col add: {
							entity.
							property.
							(entity propertyNamed: property name) } ] ].
	^ col
]

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> schema [

	^ schema
]
