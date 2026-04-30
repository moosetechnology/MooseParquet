Class {
	#name : 'MooseParquetBaselineTest',
	#superclass : 'TestCase',
	#category : 'MooseParquet-Tests-Baseline',
	#package : 'MooseParquet-Tests',
	#tag : 'Baseline'
}

{ #category : 'helpers' }
MooseParquetBaselineTest >> sourceOf: aSelector [
	^ (BaselineOfMooseParquet >> aSelector) sourceCode
]

{ #category : 'tests' }
MooseParquetBaselineTest >> testBaselineClassLivesInItsOwnPackage [
	self assert: BaselineOfMooseParquet package name equals: 'BaselineOfMooseParquet'
]

{ #category : 'tests' }
MooseParquetBaselineTest >> testBaselineDefinesMooseParquetPackage [
	self assert: ((self sourceOf: #definePackages:) includesSubstring: 'MooseParquet')
]

{ #category : 'tests' }
MooseParquetBaselineTest >> testBaselineDefinesTestsGroup [
	self assert: ((self sourceOf: #defineGroups:) includesSubstring: 'Tests')
]

{ #category : 'tests' }
MooseParquetBaselineTest >> testBaselineDefinesTestsPackage [
	self assert: ((self sourceOf: #definePackages:) includesSubstring: 'MooseParquet-Tests')
]

{ #category : 'tests' }
MooseParquetBaselineTest >> testBaselineDependsOnPharoArrow [
	self assert: ((self sourceOf: #defineDependencies:) includesSubstring: 'PharoArrow')
]
