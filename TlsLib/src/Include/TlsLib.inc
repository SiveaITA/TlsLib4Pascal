{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

{========================= Compiler Specific Settings =========================}

{$IFDEF FPC}
  {$I TlsLibFPC.inc}
{$ELSE}
  // Delphi Sydney and Above
  {$IF CompilerVersion < 34.0}
    {$MESSAGE ERROR 'This Library requires Delphi Sydney or higher.'}
  {$IFEND}

  // Silence H2586 (legacy $IFEND). The $LEGACYIFEND directive was introduced in
  // XE4 (25.0); the guard keeps older compilers (below the floor) from choking on
  // it, even though they are already rejected above.
  {$IF CompilerVersion >= 25.0}
    {$LEGACYIFEND ON}
  {$IFEND}

  {$DEFINE DELPHI}

  {$DEFINITIONINFO ON} // Enable code browsing (Ctrl+Click)
  {$STRINGCHECKS OFF}
  {$WARN DUPLICATE_CTOR_DTOR OFF}

  // XE4 (25.0) and above fixed the shl/shr-overflow behavior that older Delphi
  // needed an explicit shift-count mask to work around.
  {$IF CompilerVersion >= 25.0}
    {$DEFINE SHIFT_OVERFLOW_BUG_FIXED}
  {$IFEND}

  {============================= CPU Architecture =============================}

  {$DEFINE TLSLIB_LITTLE_ENDIAN}

  {$IFDEF CPUARM}
    {$DEFINE TLSLIB_REQUIRES_PROPER_ALIGNMENT}
  {$ENDIF}

  {$IF DEFINED(CPUX86) OR (DEFINED(CPU386) AND NOT DEFINED(CPU64BITS))}
    {$DEFINE TLSLIB_I386}
  {$IFEND}

  {$IFDEF CPUX64}
    {$DEFINE TLSLIB_X86_64}
  {$ENDIF}

  {$IFDEF CPUARM32}
    {$DEFINE TLSLIB_ARM32}
  {$ENDIF}

  {$IFDEF CPUARM64}
    {$DEFINE TLSLIB_AARCH64}
  {$ENDIF}

  {================================ Target OS =================================}

  {$IFDEF MSWINDOWS}
    {$DEFINE TLSLIB_MSWINDOWS}
  {$ENDIF}

  {$IFDEF IOS}
    {$DEFINE TLSLIB_IOS}
  {$ENDIF}

  {$IFDEF MACOS}
    {$IFNDEF IOS}
      {$DEFINE TLSLIB_MACOS}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF ANDROID}
    {$DEFINE TLSLIB_ANDROID}
  {$ENDIF}

  {$IFDEF LINUX}
    {$DEFINE TLSLIB_LINUX}
  {$ENDIF}

  {$IF DEFINED(TLSLIB_ANDROID)
     OR DEFINED(TLSLIB_LINUX)
     OR DEFINED(TLSLIB_IOS)
     OR DEFINED(TLSLIB_MACOS)}
    {$DEFINE TLSLIB_UNIXLIKE}
  {$IFEND}

{$ENDIF}

{========================== Common Defines Settings ===========================}

{$IF DEFINED(TLSLIB_I386) OR DEFINED(TLSLIB_X86_64)}
  {$DEFINE TLSLIB_X86}
{$IFEND}

{$IF DEFINED(TLSLIB_ARM32) OR DEFINED(TLSLIB_AARCH64)}
  {$DEFINE TLSLIB_ARM}
{$IFEND}

{========================== Common Compiler Settings ==========================}

{$HINTS OFF}
{$WARNINGS OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}
{$SCOPEDENUMS ON}
{$POINTERMATH ON}

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
