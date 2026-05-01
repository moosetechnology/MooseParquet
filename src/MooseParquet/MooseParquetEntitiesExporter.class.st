Class {
	#name : 'MooseParquetEntitiesExporter',
	#superclass : 'Object',
	#traits : 'TMooseParquetExporter',
	#classTraits : 'TMooseParquetExporter classTrait',
	#instVars : [
		'model',
		'idBuilder',
		'labelBuilder',
		'columns',
		'schema'
	],
	#category : 'MooseParquet-ParquetExporter',
	#package : 'MooseParquet',
	#tag : 'ParquetExporter'
}

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> archiveMemberName [

	^ MooseParquetArchive entitiesMemberName
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> columns [

	^ columns
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> defaultFileReference [

	^ FileLocator documents / 'entities.parquet'
]

{ #category : 'api' }
MooseParquetEntitiesExporter >> export [
	"Perform entities export"

	self prepareSchema.
	self prepareBuilder.
	self model entities do: [ :entity | self exportEntity: entity ].
	self finishBuilder.
	self outputTable
]

{ #category : 'exporting' }
MooseParquetEntitiesExporter >> exportEntity: entity [

	idBuilder append: entity mooseID.
	labelBuilder append: entity mooseDescription fullName
]

{ #category : 'exporting' }
MooseParquetEntitiesExporter >> finishBuilder [

	| idArray labelArray |
	idArray := idBuilder finish.

	labelArray := labelBuilder finish.
	columns := nil.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: idArray.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: labelArray.
	^ columns
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> model: anObject [

	model := anObject
]

{ #category : 'exporting' }
MooseParquetEntitiesExporter >> outputTable [

	^ self outputTableToFile: self defaultFileReference
]

{ #category : 'exporting' }
MooseParquetEntitiesExporter >> prepareBuilder [

	idBuilder := PharoArrowLibrary uniqueInstance
		             garrow_int64_array_builder_new.
	labelBuilder := PharoArrowLibrary uniqueInstance
		                garrow_string_array_builder_new
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> prepareSchema [
	"Perform entities export"

	| strType intType idField label fields |
	"prepare schema"
	strType := PharoArrowLibrary uniqueInstance
		           garrow_string_data_type_new.
	intType := PharoArrowLibrary uniqueInstance
		           garrow_int64_data_type_new.

	idField := PharoArrowLibrary uniqueInstance
		           garrow_field_new: 'id'
		           dataType: intType.
	label := PharoArrowLibrary uniqueInstance
		           garrow_field_new: 'label'
		           dataType: strType.
	fields := nil.
	fields := PharoGLibLibrary uniqueInstance g_list_append: fields with: idField.
	fields := PharoGLibLibrary uniqueInstance g_list_append: fields with: label.
	"arrow schema from our usage"
	schema := PharoArrowLibrary uniqueInstance garrow_schema_new: fields
]

{ #category : 'accessing' }
MooseParquetEntitiesExporter >> schema [

	^ schema
]
