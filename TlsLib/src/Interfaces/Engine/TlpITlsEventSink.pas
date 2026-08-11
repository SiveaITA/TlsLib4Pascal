{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpITlsEventSink;

{$I ..\..\Include\TlsLib.inc}

interface

uses
  TlpITlsEngine;

type
  /// <summary>
  /// An optional push sink for engine events. The pollable queue (ITlsEngine.
  /// NextEvent) is the canonical path; a caller that prefers push installs a sink
  /// and is notified as each event is queued. Notifications run on the caller's
  /// thread inside the engine call that produced them (no threads are introduced).
  /// </summary>
  ITlsEventSink = interface(IInterface)
    ['{6B2E9D74-1F3A-4C85-B0D6-7A2C4E619F30}']
    procedure OnEvent(const AEvent: ITlsEvent);
  end;

  /// <summary>
  /// Implemented by anything that can push events to a sink. The engine exposes it
  /// so a caller can opt into push delivery; reach it with
  /// Supports(engine, ITlsEventSource, source).
  /// </summary>
  ITlsEventSource = interface(IInterface)
    ['{8D4A0F16-2B5C-4E79-A6D3-1F0B7C39E24A}']
    procedure SetEventSink(const ASink: ITlsEventSink);
  end;

implementation

end.
