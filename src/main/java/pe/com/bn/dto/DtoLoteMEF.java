package pe.com.bn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.sql.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoLoteMEF {
    private String secOperacion;
    private String tipoOperacion;
    private String cuentaCargo;
    private String tipoDocumento;
    private String numDocumento;
    private Date fecInicioAut;
    private Date fecFinAut;
    private BigDecimal importe;        // Cambiado a BigDecimal para manejar montos correctamente
    private String secOperacionRef;
    private Date fechaRegistro;        // Se mantiene como Date para usar "SYSDATE"
    private String rucMefTemp;         // Se agregó el campo RUC
    private String tipoTarjeta;
    private String moneda;
}

