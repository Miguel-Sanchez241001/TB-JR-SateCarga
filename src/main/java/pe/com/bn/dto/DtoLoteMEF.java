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
    private String rucMefTemp;
    private String cuentaCargo;
    private Date fecInicioAut;
    private Date fecFinAut;
    private String tipoTarjeta;
    private String moneda;
    private BigDecimal importe;
    private String tipoDocumento;
    private String numDocumento;
    private String secOperacionRef;
    private Date fechaRegistro;


}

