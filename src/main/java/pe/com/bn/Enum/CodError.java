package pe.com.bn.Enum;


import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum CodError {


    CodOK("000","PROCESO_OK"),
    CodREGISTROS_ERRRADOS("100","CANTIDAD REGISTROS ERRADA"),
    CodFechasInvalidas("007", "FECHAS INVALIDAS"),
    CodRangoFechasInvalidas("008","RANGO FECHAS INVALIDO" ),
    CodCuentaCerrada("001","CUENTA CERRADA" ),
    CodClienteNoExiste("006","NUMERO DOCUMENTO NO CORRESPONDE" );
    private String codigo;
    private String descricion;

}
