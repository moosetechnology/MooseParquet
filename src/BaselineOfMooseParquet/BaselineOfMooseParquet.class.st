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
		with: [ spec repository: 'github://badetitou/PharoArrow:main/src' ];
		baseline: 'NeoJSON'
		with: [
			spec repository: 'github://svenvc/NeoJSON:master/repository' ]
]

{ #category : 'baselines' }
BaselineOfMooseParquet >> defineGroups: spec [

	spec
		group: 'Core' with: #( 'MooseParquet' );
		group: 'Tests' with: #( 'MooseParquet-Tests' );
		group: 'default' with: #( 'Core' )
]

{ #category : 'baselines' }
BaselineOfMooseParquet >> definePackages: spec [

	spec
		package: 'MooseParquet'
		with: [ spec requires: #( 'PharoArrow' 'NeoJSON' ) ];
		package: 'MooseParquet-Tests'
		with: [ spec requires: #( 'MooseParquet' ) ]
]
