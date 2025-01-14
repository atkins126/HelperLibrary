﻿unit UGenericDictionary;

interface

uses
  Rtti,
  Generics.Collections;

type
  TGenericDictionary = class
  private
    FDictionary: TDictionary<String, TValue>;
    FFreeValues: Boolean;
    function getCount: Integer;
    function getItem(const AKey: String): TValue;
    procedure setItem(const AKey: String; const AValue: TValue);
    function getKeys: TArray<String>;
  public
    constructor Create;
    destructor Destroy; override;

    property FreeValuesOnDestroy: Boolean read FFreeValues write FFreeValues;
    property Count: Integer read getCount;
    property Items[const Key: String]: TValue read getItem write setItem; default;
    property Keys: TArray<String> read getKeys;

    function Values: TArray<TValue>; overload;
    function Values<T>: TArray<T>; overload;

    function get<T>(AKey: String): T;
    function getPair(AKey: String): TPair<string, TValue>; overload;
    function getPair<T>(AKey: String): TPair<string, T>; overload;

    procedure add<T>(AKey: String; AValue:T);
    function remove<T>(AKey: String): T;

    function containsKey(AKey: String): Boolean;
    function containsValue<T>(AValue: T): Boolean;

    procedure trimExcess;
    procedure clear;
  end;
implementation

uses
  UDictImports;

{ TGenericDictionary }

procedure TGenericDictionary.add<T>(AKey: String; AValue: T);
begin
  FDictionary.AddOrSetValue(AKey, TValue.From<T>(AValue));
end;

procedure TGenericDictionary.clear;
begin
  FDictionary.Clear;
end;

function TGenericDictionary.containsKey(AKey: String): Boolean;
begin
  Result := FDictionary.ContainsKey(AKey);
end;

function TGenericDictionary.containsValue<T>(AValue: T): Boolean;
var
  LResult: Boolean;
  LList: TArray<TValue>;
begin
  LResult := False;
  LList := FDictionary.Values.ToArray;
  TArrU.forEach<TValue>(LList,
  procedure(var ATValue: TValue; out ABreak: Boolean)
  begin
    if TGenU.equals<T>(ATValue.AsType<T>) then
    begin
      LResult := True;
      ABreak := True;
    end
  end);
  Result := LResult;
end;

constructor TGenericDictionary.Create;
begin
  FDictionary := TDictionary<String, TValue>.Create;
end;

destructor TGenericDictionary.Destroy;
var LList: TArray<TValue>;
begin
  LList := Values;
  TArrU.forEach<TValue>(LList,
  procedure(var AValue: TValue; out ABreak: Boolean)
  var
    FObj: TObject;
    I: Integer;
  begin
    if TGenU.isObject(AValue) then
    begin
      FObj := AValue.AsObject;
      TGenU.freeAndNil(FObj);
    end;
    if TGenU.isArrayOfObject(AValue) then
    begin
      for I := 0 to AValue.GetArrayLength do
      begin
        if TGenU.isObject(AValue.GetArrayElement(I)) then
        begin
          FObj := AValue.GetArrayElement(I).AsObject;
          TGenU.freeAndNil(FObj);
        end;
      end;
    end;
  end);
  TGenU.freeAndNil(FDictionary);
  inherited;
end;

function TGenericDictionary.get<T>(AKey: String): T;
begin
  Result := Default(T);
  if FDictionary.ContainsKey(AKey) then
    Result := FDictionary[AKey].AsType<T>;
end;

function TGenericDictionary.getCount: Integer;
begin
  Result := FDictionary.Count;
end;

function TGenericDictionary.getItem(const AKey: String): TValue;
begin
  Result := FDictionary.Items[AKey];
end;

function TGenericDictionary.getKeys: TArray<String>;
begin
  Result := FDictionary.Keys.ToArray;
end;

function TGenericDictionary.getPair(AKey: String): TPair<string, TValue>;
begin
  Result := FDictionary.ExtractPair(AKey);
end;

function TGenericDictionary.getPair<T>(AKey: String): TPair<string, T>;
begin
  Result := TPair<string, T>.Create(AKey, get<T>(AKey))
end;

function TGenericDictionary.Values: TArray<TValue>;
begin
  Result := FDictionary.Values.ToArray;
end;

function TGenericDictionary.Values<T>: TArray<T>;
begin
  Result := TArrU.map<TValue, T>(Values,
  function(AValue: TValue): T
  begin
    Result := AValue.AsType<T>;
  end);
end;

function TGenericDictionary.remove<T>(AKey: String): T;
begin
  Result := get<T>(AKey);
  FDictionary.Remove(AKey);
end;

procedure TGenericDictionary.setItem(const AKey: String; const AValue: TValue);
begin
  FDictionary.AddOrSetValue(AKey,AValue);
end;

procedure TGenericDictionary.trimExcess;
begin
  FDictionary.TrimExcess;
end;

end.


