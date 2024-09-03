package pe.com.bn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoLoteMC {
    private String trace;
    private String tipoDoc;
    private String numDoc;
    private String apellidos;
    private String nombre;
    private String numCuenta;
    private String fecApeCta;
    private String blq1Cta;
    private String blq2Cta;
    private String numTarj;
    private String fecApeTarj;
    private String blq1Tarj;
    private String fecVencTarj;
    private String codProd;
    private String linCred;
    private String tipoResp;
    private String codBlq;
    private String motBlq;
    private String cel;
    private String email;
    private String fecReg;
    private String codAsig;
    private String fecIniLin;
    private String fecFinLin;
}