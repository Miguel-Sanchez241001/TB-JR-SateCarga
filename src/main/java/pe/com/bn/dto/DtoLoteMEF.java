package pe.com.bn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

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
    private String fecInicioAut;
    private String fecFinAut;
    private String importe;
    private String secOperacionRef;
    private String fechaRegistro;
}
