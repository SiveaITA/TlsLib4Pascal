{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpPosixDynLib;

{$I ..\..\TlsLib\src\Include\TlsLib.inc}

interface

{$IF DEFINED(TLSLIB_UNIXLIKE)}

type
  /// <summary>
  /// A cross-compiler (FPC + Delphi) wrapper over the POSIX dynamic linker so a reader can
  /// resolve its platform entry points at runtime rather than statically linking them.
  /// </summary>
  TPosixDynLib = class sealed(TObject)
  public
    /// <summary>dlopen the named shared object (RTLD_NOW). An empty name opens the global
    /// symbol namespace - the already-linked libraries. Returns 0 on failure.</summary>
    class function Open(const ASoName: string): NativeUInt; static;
    /// <summary>dlsym a symbol from an open handle; nil when the handle or the symbol is absent.</summary>
    class function Resolve(AHandle: NativeUInt; const ASymbol: string): Pointer; static;
    /// <summary>dlclose an open handle; a 0 handle (and the global handle) is a no-op.</summary>
    class procedure Close(AHandle: NativeUInt); static;
  end;

{$IFEND}

implementation

{$IF DEFINED(TLSLIB_UNIXLIKE)}

uses
{$IFDEF FPC}
  dl;
{$ELSE}
  Posix.Dlfcn;
{$ENDIF}

{ TPosixDynLib }

class function TPosixDynLib.Open(const ASoName: string): NativeUInt;
var
  LAnsi: AnsiString;
  LName: PAnsiChar;
begin
  // an empty soname opens the global namespace (dlopen(nil))
  if ASoName = '' then
    LName := nil
  else
  begin
    LAnsi := AnsiString(ASoName);
    LName := PAnsiChar(LAnsi);
  end;

{$IFDEF FPC}
  Result := NativeUInt(dlopen(LName, RTLD_NOW));
{$ELSE}
  Result := dlopen(LName, RTLD_NOW);
{$ENDIF}
end;

class function TPosixDynLib.Resolve(AHandle: NativeUInt;
  const ASymbol: string): Pointer;
var
  LAnsi: AnsiString;
begin
  if AHandle = 0 then
    Exit(nil);
  LAnsi := AnsiString(ASymbol);
  Result := dlsym(AHandle, PAnsiChar(LAnsi));
end;

class procedure TPosixDynLib.Close(AHandle: NativeUInt);
begin
  if AHandle <> 0 then
    dlclose(AHandle);
end;

{$IFEND}

end.
