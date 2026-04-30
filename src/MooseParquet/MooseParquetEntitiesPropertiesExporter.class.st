Class {
	#name : 'MooseParquetEntitiesPropertiesExporter',
	#superclass : 'Object',
	#traits : 'TMooseParquetExporter',
	#classTraits : 'TMooseParquetExporter classTrait',
	#instVars : [
		'model',
		'keyBuilder',
		'valueTypeBuilder',
		'valueStrBuilder',
		'valueIntBuilder',
		'valueFloatBuilder',
		'valueBoolBuilder',
		'nodeIDBuilder',
		'columns',
		'schema'
	],
	#category : 'MooseParquet-ParquetExporter',
	#package : 'MooseParquet',
	#tag : 'ParquetExporter'
}

{ #category : 'api' }
MooseParquetEntitiesPropertiesExporter >> export [
	"Perform entities export"

	"prepare schema""create table""write the file now""if everything goes well, you can close the writer here"
	schema := self prepareSchema.
	valueBoolBuilder := self prepareBuilder.
	self model entities do: [ :entity | self exportEntity: entity ].
	columns := self finishBuilder.
	self outputTable
]

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> exportEntity: entity [
	"export the tabular"

	"Real logic is here""0 = string
			1 = int
			2 = float
			3 = bool""have columns in my memory"

	(self propertiesOfToExport: entity) do: [ :property |
		nodeIDBuilder append: entity mooseID.
		keyBuilder append: property name.
		(property type isKindOf: FM3String) ifTrue: [
			self fillStringProperty: property forEntity: entity ].
		(property type isKindOf: FM3Number) ifTrue: [
			self fillFloatProperty: property forEntity: entity ].
		(property type isKindOf: FM3Boolean) ifTrue: [
			self fillBooleanProperty: property forEntity: entity ] ]
]

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> fillBooleanProperty: property forEntity: entity [

	valueTypeBuilder append: 3.
	valueStrBuilder appendNull.
	valueIntBuilder appendNull.
	valueFloatBuilder appendNull.
	valueBoolBuilder append: (entity propertyNamed: property name)
]

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> fillFloatProperty: property forEntity: entity [

	valueTypeBuilder append: 2.
	valueStrBuilder appendNull.
	valueIntBuilder appendNull.
	valueFloatBuilder append: (entity propertyNamed: property name).
	valueBoolBuilder appendNull
]

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> fillStringProperty: property forEntity: entity [

	valueTypeBuilder append: 0.
	valueStrBuilder append: (entity propertyNamed: property name).
	valueIntBuilder appendNull.
	valueFloatBuilder appendNull.
	valueBoolBuilder appendNull
]

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> finishBuilder [

	| keyArray valueStrArray valueTypeArray nodeIDArray valueBoolArray valueIntArray valueFloatArray |
	nodeIDArray := nodeIDBuilder finish.
	keyArray := keyBuilder finish.
	valueTypeArray := valueTypeBuilder finish.
	valueStrArray := valueStrBuilder finish.
	valueIntArray := valueIntBuilder finish.
	valueFloatArray := valueFloatBuilder finish.
	valueBoolArray := valueBoolBuilder finish.
	columns := nil.
	columns := PharoGLibLibrary uniqueInstance
		           g_list_append: columns
		           with: nodeIDArray.
	columns := columns , keyArray , valueTypeArray , valueStrArray
	           , valueIntArray , valueFloatArray , valueBoolArray.
]

{ #category : 'accessing' }
MooseParquetEntitiesPropertiesExporter >> model [

	^ model
]

{ #category : 'accessing' }
MooseParquetEntitiesPropertiesExporter >> model: anObject [

	model := anObject
]

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> outputTable [

	| writer table |
	table := PharoArrowLibrary uniqueInstance
		         garrow_table_new_values: schema
		         values: columns
		         error: nil.
	"write the file now"
	writer := PharoParquetLibrary uniqueInstance
		          gparquet_arrow_file_writer_new_path: schema
		          path:
		          (FileLocator documents / 'entities_properties.parquet')
			          fullName
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

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> prepareBuilder [

	nodeIDBuilder := PharoArrowLibrary uniqueInstance
		                 garrow_int64_array_builder_new.
	keyBuilder := PharoArrowLibrary uniqueInstance
		              garrow_string_array_builder_new.
	valueTypeBuilder := PharoArrowLibrary uniqueInstance
		                    garrow_int8_array_builder_new.
	valueStrBuilder := PharoArrowLibrary uniqueInstance
		                   garrow_string_array_builder_new.
	valueIntBuilder := PharoArrowLibrary uniqueInstance
		                   garrow_int64_array_builder_new.
	valueFloatBuilder := PharoArrowLibrary uniqueInstance
		                     garrow_float_array_builder_new.
	valueBoolBuilder := PharoArrowLibrary uniqueInstance
		                    garrow_boolean_array_builder_new
]

{ #category : 'accessing' }
MooseParquetEntitiesPropertiesExporter >> prepareSchema [
	"Perform entities export"

	| strType int64Type idField key value_type fields int8Type value_str value_int value_float value_bool floatType boolType |
	"prepare schema"
	strType := PharoArrowLibrary uniqueInstance
		           garrow_string_data_type_new.
	int64Type := PharoArrowLibrary uniqueInstance
		             garrow_int64_data_type_new.
	int8Type := PharoArrowLibrary uniqueInstance
		            garrow_int8_data_type_new.
	floatType := PharoArrowLibrary uniqueInstance
		            garrow_float_data_type_new.
	boolType := PharoArrowLibrary uniqueInstance
		            garrow_boolean_data_type_new.

	idField := PharoArrowLibrary uniqueInstance
		           garrow_field_new: 'node_id'
		           dataType: int64Type.
	key := PharoArrowLibrary uniqueInstance
		       garrow_field_new: 'key'
		       dataType: strType.
	value_type := PharoArrowLibrary uniqueInstance
		              garrow_field_new: 'value_type'
		              dataType: int8Type.
	value_str := PharoArrowLibrary uniqueInstance
		             garrow_field_new: 'value_str'
		             dataType: strType.
	value_int := PharoArrowLibrary uniqueInstance
		             garrow_field_new: 'value_int'
		             dataType: int64Type.
	value_float := PharoArrowLibrary uniqueInstance
		               garrow_field_new: 'value_float'
		               dataType: floatType.
	value_bool := PharoArrowLibrary uniqueInstance
		              garrow_field_new: 'value_bool'
		              dataType: boolType.

	fields := nil.
	fields := PharoGLibLibrary uniqueInstance
		          g_list_append: fields
		          with: idField.
	fields := fields , key , value_type , value_str , value_int
	          , value_float , value_bool.
	"arrow schema from our usage"
	schema := PharoArrowLibrary uniqueInstance garrow_schema_new: fields
]

{ #category : 'as yet unclassified' }
MooseParquetEntitiesPropertiesExporter >> propertiesOfToExport: entity [

	^ entity allDeclaredProperties reject: [ :property |
		  property isDerived or: [
			  property hasOpposite or: [
				  (entity propertyNamed: property name ifAbsent: [ nil ]) isNil
					  or: [
						  property type name = #Object or: [
							  (entity propertyNamed: property name) isCollection and: [
								  (entity propertyNamed: property name) isEmpty ] ] ] ] ] ]
]
