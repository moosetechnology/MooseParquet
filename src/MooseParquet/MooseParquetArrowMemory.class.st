"
Utility methods that bridge Parquet GLib readers and writers with in-memory Arrow buffers.
"
Class {
	#name : 'MooseParquetArrowMemory',
	#superclass : 'Object',
	#category : 'MooseParquet-Support',
	#package : 'MooseParquet',
	#tag : 'Support'
}

{ #category : 'converting' }
MooseParquetArrowMemory class >> bufferFromByteArray: aByteArray [

	| bytes buffer |
	bytes := self
		         signalIfNull: (PharoGLibLibrary uniqueInstance
				          g_bytes_new: aByteArray
				          size: aByteArray size)
		         named: 'GBytes'.
	buffer := self
		          signalIfNull:
		          (PharoArrowLibrary uniqueInstance
			           garrow_buffer_new_bytes: bytes)
		          named: 'GArrowBuffer'.
	^ buffer
]

{ #category : 'converting' }
MooseParquetArrowMemory class >> byteArrayFromBuffer: buffer [

	| bytes sizeBuffer data size result |
	bytes := self
		         signalIfNull:
		         (PharoArrowLibrary uniqueInstance garrow_buffer_get_data:
			          buffer)
		         named: 'GBytes data'.
	sizeBuffer := ByteArray new:
		              FFIArchitecture forCurrentArchitecture sizeTTypeSize.
	data := self
		        signalIfNull: (PharoGLibLibrary uniqueInstance
				         g_bytes_get_data: bytes
				         size: sizeBuffer)
		        named: 'GBytes bytes'.
	size := sizeBuffer platformSizeTAt: 1.
	result := size = 0
		          ifTrue: [ ByteArray new ]
		          ifFalse: [ data copyFrom: 1 to: size ].
	PharoGLibLibrary uniqueInstance g_bytes_unref: bytes.
	^ result
]

{ #category : 'parquet' }
MooseParquetArrowMemory class >> parquetBytesFromTable: table schema: schema [

	| buffer outputStream writer writeResult closeResult |
	buffer := self
		          signalIfNull: (PharoArrowLibrary uniqueInstance
				           garrow_resizable_buffer_new: 0
				           error: nil)
		          named: 'GArrowResizableBuffer'.
	outputStream := self
		                signalIfNull:
			                (PharoArrowLibrary uniqueInstance
				                 garrow_buffer_output_stream_new: buffer)
		                named: 'GArrowBufferOutputStream'.
	writer := self
		          signalIfNull: (PharoParquetLibrary uniqueInstance
				           gparquet_arrow_file_writer_new_arrow: schema
				           sink: outputStream
				           writerProperties: nil
				           error: nil)
		          named: 'GParquetArrowFileWriter'.
	writeResult := PharoParquetLibrary uniqueInstance
		               gparquet_arrow_file_writer_write_table: writer
		               table: table
		               chunkSize: 10000
		               error: nil.
	writeResult = 0 ifTrue: [
		Error signal: 'Unable to write Parquet table to memory' ].
	closeResult := PharoParquetLibrary uniqueInstance
		               gparquet_arrow_file_writer_close: writer
		               error: nil.
	closeResult = 0 ifTrue: [
		Error signal: 'Unable to close memory Parquet writer' ].
	^ self trimmedParquetBytesFrom: (self byteArrayFromBuffer: buffer)
]

{ #category : 'private' }
MooseParquetArrowMemory class >> signalIfNull: pointer named: objectName [

	(pointer isNil or: [
		 (pointer respondsTo: #isNull) and: [ pointer isNull ] ]) ifTrue: [
		Error signal: 'Unable to create Arrow memory object: ' , objectName ].
	^ pointer
]

{ #category : 'parquet' }
MooseParquetArrowMemory class >> tableFromParquetBytes: aByteArray [

	| buffer inputStream reader |
	buffer := self bufferFromByteArray: aByteArray.
	inputStream := self
		               signalIfNull:
			               (PharoArrowLibrary uniqueInstance
				                garrow_buffer_input_stream_new: buffer)
		               named: 'GArrowBufferInputStream'.
	reader := self
		          signalIfNull:
		          (GParquetArrowFileReader
			           onArrowInputStream: inputStream
			           error: nil)
		          named: 'GParquetArrowFileReader'.
	^ reader readTableWithError: nil
]

{ #category : 'parquet' }
MooseParquetArrowMemory class >> trimmedParquetBytesFrom: aByteArray [

	| magic lastMagicIndex |
	magic := #[ 80 65 82 49 ].
	lastMagicIndex := 0.
	1 to: aByteArray size - magic size + 1 do: [ :index |
		((aByteArray at: index) = (magic at: 1) and: [
			 (aByteArray at: index + 1) = (magic at: 2) and: [
				 (aByteArray at: index + 2) = (magic at: 3) and: [
					 (aByteArray at: index + 3) = (magic at: 4) ] ] ]) ifTrue: [
			lastMagicIndex := index ] ].
	lastMagicIndex <= 1 ifTrue: [ ^ aByteArray ].
	^ aByteArray copyFrom: 1 to: lastMagicIndex + magic size - 1
]
