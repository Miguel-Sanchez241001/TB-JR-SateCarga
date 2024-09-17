package pe.com.bn.service;

import org.apache.log4j.Logger;
import pe.com.bn.Enum.Cabeceras;
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
    private final BatchService batchService;

    public LoteService() {
        this.batchService = new BatchService();
    }

    public void process(InputParametros input) throws Exception {
        // Registrar los parámetros sin exponer información sensible
        log.info("Inicio del proceso con los parámetros de entrada.");

        String filePath = input.getPathFile();
        DbUtil dbUtil = DbUtil.getInstance(input.getUrlConection());
        int totalRegistrosProcesados = 0;  // Contador de registros procesados
        int totalRegistrosFallidos = 0;    // Contador de registros fallidos
        int totalRegistrosEsperados = 0;   // Total de registros que deberían procesarse (según la cabecera)
        log.debug("Ruta del archivo: " + input.getPathFile());


        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {

            String line = br.readLine();
            log.info("Encabezado del archivo omitido, iniciando la lectura de registros.");
            totalRegistrosEsperados = descripcionArchivo(line);  // Extraer el número total de registros de la cabecera

            // Determinar el tipo de tabla basado en el tipo de proceso
            TableType tableType = getTableType(input);
            log.info("Tipo de proceso identificado: " + tableType);

            // Genera la consulta de inserción para la tabla correspondiente
            String sql = QueryUtil.generateInsertQuery(tableType);
            log.debug("Consulta SQL de inserción generada para la tabla: " + tableType);

            // Procesar cada línea del archivo
            while ((line = br.readLine()) != null) {
                Object dtoGenerico = null;
                try {
                    dtoGenerico = this.batchService.saveLote(line, input.getTypeProcess(), input.getTypeProcessMC());
                    log.debug("Línea procesada y objeto DTO generado correctamente.");
                    Object[] params = getInsertParams(dtoGenerico, tableType);


                    // Ejecutar la inserción en la base de datos
                    int rowsAffected = dbUtil.insert(sql, params);
                    if (rowsAffected > 0) {
                        totalRegistrosProcesados++;
                    } else {
                        totalRegistrosFallidos++;
                    }
                } catch (Exception e) {
                    totalRegistrosFallidos++;
                    log.error("Error al procesar la línea: " + e.getMessage());
                }

            }

            // Mostrar los resultados al final
            log.info("Procesamiento de archivo completado.");
            log.info("Total de registros esperados: " + totalRegistrosEsperados);
            log.info("Total de registros procesados correctamente: " + totalRegistrosProcesados);
            log.info("Total de registros fallidos: " + totalRegistrosFallidos);

        } catch (Exception e) {
            log.error("Error durante el procesamiento del archivo: " + e.getMessage(), e);
            throw new ProcessException("Error al procesar el archivo: " + e.getMessage());
        }
    }

    private Object[] getInsertParams(Object dtoGenerico, TableType tableType) {
        if (TableType.RPTA_MEF_TEMP.equals(tableType)) {
            DtoLoteMEF dtoLoteMEF = (DtoLoteMEF) dtoGenerico;
            return new Object[]{
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
        } else {
            DtoLoteMC dtoLoteMC = (DtoLoteMC) dtoGenerico;
            return new Object[]{
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
        }
    }

    private TableType getTableType(InputParametros input) throws ProcessException {
        if ("1".equals(input.getTypeProcess())) {
            return TableType.RPTA_MC_TEMP;
        } else if ("2".equals(input.getTypeProcess())) {
            return TableType.RPTA_MEF_TEMP;
        } else {
            throw new ProcessException("Tipo de proceso no soportado.");
        }
    }


    private int descripcionArchivo(String line) {
        int totalRegistros = 0;
        for (Cabeceras cabecera : Cabeceras.values()) {
            int startIndex = cabecera.getPosicionIncial() - 1;
            int endIndex = startIndex + cabecera.getTamaño();
            String valor = line.substring(startIndex, endIndex).trim();

            // Manejar el caso específico de la fecha
            if ("Fecha".equals(cabecera.getName())) {
                String fecha = valor;
                String fechaFormateada = fecha.substring(0, 4) + "-" + fecha.substring(4, 6) + "-" + fecha.substring(6, 8);
                log.info(cabecera.getName() + ": " + fechaFormateada);
            }
            // Manejar el caso específico de los registros
            else if ("Regitros".equals(cabecera.getName())) {
                totalRegistros = Integer.parseInt(valor);  // Convertir el valor a entero
                log.info(cabecera.getName() + ": " + totalRegistros);
            } else {
                log.info(cabecera.getName() + ": " + valor);
            }
        }
        return totalRegistros;  // Retornar el número total de registros
    }


}
