// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LocalDBMeasureModel.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class LocalDBMeasure extends _LocalDBMeasure with RealmEntity, RealmObject {
  LocalDBMeasure(
    String id,
    num TVOC,
    num eCO2,
    String date,
    num lat,
    num lon,
    bool synked,
  ) {
    RealmObject.set(this, 'id', id);
    RealmObject.set(this, 'TVOC', TVOC);
    RealmObject.set(this, 'eCO2', eCO2);
    RealmObject.set(this, 'date', date);
    RealmObject.set(this, 'lat', lat);
    RealmObject.set(this, 'lon', lon);
    RealmObject.set(this, 'synked', synked);
  }

  LocalDBMeasure._();

  @override
  String get id => RealmObject.get<String>(this, 'id') as String;
  @override
  set id(String value) => throw RealmUnsupportedSetError();

  @override
  num get TVOC => RealmObject.get<num>(this, 'TVOC') as num;
  @override
  set TVOC(num value) => RealmObject.set(this, 'TVOC', value);

  @override
  num get eCO2 => RealmObject.get<num>(this, 'eCO2') as num;
  @override
  set eCO2(num value) => RealmObject.set(this, 'eCO2', value);

  @override
  String get date => RealmObject.get<String>(this, 'date') as String;
  @override
  set date(String value) => RealmObject.set(this, 'date', value);

  @override
  num get lat => RealmObject.get<num>(this, 'lat') as num;
  @override
  set lat(num value) => RealmObject.set(this, 'lat', value);

  @override
  num get lon => RealmObject.get<num>(this, 'lon') as num;
  @override
  set lon(num value) => RealmObject.set(this, 'lon', value);

  @override
  bool get synked => RealmObject.get<bool>(this, 'synked') as bool;
  @override
  set synked(bool value) => RealmObject.set(this, 'synked', value);

  @override
  Stream<RealmObjectChanges<LocalDBMeasure>> get changes =>
      RealmObject.getChanges<LocalDBMeasure>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObject.registerFactory(LocalDBMeasure._);
    return const SchemaObject(LocalDBMeasure, [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('TVOC', RealmPropertyType.double),
      SchemaProperty('eCO2', RealmPropertyType.double),
      SchemaProperty('date', RealmPropertyType.string),
      SchemaProperty('lat', RealmPropertyType.double),
      SchemaProperty('lon', RealmPropertyType.double),
      SchemaProperty('synked', RealmPropertyType.bool),
    ]);
  }
}
