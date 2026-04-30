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

{ #category : 'api' }
MooseParquetRelationshipsExporter >> export [
	"Perform entities export"

	| writer table |
	"prepare schema"
	self prepareSchema.
	self prepareBuilder.
	self model entities do: [ :entity | self exportEntity: entity ].
	self finishBuilder.
	"create table"
	table := PharoArrowLibrary uniqueInstance
		         garrow_table_new_values: schema
		         values: columns
		         error: nil.
	"write the file now"
	writer := PharoParquetLibrary uniqueInstance
		          gparquet_arrow_file_writer_new_path: schema
		          path:
		          (FileLocator documents / 'relationships.parquet') fullName
		          writerProperties: nil
		          error: nil.
	PharoParquetLibrary uniqueInstance
		gparquet_arrow_file_writer_write_table: writer
		table: table
		chunkSize: 10000
		error: nil.

	"if everything goes well, you can close the writer here"
	PharoParquetLibrary uniqueInstance
		gparquet_arrow_file_writer_close: writer
		error: nil
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

{ #category : 'accessing' }
MooseParquetRelationshipsExporter >> outputTable [

	| writer table |
	"create table"
	table := PharoArrowLibrary uniqueInstance
		         garrow_table_new_values: schema
		         values: columns
		         error: nil.
	"write the file now"
	writer := PharoParquetLibrary uniqueInstance
		          gparquet_arrow_file_writer_new_path: schema
		          path:
		          (FileLocator documents / 'relationships.parquet') fullName
		          writerProperties: nil
		          error: nil.
	PharoParquetLibrary uniqueInstance
		gparquet_arrow_file_writer_write_table: writer
		table: table
		chunkSize: 10000
		error: nil.

	"if everything goes well, you can close the writer here"
	PharoParquetLibrary uniqueInstance
		gparquet_arrow_file_writer_close: writer
		error: nil
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
