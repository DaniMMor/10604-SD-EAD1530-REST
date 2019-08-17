unit UPedidoRepositoryImpl;

interface

uses
  UPedidoRepositoryIntf, System.Rtti,UPizzaTamanhoEnum, UPizzaSaborEnum, UDBConnectionIntf, FireDAC.Comp.Client, UPedidoRetornoDTOImpl;

type
  TPedidoRepository = class(TInterfacedObject, IPedidoRepository)
  private
    FDBConnection: IDBConnection;
    FFDQuery: TFDQuery;
  public
    procedure efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
      const ATempoPreparo: Integer; const ACodigoCliente: Integer);
    function GETpedido(const ADocumentoCliente: string): TPedidoRetornoDTO;

    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  UDBConnectionImpl, System.SysUtils, Data.DB, FireDAC.Stan.Param;

const
  CMD_INSERT_PEDIDO: String = 'INSERT INTO tb_pedido (cd_cliente, dt_pedido, dt_entrega, vl_pedido, nr_tempopedido) VALUES (:pCodigoCliente, :pDataPedido, :pDataEntrega, :pValorPedido, :pTempoPedido)';
  CMD_SELECT_PEDIDO: string = 'select P.cd_cliente,P.dt_pedido,P.nr_tempopedido,P.vl_pedido,P.te_sabor,P.te_tamanho from tb_pedido P join tb_cliente C on (C.id = P.cd_cliente) where C.nr_documento = :Pnr_documento limit 1';

  { TPedidoRepository }

constructor TPedidoRepository.Create;
begin
  inherited;

  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;
end;

destructor TPedidoRepository.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

procedure TPedidoRepository.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
  const ATempoPreparo: Integer; const ACodigoCliente: Integer);
begin
  FFDQuery.SQL.Text := CMD_INSERT_PEDIDO;

  FFDQuery.ParamByName('pCodigoCliente').AsInteger := ACodigoCliente;
  FFDQuery.ParamByName('pDataPedido').AsDateTime := now();
  FFDQuery.ParamByName('pDataEntrega').AsDateTime := now();
  FFDQuery.ParamByName('pValorPedido').AsCurrency := AValorPedido;
  FFDQuery.ParamByName('pTempoPedido').AsInteger := ATempoPreparo;

  FFDQuery.Prepare;
  FFDQuery.ExecSQL(True);
end;

function TPedidoRepository.GETpedido(
  const ADocumentoCliente: string): TPedidoRetornoDTO;
begin
  FFDQuery.SQL.Text := CMD_SELECT_PEDIDO;
  FFDQuery.ParamByName('PNR_DOCUMENTO').AsString := ADocumentoCliente;
  FFDQuery.Open();
  if (FFDQuery.RecordCount = 0) then
    raise Exception.Create('Não foi encontrado pedido para o documento informado.');
  Result := TPedidoRetornoDTO.Create(
    TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(FFDQuery.FieldByName('TE_TAMANHO').AsString),
    TRttiEnumerationType.GetValue<TPizzaSaborEnum>(FFDQuery.FieldByName('te_sabor').AsString),
    FFDQuery.FieldByName('VL_PEDIDO').AsFloat,
    FFDQuery.FieldByName('NR_TEMPOPEDIDO').AsInteger);
end;

end.
