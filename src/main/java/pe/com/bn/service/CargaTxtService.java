package pe.com.bn.service;

import com.google.inject.Inject;
import org.apache.log4j.Logger;
import pe.com.bn.Enum.Cabeceras;
import pe.com.bn.Enum.TableType;
import pe.com.bn.customexception.ProcessException;
import pe.com.bn.dto.DtoLoteMefComplete;
import pe.com.bn.model.InputParametros;
import pe.com.bn.util.componen.BeanMapperObject;
import pe.com.bn.util.DbUtil;
import pe.com.bn.util.QueryUtil;

import java.io.*;
import java.util.List;

import static pe.com.bn.util.Functions.getInsertParams;
import static pe.com.bn.util.Functions.getTableType;

public class CargaTxtService {
    private static final Logger log = Logger.getLogger(CargaTxtService.class);
    private final BeanMapperObject batchService;
    private final ArchivosService archivosService;
    private final InputParametros input;
    @Inject
    public CargaTxtService(BeanMapperObject batchService, ArchivosService archivosService, InputParametros inputParametros) {
        this.batchService = batchService;
        this.archivosService = archivosService;
        this.input = inputParametros;
    }

    public void process() throws Exception {
        archivosService.initArchivoRespuesta();

        String filePath = input.getPathFile();
        DbUtil dbUtil = DbUtil.getInstance(input.getUrlConection());
        int totalRegistrosProcesados = 0;  // Contador de registros procesados
        int totalRegistrosFallidos = 0;    // Contador de registros fallidos
        int totalRegistrosEsperados = 0;   // Total de registros que deberían procesarse (según la cabecera)
        log.debug("Ruta del archivo: " + input.getPathFile());

        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {

            TableType tableType = getTableType();
            log.info("Tipo de proceso identificado: " + tableType);
            String line = br.readLine();
            totalRegistrosEsperados = descripcionArchivo(line, tableType);
            DtoLoteMefComplete loteComplete = descripcionArchivoHeader(line, tableType);
            if (loteComplete != null) {
                return;
            }
            String sql = QueryUtil.generateInsertQuery(tableType);
            log.debug("Consulta SQL de inserción generada para la tabla: " + tableType);

            while ((line = br.readLine()) != null) {
                Object dtoGenerico = null;
                try {
                    dtoGenerico = this.batchService.getMapperObjectGeneric(line, input.getTypeProcess(), input.getTypeProcessMC());
                    log.debug("Línea procesada y objeto DTO generado correctamente.");
                    Object[] params = getInsertParams(dtoGenerico, tableType);

                    int rowsAffected = dbUtil.insert(sql, params);
                    if (rowsAffected > 0) {
                        totalRegistrosProcesados++;
                    } else {
                        totalRegistrosFallidos++;
                    }
                } catch (Exception e) {
                    archivosService.saveFailError(line);
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
            archivosService.saveFailErrorHead(String.valueOf(totalRegistrosFallidos));
            log.error("Error durante el procesamiento del archivo: " + e.getMessage(), e);
            throw new ProcessException("Error al procesar el archivo: " + e.getMessage());
        }
    }

    private DtoLoteMefComplete descripcionArchivoHeader(String line, TableType tableType) throws ProcessException {
        if (!tableType.equals(TableType.RPTA_MEF_TEMP)) {
            return null;
        }
        try {
            DtoLoteMefComplete loteMef = this.batchService.getMapperObject(line);
            return loteMef;
        } catch (Exception e) {
            throw new ProcessException(e.getMessage());
        }
    }

    private int descripcionArchivo(String line, TableType tableType) {
        int totalRegistros = 0;
        List<Cabeceras> cabeceraTemp = TableType.RPTA_MEF_TEMP.equals(tableType) ? Cabeceras.getCabeceraMEF() : Cabeceras.getCabeceraMC();

        for (Cabeceras cabecera : cabeceraTemp) {
            int startIndex = cabecera.getPosicionIncial() - 1;
            int endIndex = startIndex + cabecera.getTamaño();
            String valor = line.substring(startIndex, endIndex).trim();

            // Manejar el caso específico de la fecha
            if ("Fecha".equals(cabecera.getName())) {
                String fechaFormateada = valor.substring(0, 4) + "-" + valor.substring(4, 6) + "-" + valor.substring(6, 8);
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
