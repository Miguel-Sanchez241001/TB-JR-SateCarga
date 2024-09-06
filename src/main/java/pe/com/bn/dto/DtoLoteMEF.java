package pe.com.bn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

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
    private String nombreBeneficiario;
    private String numTarjetaAut;
    private Date fecInicioAut;
    private Date fecFinAut;
    private String importe;
    private String secOperacionRef;
    private Date fechaRegistro;  // Se mantiene como String para usar "SYSDATE"

}
