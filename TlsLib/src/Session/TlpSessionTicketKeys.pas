{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpSessionTicketKeys;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  SyncObjs,
  Generics.Collections,
  TlpArrayUtilities,
  TlpICryptoProvider,
  TlpISecretBuffer,
  TlpSecretBuffer,
  TlpSecureMemory,
  TlpISession;

type
  /// <summary>
  /// The default <see cref="ISessionTicketKeyManager" />: a rotating STEK ring
  /// holding the current encrypt key plus a bounded window of recent keys still
  /// accepted for decrypt. Keys are AES-256 sized and each is tagged by a random
  /// fixed-length name carried in the clear at the front of a ticket. Rotation
  /// promotes a fresh current key and retires the oldest beyond the window.
  /// Guarded by an internal lock, so one instance is safe to share across
  /// connections/threads.
  /// </summary>
  TStekTicketKeyManager = class sealed(TInterfacedObject, ISessionTicketKeyManager)
  strict private
  type
    TStekKey = record
      Name: TBytes;
      Key: ISecretBuffer;
    end;
  var
    FRandom: IRandom;
    FKeys: TList<TStekKey>; // oldest .. current (the last entry is current)
    FWindow: Int32;
    FLock: TCriticalSection;
    procedure TrimToWindow;
  public
    /// <summary>A manager with a fresh current key and an AWindowSize decrypt
    /// window (defaults applied when 0 or less).</summary>
    constructor Create(const ARandom: IRandom; AWindowSize: Int32 = 0);
    destructor Destroy; override;

    function CurrentKey(out AKeyName: TBytes; out AKey: ISecretBuffer): Boolean;
    function KeyByName(const AKeyName: TBytes; out AKey: ISecretBuffer): Boolean;
    procedure Rotate;
    function KeyNameLength: Int32;

    /// <summary>Installs a caller-supplied key as the current key (e.g. a shared
    /// STEK across a server fleet); it also enters the decrypt window.</summary>
    procedure InstallKey(const AName: TBytes; const AKey: ISecretBuffer);
  end;

implementation

const
  StekKeyNameLength = Int32(16);
  StekKeyLength = Int32(32); // AES-256-GCM
  DefaultDecryptWindow = Int32(3);

{ TStekTicketKeyManager }

constructor TStekTicketKeyManager.Create(const ARandom: IRandom;
  AWindowSize: Int32);
begin
  inherited Create;
  FRandom := ARandom;
  if AWindowSize > 0 then
    FWindow := AWindowSize
  else
    FWindow := DefaultDecryptWindow;
  FKeys := TList<TStekKey>.Create;
  FLock := TCriticalSection.Create;
  Rotate; // start with one fresh current key
end;

destructor TStekTicketKeyManager.Destroy;
begin
  FKeys.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TStekTicketKeyManager.TrimToWindow;
begin
  while FKeys.Count > FWindow do
    FKeys.Delete(0);
end;

function TStekTicketKeyManager.CurrentKey(out AKeyName: TBytes;
  out AKey: ISecretBuffer): Boolean;
var
  LEntry: TStekKey;
begin
  AKeyName := nil;
  AKey := nil;
  FLock.Enter;
  try
    Result := FKeys.Count > 0;
    if not Result then
      Exit;
    LEntry := FKeys[FKeys.Count - 1];
    AKeyName := System.Copy(LEntry.Name, 0, System.Length(LEntry.Name));
    AKey := LEntry.Key;
  finally
    FLock.Leave;
  end;
end;

function TStekTicketKeyManager.KeyByName(const AKeyName: TBytes;
  out AKey: ISecretBuffer): Boolean;
var
  LIndex: Int32;
begin
  AKey := nil;
  Result := False;
  FLock.Enter;
  try
    // the key name is public (it rides the ticket in the clear); a plain compare is fine
    for LIndex := FKeys.Count - 1 downto 0 do
      if TArrayUtilities.AreEqual(FKeys[LIndex].Name, AKeyName) then
      begin
        AKey := FKeys[LIndex].Key;
        Result := True;
        Exit;
      end;
  finally
    FLock.Leave;
  end;
end;

procedure TStekTicketKeyManager.Rotate;
var
  LEntry: TStekKey;
  LRaw: TBytes;
begin
  LEntry.Name := FRandom.GenerateBytes(StekKeyNameLength);
  // wrap the fresh key material in the secret buffer (which copies it), then wipe the
  // transient plaintext TBytes so the raw key does not linger on the heap
  LRaw := FRandom.GenerateBytes(StekKeyLength);
  try
    LEntry.Key := TSecretBuffer.From(LRaw);
  finally
    TSecureMemory.WipeBytes(LRaw);
  end;
  FLock.Enter;
  try
    FKeys.Add(LEntry);
    TrimToWindow;
  finally
    FLock.Leave;
  end;
end;

procedure TStekTicketKeyManager.InstallKey(const AName: TBytes;
  const AKey: ISecretBuffer);
var
  LEntry: TStekKey;
begin
  LEntry.Name := System.Copy(AName, 0, System.Length(AName));
  LEntry.Key := AKey;
  FLock.Enter;
  try
    FKeys.Add(LEntry);
    TrimToWindow;
  finally
    FLock.Leave;
  end;
end;

function TStekTicketKeyManager.KeyNameLength: Int32;
begin
  Result := StekKeyNameLength;
end;

end.
