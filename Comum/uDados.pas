unit uDados;

interface

uses
  Data.DB, FireDAC.Stan.Param, System.SysUtils, System.Variants;

procedure LimparParametro(poParam: TFDParam; peTipo: TFieldType; piTamanho: Integer = 0);
function TextoOuNulo(const psValor: string): Variant;
function ArredondarMoeda(const pnValor: Currency): Currency;
function ArredondarPercentual(const pnValor: Double): Double;
function SemAcento(const psTexto: string): string;
function SqlSemAcento(const psExpressao: string): string;

implementation

procedure LimparParametro(poParam: TFDParam; peTipo: TFieldType; piTamanho: Integer);
begin
  poParam.DataType := peTipo;
  if piTamanho > 0 then
    poParam.Size := piTamanho;
  poParam.Clear;
end;

function TextoOuNulo(const psValor: string): Variant;
begin
  if Trim(psValor) = '' then
    Result := Null
  else
    Result := Trim(psValor);
end;

function ArredondarMoeda(const pnValor: Currency): Currency;
begin
  Result := Round(pnValor * 100) / 100;
end;

function ArredondarPercentual(const pnValor: Double): Double;
begin
  Result := Round(pnValor * 100) / 100;
end;

function SemAcento(const psTexto: string): string;
var
  iPos: Integer;
  sBase: string;
begin
  sBase := UpperCase(Trim(psTexto));
  Result := '';
  for iPos := 1 to Length(sBase) do
    case sBase[iPos] of
      #$00C1, #$00C0, #$00C2, #$00C3, #$00C4: Result := Result + 'A';
      #$00C9, #$00C8, #$00CA, #$00CB: Result := Result + 'E';
      #$00CD, #$00CC, #$00CE, #$00CF: Result := Result + 'I';
      #$00D3, #$00D2, #$00D4, #$00D5, #$00D6: Result := Result + 'O';
      #$00DA, #$00D9, #$00DB, #$00DC: Result := Result + 'U';
      #$00C7: Result := Result + 'C';
      #$00D1: Result := Result + 'N';
    else
      Result := Result + sBase[iPos];
    end;
end;

function SqlSemAcento(const psExpressao: string): string;

  function Trocar(const psExpr, psHex, psPara: string): string;
  begin
    Result := 'REPLACE(' + psExpr + ', _UTF8 X''' + psHex + ''', ''' + psPara + ''')';
  end;

begin
  Result := psExpressao;
  Result := Trocar(Result, 'C3A1', 'a');
  Result := Trocar(Result, 'C3A0', 'a');
  Result := Trocar(Result, 'C3A2', 'a');
  Result := Trocar(Result, 'C3A3', 'a');
  Result := Trocar(Result, 'C3A4', 'a');
  Result := Trocar(Result, 'C381', 'A');
  Result := Trocar(Result, 'C380', 'A');
  Result := Trocar(Result, 'C382', 'A');
  Result := Trocar(Result, 'C383', 'A');
  Result := Trocar(Result, 'C384', 'A');
  Result := Trocar(Result, 'C3A9', 'e');
  Result := Trocar(Result, 'C3A8', 'e');
  Result := Trocar(Result, 'C3AA', 'e');
  Result := Trocar(Result, 'C3AB', 'e');
  Result := Trocar(Result, 'C389', 'E');
  Result := Trocar(Result, 'C388', 'E');
  Result := Trocar(Result, 'C38A', 'E');
  Result := Trocar(Result, 'C38B', 'E');
  Result := Trocar(Result, 'C3AD', 'i');
  Result := Trocar(Result, 'C3AC', 'i');
  Result := Trocar(Result, 'C3AE', 'i');
  Result := Trocar(Result, 'C38D', 'I');
  Result := Trocar(Result, 'C38C', 'I');
  Result := Trocar(Result, 'C38E', 'I');
  Result := Trocar(Result, 'C3B3', 'o');
  Result := Trocar(Result, 'C3B2', 'o');
  Result := Trocar(Result, 'C3B4', 'o');
  Result := Trocar(Result, 'C3B5', 'o');
  Result := Trocar(Result, 'C3B6', 'o');
  Result := Trocar(Result, 'C393', 'O');
  Result := Trocar(Result, 'C392', 'O');
  Result := Trocar(Result, 'C394', 'O');
  Result := Trocar(Result, 'C395', 'O');
  Result := Trocar(Result, 'C396', 'O');
  Result := Trocar(Result, 'C3BA', 'u');
  Result := Trocar(Result, 'C3B9', 'u');
  Result := Trocar(Result, 'C3BB', 'u');
  Result := Trocar(Result, 'C3BC', 'u');
  Result := Trocar(Result, 'C39A', 'U');
  Result := Trocar(Result, 'C399', 'U');
  Result := Trocar(Result, 'C39B', 'U');
  Result := Trocar(Result, 'C39C', 'U');
  Result := Trocar(Result, 'C3A7', 'c');
  Result := Trocar(Result, 'C387', 'C');
  Result := Trocar(Result, 'C3B1', 'n');
  Result := Trocar(Result, 'C391', 'N');
  Result := 'UPPER(' + Result + ')';
end;

end.
