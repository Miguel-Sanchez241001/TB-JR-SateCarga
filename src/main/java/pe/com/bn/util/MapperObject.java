package pe.com.bn.util;

import org.apache.log4j.Logger;
import pe.com.bn.Enum.Bnsate12RptaMcTemp;
import pe.com.bn.Enum.Bnsate13RptaMefTemp;
import pe.com.bn.Enum.Cabeceras;
import pe.com.bn.Enum.TableType;
import pe.com.bn.config.anotation.BeanBN;
import pe.com.bn.customexception.ProcessException;
import pe.com.bn.dto.DtoLoteMC;
import pe.com.bn.dto.DtoLoteMEF;
import pe.com.bn.dto.DtoLoteMefComplete;

import java.math.BigDecimal;
import java.sql.Date;
import java.text.ParseException;
import java.util.List;


@BeanBN
public class MapperObject {
    private static final Logger log = Logger.getLogger(MapperObject.class);


    public <T> T getMapperObjectGeneric(String line, String typeProcess, String typeProcessMC) throws ProcessException {
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
                            log.error("Error Campo: ".concat(Bnsate13RptaMefTemp.B13_FEC_INICIO_AUT.getColumnName()));
                             dtoLoteMEF.setFecInicioAut(null);
                        }
                        break;
                    case B13_FEC_FIN_AUT:
                        try {
                            dtoLoteMEF.setFecFinAut(QueryUtil.convertStringToSqlDate(fieldValue));
                        } catch (ParseException e) {
                            log.error(e.getMessage());
                            log.error("Error Campo: ".concat(Bnsate13RptaMefTemp.B13_FEC_FIN_AUT.getColumnName()));
                            dtoLoteMEF.setFecFinAut(null);
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

                }
            }

            return (T) dtoLoteMEF; // Devuelve el DTO con los datos asignados
        } else {
            DtoLoteMC dtoLoteMC = new DtoLoteMC();
            if (typeProcessMC.equals("FICTA")) {
                for (Bnsate12RptaMcTemp field : Bnsate12RptaMcTemp.values()) {
                    String fieldValue = line.substring(field.getStart() - 1, field.getStart() + field.getEnd()).trim();

                    switch (field) {
                        case FEC_VENC_TARJ:
                            try {
                                dtoLoteMC.setFecVencTarj(QueryUtil.convertStringToSqlDate(fieldValue));
                            } catch (ParseException e) {
                                log.error(e.getMessage());
                                log.error("Error Campo: ".concat(Bnsate12RptaMcTemp.FEC_VENC_TARJ.getColumnName()));
                                //throw new ProcessException("Error en trama :" + line);
                                dtoLoteMC.setFecVencTarj(null);
                            }
                            break;
                        case FEC_APE_TARJ:
                            try {
                                dtoLoteMC.setFecApeTarj(QueryUtil.convertStringToSqlDate(fieldValue));
                            } catch (ParseException e) {
                                log.error(e.getMessage());
                                log.error("Error Campo: ".concat(Bnsate12RptaMcTemp.FEC_APE_TARJ.getColumnName()));
                                //throw new ProcessException("Error en trama :" + line);
                                dtoLoteMC.setFecApeTarj(null);
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
                        case SALDO:
                            BigDecimal bigDecimalValue = new BigDecimal(fieldValue);
                            dtoLoteMC.setSaldo(bigDecimalValue);
                            break;
                        case NUM_TARJ:
                            dtoLoteMC.setNumTarj(fieldValue);
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
                                log.error("Error Campo: ".concat(Bnsate12RptaMcTemp.FEC_APE_CTA.getColumnName()));
                                //throw new ProcessException("Error en trama :" + line);
                                dtoLoteMC.setFecApeCta(null);
                            }
                            break;
                        case BLQ1_CTA:
                            dtoLoteMC.setBlq1Cta(fieldValue);
                            break;
                    }

                }
                if (dtoLoteMC.getSaldo() != null
                        && dtoLoteMC.getSaldo().compareTo(BigDecimal.ZERO) == 0
                        && dtoLoteMC.getFecApeTarj() != null
                        && dtoLoteMC.getFecVencTarj() != null) {
                    // Saldo es 0 y fecha de tarjeta no es nula
                    dtoLoteMC.setTipoResp("0"); // RECEPCION DE SOLICITUD
                } else if (
                        dtoLoteMC.getSaldo() != null
                        && dtoLoteMC.getSaldo().compareTo(BigDecimal.ZERO) > 0
                        && dtoLoteMC.getFecApeTarj() != null
                        && dtoLoteMC.getFecVencTarj() != null) {
                    // Saldo es mayor a 0 y fecha de tarjeta no es nula
                    dtoLoteMC.setTipoResp("1"); // primera asigancion
                } else if (
                        dtoLoteMC.getSaldo() != null
                        && dtoLoteMC.getSaldo().compareTo(BigDecimal.ZERO) > 0
                        && dtoLoteMC.getFecApeTarj() == null
                        && dtoLoteMC.getFecVencTarj() == null) {
                    dtoLoteMC.setTipoResp("2"); // Desde segunda a mas asignaciones
                } else {
                    dtoLoteMC.setTipoResp("3");
                    throw new ProcessException("Error en trama :" + line);
                }
            }


            return (T) dtoLoteMC;
        }
    }

        public DtoLoteMefComplete getMapperObject(String line){

            List<Cabeceras> cabeceraTemp = Cabeceras.getCabeceraMEFDto();
            DtoLoteMefComplete dtoLoteMefComplete = new DtoLoteMefComplete();

            for (Cabeceras cabecera : cabeceraTemp) {
                int startIndex = cabecera.getPosicionIncial() - 1;
                int endIndex = startIndex + cabecera.getTamaño();
                String valor = line.substring(startIndex, endIndex).trim();
                switch (cabecera) {
                    case MEF_TTPHAB_NLOTE:
                        dtoLoteMefComplete.setNumeroLote(valor);
                        break;
                    case MEF_TTPHAB_FECHA:
                        dtoLoteMefComplete.setFechaGeneracion(valor);
                        break;
                    case MEF_TTPHAB_REGISTROS:
                         dtoLoteMefComplete.setCantidadRegistros(new BigDecimal(valor));
                        break;
                    case MEF_TTPHAB_IMPORTES:
                        dtoLoteMefComplete.setSumaImportes(new BigDecimal(valor));
                        break;

                }

            }
            return dtoLoteMefComplete;
        }
    }
