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
| model output exporter |

model := MooseModel root second. "ou ton modèle Moose déjà chargé"
output := FileLocator documents / 'jpetStore.moosemodel'.

exporter := MooseParquetExporter new.
exporter model: model.
exporter exportTo: output.
```

## Example Usage: Import

Import the generated Parquet files into a Moose model:

```smalltalk
| model input importer |

model := MooseModel new.
input := FileLocator documents / 'my-model.moosemodel'.

importer := MooseParquetImporter new.
importer model: model.
importer importFrom: input.

model
```
