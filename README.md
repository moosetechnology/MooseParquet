# MooseParquet

MooseParquet exports and imports Moose models using Apache Parquet files.
It provides a small set of exporters and importers to persist Moose entities,
their scalar properties, and their relationships in a tabular graph-oriented
format.

## Installation

Load MooseParquet with Metacello:

```smalltalk
Metacello new
	baseline: 'MooseParquet';
	repository: 'github://Evref-BL/MooseParquet:main/src';
	load.
```

## Example Usage: Export

Export a Moose model to Parquet files:

```smalltalk
exporter := MooseParquetExporter new.
exporter model: MooseModel root anyOne.
exporter export.
```

The exporter writes the following files:

- `entities.parquet`
- `entities_properties.parquet`
- `relationships.parquet`

These files contain the model entities, their exported scalar properties, and
the relationships between entities.

## Example Usage: Import

Import the generated Parquet files into a Moose model:

```smalltalk
modelJava := FamixJavaModel new.

importer := MooseParquetImporter new.
importer model: modelJava.
importer importEntities. "11 sec"
importer importEntitiesProperties. "1 min"
importer importEntitiesRelationships
```

The import process should be run in this order: entities first, then scalar
properties, then relationships. This ensures that every relationship can be
resolved against entities already present in the target model.
