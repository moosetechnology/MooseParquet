Trait {
	#name : 'TMooseParquetExporter',
	#category : 'MooseParquet-ParquetExporter',
	#package : 'MooseParquet',
	#tag : 'ParquetExporter'
}

{ #category : 'exporting' }
TMooseParquetExporter >> exportEntity: entity [

	self subclassResponsibility
]

{ #category : 'exporting' }
TMooseParquetExporter >> finishBuilder [

	self subclassResponsibility
]

{ #category : 'exporting' }
TMooseParquetExporter >> outputTable [

	self subclassResponsibility
]

{ #category : 'exporting' }
TMooseParquetExporter >> outputTableToFile: aFileReference [

	aFileReference asFileReference binaryWriteStreamDo: [ :stream |
		stream nextPutAll: self parquetBytes ].
	^ aFileReference asFileReference
]

{ #category : 'exporting' }
TMooseParquetExporter >> parquetBytes [

	^ MooseParquetArrowMemory
		  parquetBytesFromTable: self table
		  schema: self schema
]

{ #category : 'exporting' }
TMooseParquetExporter >> prepareBuilder [

	self subclassResponsibility
]

{ #category : 'exporting' }
TMooseParquetExporter >> prepareSchema [

	self subclassResponsibility
]

{ #category : 'exporting' }
TMooseParquetExporter >> table [

	self columns ifNil: [ self finishBuilder ].
	^ PharoArrowLibrary uniqueInstance
		  garrow_table_new_values: self schema
		  values: self columns
		  error: nil
]
