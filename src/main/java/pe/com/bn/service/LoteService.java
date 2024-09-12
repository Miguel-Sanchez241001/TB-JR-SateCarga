package pe.com.bn.service;

import org.apache.log4j.Logger;
import pe.com.bn.Enum.TableType;
import pe.com.bn.customexception.ProcessException;
import pe.com.bn.dto.DtoLoteMC;
import pe.com.bn.dto.DtoLoteMEF;
import pe.com.bn.model.InputParametros;
import pe.com.bn.util.DbUtil;
import pe.com.bn.util.QueryUtil;

import java.io.BufferedReader;
import java.io.FileReader;

public class LoteService {
    private static final Logger log = Logger.getLogger(LoteService.class);
    private BatchService batchService;
    public LoteService( ) {
        this.batchService = new BatchService();
    }

    public void process(InputParametros input) throws Exception {
        log.info("Parameters from shell: {}"+ input.toString());
        String filePath = input.getPathFile();
        log.info("{} file is located in: {}"+ filePath);
        DbUtil dbUtil = DbUtil.getInstance(input.getUrlConection());
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            // Omitir la primera línea
            String line = br.readLine();


            // Determina el tipo de tabla basado en el tipo de proceso
            TableType tableType;
            if ("1".equals(input.getTypeProcess())) {
                tableType = TableType.RPTA_MC_TEMP;
            } else if ("2".equals(input.getTypeProcess())) {
                tableType = TableType.RPTA_MEF_TEMP;
            } else {
                throw new ProcessException("Tipo de proceso no soportado: " + input.getTypeProcess());
            }
            // Genera la consulta de inserción para la tabla correspondiente
            String sql = QueryUtil.generateInsertQuery(tableType);
            log.info("INSERT: "+ sql );

            while ((line = br.readLine()) != null) {
                Object dtoGenerci = null;
                try {
                    dtoGenerci = this.batchService.saveLote(line,input.getTypeProcess(),input.getTypeProcessMC());

                }catch (Exception e){
                    log.error(e.getMessage() );
                    continue;
                }

                Object[] params;
                if (TableType.RPTA_MEF_TEMP.equals(tableType)) {
                    // Extrae los valores del DTO para usarlos como parámetros
                    DtoLoteMEF dtoLoteMEF = (DtoLoteMEF) dtoGenerci;
                    params = new Object[]{
                            dtoLoteMEF.getSecOperacion(),        // B13_SEC_OPERACION
                            dtoLoteMEF.getTipoOperacion(),       // B13_TIPO_OPERACION
                            dtoLoteMEF.getRucMefTemp(),          // B13_RUC_MEF_TEMP
                            dtoLoteMEF.getCuentaCargo(),         // B13_CUENTA_CARGO
                            dtoLoteMEF.getFecInicioAut(),        // B13_FEC_INICIO_AUT
                            dtoLoteMEF.getFecFinAut(),           // B13_FEC_FIN_AUT
                            dtoLoteMEF.getTipoTarjeta(),         // B13_TIPO_TARJETA
                            dtoLoteMEF.getMoneda(),              // B13_MONEDA
                            dtoLoteMEF.getImporte(),             // B13_IMPORTE
                            dtoLoteMEF.getTipoDocumento(),       // B13_TIPO_DOCUMENTO
                            dtoLoteMEF.getNumDocumento(),        // B13_NUM_DOCUMENTO
                            dtoLoteMEF.getFechaRegistro()        // B13_FECHA_REGISTRO (Fecha actual)
                    };
                    //aqui  dbUtil.insert(dtoLoteMEF);
                    log.info("DtoLoteMEF: "+ dtoLoteMEF.toString());


                }
                else{
                    // Extrae los valores del DTO para usarlos como parámetros
                    DtoLoteMC dtoLoteMC = (DtoLoteMC) dtoGenerci;
                    params = new Object[]{
                            dtoLoteMC.getTipoDoc(),
                            dtoLoteMC.getNumDoc(),
                            dtoLoteMC.getApellidos(),
                            dtoLoteMC.getNombre(),
                            dtoLoteMC.getFecReg(),
                            dtoLoteMC.getCodProd(),
                            dtoLoteMC.getNumTarj(),
                            dtoLoteMC.getFecApeTarj(),
                            dtoLoteMC.getFecVencTarj(),
                            dtoLoteMC.getTipoResp(),
                            dtoLoteMC.getCodEntidad(),
                            dtoLoteMC.getNumCuenta(),
                            dtoLoteMC.getFecApeCta(),
                            dtoLoteMC.getBlq1Cta(),
                    };
                    //aqui  dbUtil.insert(dtoLoteMEF);
                    log.info("dtoLoteMC: "+ dtoLoteMC.toString());
                }


               int rowsAffected = dbUtil.insert(sql, params);
                log.info("Filas insertadas: {}" + rowsAffected);
            }
        } catch (Exception e) {
            log.error("ERROR: {}"+ e.getMessage());
            throw new ProcessException(e.getMessage());
        }
    }
}
