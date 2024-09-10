package pe.com.bn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Date;

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
    private Date fecApeCta;
    private String blq1Cta;
    private String blq2Cta;
    private String numTarj;
    private Date fecApeTarj;
    private String blq1Tarj;
    private Date fecVencTarj;
    private String codProd;
    private String linCred;
    private String tipoResp;
    private String codBlq;
    private String motBlq;
    private String cel;
    private String email;
    private Date fecReg;
    private String codAsig;
    private Date fecIniLin;
    private Date fecFinLin;
    private String codEntidad;

    @Override
    public String toString() {
        return "DtoLoteMC{" +
                "numTarj='" + numTarj + '\'' +
                ", fecVencTarj=" + fecVencTarj +
                ", fecApeTarj=" + fecApeTarj +
                ", apellidos='" + apellidos + '\'' +
                ", nombre='" + nombre + '\'' +
                ", numDoc='" + numDoc + '\'' +
                ", codProd='" + codProd + '\'' +
                ", tipoDoc='" + tipoDoc + '\'' +
                ", codEntidad='" + codEntidad + '\'' +
                ", fecReg=" + fecReg +
                '}';
    }
}