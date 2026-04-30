Class {
	#name : 'BaselineOfMooseParquet',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfMooseParquet',
	#package : 'BaselineOfMooseParquet'
}

{ #category : 'baselines' }
BaselineOfMooseParquet >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self defineDependencies: spec.
		self definePackages: spec.
		self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfMooseParquet >> defineDependencies: spec [

	spec
		baseline: 'PharoArrow'
		with: [ spec repository: 'github://badetitou/PharoArrow:main/src' ]
]

{ #category : 'baselines' }
BaselineOfMooseParquet >> defineGroups: spec [

	
]

{ #category : 'baselines' }
BaselineOfMooseParquet >> definePackages: spec [

	spec
		package: 'MooseParquet'
		with: [ spec requires: #( 'PharoArrow' ) ]
]
