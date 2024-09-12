package pe.com.bn.service;

import org.apache.log4j.Logger;
import pe.com.bn.Enum.Bnsate12RptaMcTemp;
import pe.com.bn.Enum.Bnsate13RptaMefTemp;
import pe.com.bn.Enum.TableType;
import pe.com.bn.customexception.ProcessException;
import pe.com.bn.dto.DtoLoteMC;
import pe.com.bn.dto.DtoLoteMEF;
import pe.com.bn.util.QueryUtil;

import java.math.BigDecimal;
import java.sql.Date;
import java.text.ParseException;

public class BatchService {
    private static final Logger log = Logger.getLogger(BatchService.class);

    public String getLote(String line, String typeProcess) {
        return null;
    }

    public <T> T saveLote(String line, String typeProcess, String typeProcessMC) throws ProcessException {
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
                        try {
                            dtoLoteMEF.setFecInicioAut(QueryUtil.convertStringToSqlDate(fieldValue));
                        } catch (ParseException e) {
                            log.error(e.getMessage());
                            throw new ProcessException("Error en trama :" + line);
                        }
                        break;
                    case B13_FEC_FIN_AUT:
                        try {
                            dtoLoteMEF.setFecFinAut(QueryUtil.convertStringToSqlDate(fieldValue));
                        } catch (ParseException e) {
                            log.error(e.getMessage());
                            throw new ProcessException("Error en trama :" + line);
                        }
                        break;
                    case B13_IMPORTE:
                        BigDecimal importe = new BigDecimal(fieldValue).movePointLeft(2);
                        dtoLoteMEF.setImporte(importe);
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

            return (T) dtoLoteMEF; // Devuelve el DTO con los datos asignados
        } else {
            DtoLoteMC dtoLoteMC = new DtoLoteMC();
            if (typeProcessMC.equals("FICTA")) {
                for (Bnsate12RptaMcTemp field : Bnsate12RptaMcTemp.values()) {
                    String fieldValue = line.substring(field.getStart()-1, field.getStart()+field.getEnd()).trim();

                    switch (field) {
                        case FEC_VENC_TARJ:
                            try {
                                dtoLoteMC.setFecVencTarj(QueryUtil.convertStringToSqlDate(fieldValue));
                            } catch (ParseException e) {
                                throw new RuntimeException(e);
                            }
                            break;
                        case TIPO_DOC:
                            dtoLoteMC.setTipoDoc(fieldValue);
                            break;
                        case NUM_DOC:
                            dtoLoteMC.setNumDoc(fieldValue);
                            break;
                        case APELLIDOS:
                            dtoLoteMC.setApellidos(fieldValue);
                            break;
                        case NOMBRE:
                            dtoLoteMC.setNombre(fieldValue);
                            break;
                        case COD_PROD:
                            dtoLoteMC.setCodProd(fieldValue);
                            break;
                        case TIPO_RESP:
                            dtoLoteMC.setTipoResp("0"); // FITAR
                            break;

                        case NUM_TARJ:
                            dtoLoteMC.setNumTarj(fieldValue);
                            break;
                        case FEC_APE_TARJ:
                            try {
                                dtoLoteMC.setFecApeTarj(QueryUtil.convertStringToSqlDate(fieldValue));
                            } catch (ParseException e) {
                                log.error(e.getMessage());
                                throw new ProcessException("Error en trama :" + line);
                            }
                            break;

                        case FEC_REG:
                            dtoLoteMC.setFecReg(new Date(System.currentTimeMillis())); // Fecha actual
                            break;
                        case COD_UNIDAD:
                            dtoLoteMC.setCodEntidad(fieldValue); // Fecha actual
                            break;
                        case NUM_CUENTA:
                            dtoLoteMC.setNumCuenta(fieldValue);
                            break;
                        case FEC_APE_CTA:
                            try {
                                dtoLoteMC.setFecApeCta(QueryUtil.convertStringToSqlDate(fieldValue)); // Fecha actual
                            } catch (ParseException e) {
                                log.error(e.getMessage());
                                throw new ProcessException("Error en trama :" + line);
                            }
                            break;
                        case BLQ1_CTA:
                            dtoLoteMC.setBlq1Cta(fieldValue);
                            break;
                    }
                }
            } else if (typeProcessMC.equals("FITAR")) {

            } else {
                throw new ProcessException("Tipo de procesoMC no soportado: " + typeProcessMC);

            }


            return (T) dtoLoteMC;
        }


    }
}