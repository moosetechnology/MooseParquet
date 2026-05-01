"
Utility methods for the .moosemodel ZIP container layout.
"
Class {
	#name : 'MooseParquetArchive',
	#superclass : 'Object',
	#category : 'MooseParquet-Support',
	#package : 'MooseParquet',
	#tag : 'Support'
}

{ #category : 'writing' }
MooseParquetArchive class >> addMemberNamed: memberName from: stagingRoot to: archive [

	| member source |
	source := self referenceForMember: memberName in: stagingRoot.
	source exists ifFalse: [
		Error signal: 'Missing staged .moosemodel member: ' , memberName ].
	member := archive addFile: source as: memberName.
	member desiredCompressionMethod: ZipArchive compressionStored.
	^ member
]

{ #category : 'reading' }
MooseParquetArchive class >> binaryContentsOf: memberName in: archive [

	| contents |
	contents := archive contentsOf: memberName.
	contents ifNil: [
		Error signal: 'Missing .moosemodel entry: ' , memberName ].
	contents isString ifTrue: [ ^ contents utf8Encoded ].
	^ contents
]

{ #category : 'constants' }
MooseParquetArchive class >> entitiesMemberName [

	^ 'data/entities.parquet'
]

{ #category : 'constants' }
MooseParquetArchive class >> entitiesPropertiesMemberName [

	^ 'data/entities_properties.parquet'
]

{ #category : 'constants' }
MooseParquetArchive class >> formatVersion [

	^ 1
]

{ #category : 'manifest' }
MooseParquetArchive class >> manifestDictionary [

	| files |
	files := Dictionary new.
	files at: 'entities' put: self entitiesMemberName.
	files at: 'entitiesProperties' put: self entitiesPropertiesMemberName.
	files at: 'relationships' put: self relationshipsMemberName.
	^ Dictionary newFrom: {
			  ('format' -> 'MooseParquet MooseModel').
			  ('formatVersion' -> self formatVersion).
			  ('metadata' -> self metadataFileName).
			  ('files' -> files) }
]

{ #category : 'constants' }
MooseParquetArchive class >> manifestFileName [

	^ 'manifest.json'
]

{ #category : 'manifest' }
MooseParquetArchive class >> manifestJSON [

	^ NeoJSONWriter toString: self manifestDictionary
]

{ #category : 'constants' }
MooseParquetArchive class >> metadataFileName [

	^ 'metadata.json'
]

{ #category : 'constants' }
MooseParquetArchive class >> parquetMemberNames [

	^ {
		  self entitiesMemberName.
		  self entitiesPropertiesMemberName.
		  self relationshipsMemberName }
]

{ #category : 'reading' }
MooseParquetArchive class >> readFrom: aFileReference [

	^ [
	  | archive |
	  archive := ZipArchive new.
	  archive readFrom: aFileReference asFileReference.
	  archive ]
		  on: Error
		  do: [ :exception |
			  Error signal: 'Invalid .moosemodel ZIP: ' , exception messageText ]
]

{ #category : 'files' }
MooseParquetArchive class >> referenceForMember: memberName in: rootReference [

	^ (memberName findTokens: '/')
		  inject: rootReference
		  into: [ :reference :pathPart | reference / pathPart ]
]

{ #category : 'constants' }
MooseParquetArchive class >> relationshipsMemberName [

	^ 'data/relationships.parquet'
]

{ #category : 'constants' }
MooseParquetArchive class >> requiredMemberNames [

	^ {
		  self manifestFileName.
		  self metadataFileName.
		  self entitiesMemberName.
		  self entitiesPropertiesMemberName.
		  self relationshipsMemberName }
]

{ #category : 'reading' }
MooseParquetArchive class >> textContentsOf: memberName in: archive [

	| contents |
	contents := self binaryContentsOf: memberName in: archive.
	contents isString ifTrue: [ ^ contents ].
	^ contents utf8Decoded
]

{ #category : 'validation' }
MooseParquetArchive class >> validateArchive: archive [

	self validateRequiredMembersIn: archive.
	^ self validateManifestIn: archive
]

{ #category : 'validation' }
MooseParquetArchive class >> validateManifestIn: archive [

	| manifest version |
	manifest := [
	            NeoJSONReader fromString:
		            (self textContentsOf: self manifestFileName in: archive) ]
		            on: Error
		            do: [ :exception |
			            Error signal:
				            'Invalid .moosemodel manifest.json: '
				            , exception messageText ].
	version := manifest at: 'formatVersion' ifAbsent: [
		           Error signal:
			           'Invalid .moosemodel manifest.json: missing formatVersion' ].
	version = self formatVersion ifFalse: [
		Error signal:
			'Unsupported .moosemodel formatVersion: ' , version asString ].
	^ manifest
]

{ #category : 'validation' }
MooseParquetArchive class >> validateRequiredMembersIn: archive [

	self requiredMemberNames do: [ :memberName |
		(archive memberNamed: memberName) ifNil: [
			Error signal: 'Missing .moosemodel entry: ' , memberName ] ]
]

{ #category : 'writing' }
MooseParquetArchive class >> writeBytes: aByteArray toMember: memberName in: stagingRoot [

	| reference |
	reference := self referenceForMember: memberName in: stagingRoot.
	reference parent ensureCreateDirectory.
	reference binaryWriteStreamDo: [ :stream |
		stream nextPutAll: aByteArray ].
	^ reference
]

{ #category : 'writing' }
MooseParquetArchive class >> writeStaging: stagingRoot to: targetFileReference [

	| archive |
	archive := ZipArchive new.
	self requiredMemberNames do: [ :memberName |
		self addMemberNamed: memberName from: stagingRoot to: archive ].
	archive writeToFile: targetFileReference asFileReference.
	^ targetFileReference asFileReference
]

{ #category : 'writing' }
MooseParquetArchive class >> writeString: aString toMember: memberName in: stagingRoot [

	^ self
		  writeBytes: aString utf8Encoded
		  toMember: memberName
		  in: stagingRoot
]
