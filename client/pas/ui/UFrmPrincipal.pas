unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    edtEnderecoBackend: TLabeledEdit;
    edtPortaBackend: TLabeledEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  Rest.JSON, MVCFramework.RESTClient, UEfetuarPedidoDTOImpl, System.Rtti,
  UPizzaSaborEnum, UPizzaTamanhoEnum, System.JSON;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Clt: TRestClient;
  oEfetuarPedido: TEfetuarPedidoDTO;
begin
  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oEfetuarPedido := TEfetuarPedidoDTO.Create;
    try
      oEfetuarPedido.PizzaTamanho :=
        TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(cmbTamanhoPizza.Text);
      oEfetuarPedido.PizzaSabor :=
        TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text);
      oEfetuarPedido.DocumentoCliente := edtDocumentoCliente.Text;
      mmRetornoWebService.Text := Clt.doPOST('/efetuarPedido', [],
        TJson.ObjecttoJsonString(oEfetuarPedido)).BodyAsString;
    finally
      oEfetuarPedido.Free;
    end;
  finally
    Clt.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  RestResponse: IRESTResponse;
  RestClient: TRESTClient;
  Resposta: TJSONValue;

begin
  RestClient := RestClient.Create(edtEnderecoBackend.Text, string(edtPortaBackend.Text).ToInteger());
  RestClient.ReadTimeOut(50000);
  RestResponse := RestClient.doGET('/GETpedido', [edtDocumentoCliente.Text]);

  Resposta := TJSONObject.ParseJSONValue(RestResponse.BodyAsString());
  mmRetornoWebService.Lines.CLEAR;
  mmRetornoWebService.Lines.Add('RESUMO DO PEDIDO');
  mmRetornoWebService.Lines.Add('');
  mmRetornoWebService.Lines.Add('TAMANHO: ' + COPY(RESPOSTA.GetValue<string>('PizzaTamanho'),3,15));
  mmRetornoWebService.Lines.Add('SABOR:' + COPY(RESPOSTA.GetValue<string>('PizzaSabor'),3,15));
  mmRetornoWebService.Lines.Add('');
  mmRetornoWebService.Lines.Add('VALOR: ' + FormatFloat('R$ ###,##0.00',RESPOSTA.GetValue<Double>('ValorTotalPedido')));
  mmRetornoWebService.Lines.Add('');
  mmRetornoWebService.Lines.Add('TEMPO DE PREPARO: ' + RESPOSTA.GetValue<Integer>('TempoPreparo').ToString()+' MINUTOS');

end;

end.
