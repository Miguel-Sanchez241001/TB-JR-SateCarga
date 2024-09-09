package pe.com.bn.service;

import pe.com.bn.Enum.Bnsate13RptaMefTemp;
import pe.com.bn.Enum.TableType;
import pe.com.bn.dto.DtoLoteMEF;
import pe.com.bn.util.QueryUtil;

import java.math.BigDecimal;
import java.sql.Date;
import java.text.ParseException;

public class BatchService {
    public String getLote(String line, String typeProcess) {
        return null;
    }

    public DtoLoteMEF saveLoteMef(String line, String typeProcess) throws ParseException {
        // Verifica si el tipo de proceso coincide
        if (typeProcess.equals(TableType.RPTA_MEF_TEMP.getTableNumber())) {
            DtoLoteMEF dtoLoteMEF = new DtoLoteMEF();

            for (Bnsate13RptaMefTemp field : Bnsate13RptaMefTemp.values()) {
                String fieldValue = line.substring(field.getStart(), field.getEnd()).trim();

                switch (field) {
                    case B13_SEC_OPERACION:
                        dtoLoteMEF.setSecOperacion(fieldValue);
                        break;
                    case B13_TIPO_OPERACION:
                        dtoLoteMEF.setTipoOperacion(fieldValue);
                        break;
                    case B13_RUC_MEF_TEMP:
                        dtoLoteMEF.setRucMefTemp(fieldValue); // Asigna el RUC
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
                    case B13_FEC_INICIO_AUT:
                        dtoLoteMEF.setFecInicioAut(QueryUtil.convertStringToSqlDate(fieldValue));
                        break;
                    case B13_FEC_FIN_AUT:
                        dtoLoteMEF.setFecFinAut(QueryUtil.convertStringToSqlDate(fieldValue));
                        break;
                    case B13_IMPORTE:
                        dtoLoteMEF.setImporte(new BigDecimal(fieldValue)); // Convierte el valor a BigDecimal
                        break;
                    case B13_TIPO_TARJETA:
                        dtoLoteMEF.setTipoTarjeta(fieldValue);
                        break;
                    case B13_MONEDA:
                        dtoLoteMEF.setMoneda(fieldValue);
                        break;
                    case B13_FECHA_REGISTRO:
                        dtoLoteMEF.setFechaRegistro(new Date(System.currentTimeMillis())); // Establece la fecha actual
                        break;
                    default:
                        throw new IllegalArgumentException("Campo inesperado: " + field);
                }
            }

            return dtoLoteMEF; // Devuelve el DTO con los datos asignados
        } else {

        }

        return null;
    }
}
