{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpCodeKeyedRegistry;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpArrayUtilities;

type
  /// <summary>
  /// The behavior shared by the code-keyed registries: an ordered, prunable list
  /// keyed by a UInt16 wire code. A concrete registry supplies the code extractor
  /// (through the constructor) and the specific registry interface; the vocabulary
  /// - Items / Contains / TryGet / Add / Prune - is then uniform across all of them.
  /// Insertion order is preserved (it is the on-wire preference order); Add is a
  /// no-op when the code is already present.
  /// </summary>
  TCodeKeyedRegistry<T> = class abstract(TInterfacedObject)
  strict private
  var
    FItems: TArray<T>;
    FCodeOf: TKeyOf<T, UInt16>;
  strict protected
    constructor Create(const ACodeOf: TKeyOf<T, UInt16>);
  public
    /// <summary>All entries, in insertion (preference) order.</summary>
    function Items: TArray<T>;
    /// <summary>Whether an entry with ACode is registered.</summary>
    function Contains(ACode: UInt16): Boolean;
    /// <summary>The entry with ACode; False (AItem unset) when none.</summary>
    function TryGet(ACode: UInt16; out AItem: T): Boolean;
    /// <summary>Appends AItem unless its code is already present.</summary>
    procedure Add(const AItem: T);
    /// <summary>Removes the entry with ACode, if any.</summary>
    procedure Prune(ACode: UInt16);
  end;

implementation

{ TCodeKeyedRegistry<T> }

constructor TCodeKeyedRegistry<T>.Create(const ACodeOf: TKeyOf<T, UInt16>);
begin
  inherited Create;
  FCodeOf := ACodeOf;
end;

function TCodeKeyedRegistry<T>.Items: TArray<T>;
begin
  Result := FItems;
end;

function TCodeKeyedRegistry<T>.TryGet(ACode: UInt16; out AItem: T): Boolean;
var
  LIndex: Int32;
begin
  LIndex := TArrayUtilities.IndexOfKey<T, UInt16>(FItems, FCodeOf, ACode);
  Result := LIndex >= 0;
  if Result then
    AItem := FItems[LIndex];
end;

function TCodeKeyedRegistry<T>.Contains(ACode: UInt16): Boolean;
var
  LItem: T;
begin
  Result := TryGet(ACode, LItem);
end;

procedure TCodeKeyedRegistry<T>.Add(const AItem: T);
begin
  if Contains(FCodeOf(AItem)) then
    Exit;
  TArrayUtilities.Append<T>(FItems, AItem);
end;

procedure TCodeKeyedRegistry<T>.Prune(ACode: UInt16);
begin
  TArrayUtilities.RemoveKey<T, UInt16>(FItems, FCodeOf, ACode);
end;

end.
