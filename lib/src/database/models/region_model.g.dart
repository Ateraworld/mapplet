// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: prefer_double_quotes

part of 'region_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetRegionModelCollection on Isar {
  IsarCollection<RegionModel> get regionModels => this.collection();
}

const RegionModelSchema = CollectionSchema(
  name: r'RegionModel',
  id: 3568151106562102397,
  properties: {
    r'regionId': PropertySchema(
      id: 0,
      name: r'regionId',
      type: IsarType.string,
    )
  },
  estimateSize: _regionModelEstimateSize,
  serialize: _regionModelSerialize,
  deserialize: _regionModelDeserialize,
  deserializeProp: _regionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'tiles': LinkSchema(
      id: 8959296370443501351,
      name: r'tiles',
      target: r'TileModel',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _regionModelGetId,
  getLinks: _regionModelGetLinks,
  attach: _regionModelAttach,
  version: '3.0.5',
);

int _regionModelEstimateSize(
  RegionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.regionId.length * 3;
  return bytesCount;
}

void _regionModelSerialize(
  RegionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.regionId);
}

RegionModel _regionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RegionModel(
    regionId: reader.readString(offsets[0]),
  );
  return object;
}

P _regionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _regionModelGetId(RegionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _regionModelGetLinks(RegionModel object) {
  return [object.tiles];
}

void _regionModelAttach(
    IsarCollection<dynamic> col, Id id, RegionModel object) {
  object.tiles.attach(col, col.isar.collection<TileModel>(), r'tiles', id);
}

extension RegionModelQueryWhereSort
    on QueryBuilder<RegionModel, RegionModel, QWhere> {
  QueryBuilder<RegionModel, RegionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RegionModelQueryWhere
    on QueryBuilder<RegionModel, RegionModel, QWhereClause> {
  QueryBuilder<RegionModel, RegionModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RegionModelQueryFilter
    on QueryBuilder<RegionModel, RegionModel, QFilterCondition> {
  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> regionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      regionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'regionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      regionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'regionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> regionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'regionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      regionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'regionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      regionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'regionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      regionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'regionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> regionIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'regionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      regionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regionId',
        value: '',
      ));
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      regionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'regionId',
        value: '',
      ));
    });
  }
}

extension RegionModelQueryObject
    on QueryBuilder<RegionModel, RegionModel, QFilterCondition> {}

extension RegionModelQueryLinks
    on QueryBuilder<RegionModel, RegionModel, QFilterCondition> {
  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> tiles(
      FilterQuery<TileModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tiles');
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      tilesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tiles', length, true, length, true);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition> tilesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tiles', 0, true, 0, true);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      tilesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tiles', 0, false, 999999, true);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      tilesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tiles', 0, true, length, include);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      tilesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tiles', length, include, 999999, true);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterFilterCondition>
      tilesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'tiles', lower, includeLower, upper, includeUpper);
    });
  }
}

extension RegionModelQuerySortBy
    on QueryBuilder<RegionModel, RegionModel, QSortBy> {
  QueryBuilder<RegionModel, RegionModel, QAfterSortBy> sortByRegionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionId', Sort.asc);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterSortBy> sortByRegionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionId', Sort.desc);
    });
  }
}

extension RegionModelQuerySortThenBy
    on QueryBuilder<RegionModel, RegionModel, QSortThenBy> {
  QueryBuilder<RegionModel, RegionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterSortBy> thenByRegionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionId', Sort.asc);
    });
  }

  QueryBuilder<RegionModel, RegionModel, QAfterSortBy> thenByRegionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regionId', Sort.desc);
    });
  }
}

extension RegionModelQueryWhereDistinct
    on QueryBuilder<RegionModel, RegionModel, QDistinct> {
  QueryBuilder<RegionModel, RegionModel, QDistinct> distinctByRegionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'regionId', caseSensitive: caseSensitive);
    });
  }
}

extension RegionModelQueryProperty
    on QueryBuilder<RegionModel, RegionModel, QQueryProperty> {
  QueryBuilder<RegionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RegionModel, String, QQueryOperations> regionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'regionId');
    });
  }
}
