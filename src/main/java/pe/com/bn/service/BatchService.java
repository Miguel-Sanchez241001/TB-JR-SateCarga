package pe.com.bn.service;

import pe.com.bn.Enum.Bnsate13RptaMefTemp;
import pe.com.bn.Enum.TableType;
import pe.com.bn.dto.DtoLoteMEF;

public class BatchService {
    public String getLote(String line, String typeProcess) {
        return null;
    }

    public DtoLoteMEF saveLoteMef(String line, String typeProcess) {
        // Verifica si el tipo de proceso coincide
        if (typeProcess.equals(TableType.RPTA_MEF_TEMP.getTableNumber())) {
            DtoLoteMEF dtoLoteMEF = new DtoLoteMEF();

            // Itera sobre cada campo del enum para extraer su valor
            for (Bnsate13RptaMefTemp field : Bnsate13RptaMefTemp.values()) {
                // Obtiene el valor del campo usando los índices de inicio y fin
                String fieldValue = line.substring(field.getStart(), field.getEnd()).trim();

                // Asigna el valor extraído al campo correspondiente del DTO
                switch (field) {
                    case B13_SEC_OPERACION:
                        dtoLoteMEF.setSecOperacion(fieldValue);
                        break;
                    case B13_TIPO_OPERACION:
                        dtoLoteMEF.setTipoOperacion(fieldValue);
                        break;
                    case B13_CUENTA_CARGO:
                        dtoLoteMEF.setCuentaCargo(fieldValue);
                        break;
                    case B13_TIPO_DOCUMENTO:
                        dtoLoteMEF.setTipoDocumento(fieldValue);
                        break;
                    case B13_NUM_DOCUMENTO:
                        dtoLoteMEF.setNumDocumento(fieldValue);
                        break;
                    case B13_NOMBRE_BENEFICIARIO:
                        dtoLoteMEF.setNombreBeneficiario(fieldValue);
                        break;
                    case B13_NUM_TARJETA_AUT:
                        dtoLoteMEF.setNumTarjetaAut(fieldValue);
                        break;
                    case B13_FEC_INICIO_AUT:
                        dtoLoteMEF.setFecInicioAut(fieldValue);
                        break;
                    case B13_FEC_FIN_AUT:
                        dtoLoteMEF.setFecFinAut(fieldValue);
                        break;
                    case B13_IMPORTE:
                        dtoLoteMEF.setImporte(fieldValue);
                        break;
                    case B13_SEC_OPERACION_REF:
                        dtoLoteMEF.setSecOperacionRef(fieldValue);
                        break;
                    case B13_FECHA_REGISTRO:
                        dtoLoteMEF.setFechaRegistro(fieldValue);
                        break;
                    default:
                        // Manejo de cualquier caso inesperado
                        throw new IllegalArgumentException("Campo inesperado: " + field);
                }
            }

            return dtoLoteMEF; // Devuelve el DTO con los datos asignados
        } else {

        }

        return null;
    }
}
