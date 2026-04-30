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
TMooseParquetExporter >> prepareBuilder [

	self subclassResponsibility
]

{ #category : 'exporting' }
TMooseParquetExporter >> prepareSchema [

	self subclassResponsibility
]
