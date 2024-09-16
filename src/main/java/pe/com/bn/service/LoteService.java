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

    public LoteService() {
        this.batchService = new BatchService();
    }

    public void process(InputParametros input) throws Exception {
        // Registrar los parámetros sin exponer información sensible
        log.info("Inicio del proceso con los parámetros de entrada.");
        log.debug("Ruta del archivo: " + input.getPathFile());

        String filePath = input.getPathFile();
        DbUtil dbUtil = DbUtil.getInstance(input.getUrlConection());

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            // Omitir la primera línea
            String line = br.readLine();
            log.info("Encabezado del archivo omitido, iniciando la lectura de registros.");

            // Determina el tipo de tabla basado en el tipo de proceso
            TableType tableType;
            if ("1".equals(input.getTypeProcess())) {
                tableType = TableType.RPTA_MC_TEMP;
            } else if ("2".equals(input.getTypeProcess())) {
                tableType = TableType.RPTA_MEF_TEMP;
            } else {
                throw new ProcessException("Tipo de proceso no soportado.");
            }
            log.info("Tipo de proceso identificado: " + tableType);

            // Genera la consulta de inserción para la tabla correspondiente
            String sql = QueryUtil.generateInsertQuery(tableType);
            log.debug("Consulta SQL de inserción generada para la tabla: " + tableType);

            // Procesar cada línea del archivo
            while ((line = br.readLine()) != null) {
                Object dtoGenerci = null;
                try {
                    dtoGenerci = this.batchService.saveLote(line, input.getTypeProcess(), input.getTypeProcessMC());
                    log.debug("Línea procesada y objeto DTO generado correctamente.");

                } catch (Exception e) {
                    log.error("Error al procesar la línea: " + e.getMessage());
                    continue; // Continuar con la siguiente línea
                }

                Object[] params;
                if (TableType.RPTA_MEF_TEMP.equals(tableType)) {
                    DtoLoteMEF dtoLoteMEF = (DtoLoteMEF) dtoGenerci;
                    params = new Object[]{
                            dtoLoteMEF.getSecOperacion(),
                            dtoLoteMEF.getTipoOperacion(),
                            dtoLoteMEF.getRucMefTemp(),
                            dtoLoteMEF.getCuentaCargo(),
                            dtoLoteMEF.getFecInicioAut(),
                            dtoLoteMEF.getFecFinAut(),
                            dtoLoteMEF.getTipoTarjeta(),
                            dtoLoteMEF.getMoneda(),
                            dtoLoteMEF.getImporte(),
                            dtoLoteMEF.getTipoDocumento(),
                            dtoLoteMEF.getNumDocumento(),
                            dtoLoteMEF.getFechaRegistro()
                    };
                    log.debug("Objeto DtoLoteMEF creado correctamente. Listo para insertar.");
                    // log.debug("DtoLoteMEF: " + dtoLoteMEF.toString()); // Comentar o eliminar para evitar logs sensibles

                } else {
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
                            dtoLoteMC.getBlq1Cta()
                    };
                    log.debug("Objeto DtoLoteMC creado correctamente. Listo para insertar.");
                    // log.debug("DtoLoteMC: " + dtoLoteMC.toString()); // Comentar o eliminar para evitar logs sensibles
                }

                // Ejecutar la inserción en la base de datos
                int rowsAffected = dbUtil.insert(sql, params);
                log.debug("Filas insertadas: " + rowsAffected);
            }

            log.info("Procesamiento de archivo completado correctamente.");

        } catch (Exception e) {
            log.error("Error durante el procesamiento del archivo: " + e.getMessage(), e);
            throw new ProcessException("Error al procesar el archivo: " + e.getMessage());
        }
    }
}
