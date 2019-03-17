unit CryptU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DCPrijndael, DCPsha256;

function Encrypt(const s_cred: string): string;
function Decrypt(const s_cred: string): string;
function GetAsin: string;

implementation


function Encrypt(const s_cred: string): string;
var
  crypt: TDCP_rijndael;
  s: string;
begin
  s := '';
  crypt := TDCP_rijndael.Create(nil);
  try
    crypt.InitStr(GetAsin,TDCP_sha256);
    s := crypt.EncryptString(s_cred);
  finally
    crypt.Free;
  end;
  Result := s;
end;

function Decrypt(const s_cred: string): string;
var
  crypt: TDCP_rijndael;
  s: string;
begin
  s := '';
  crypt := TDCP_rijndael.Create(nil);
  try
    crypt.InitStr(GetAsin,TDCP_sha256);
    s := crypt.DecryptString(s_cred);
  finally
    crypt.Free;
  end;
  Result := s;
end;

function GetAsin: string;
begin
  result := 'asdf23460cvklq{}O())_FGGHTRddl-(&^=';
end;

end.

