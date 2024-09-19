package pe.com.bn.service;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import pe.com.bn.Enum.Cabeceras;
import pe.com.bn.Enum.TableType;
import pe.com.bn.customexception.ProcessException;
import pe.com.bn.dto.DtoLoteMC;
import pe.com.bn.dto.DtoLoteMEF;
import pe.com.bn.model.InputParametros;
import pe.com.bn.util.DbUtil;
import pe.com.bn.util.MapperObject;
import pe.com.bn.util.QueryUtil;

import java.io.*;
import java.util.List;

public class CargaTxtService {
    private static final Logger log = Logger.getLogger(CargaTxtService.class);
    private final MapperObject batchService;
    private File responseProccessFail;
    private File responseProccessOK;
    public CargaTxtService() {
        this.batchService = new MapperObject();

    }



    public void process(InputParametros input) throws Exception {
        initFailResponse(input);


        String filePath = input.getPathFile();
        DbUtil dbUtil = DbUtil.getInstance(input.getUrlConection());
        int totalRegistrosProcesados = 0;  // Contador de registros procesados
        int totalRegistrosFallidos = 0;    // Contador de registros fallidos
        int totalRegistrosEsperados = 0;   // Total de registros que deberían procesarse (según la cabecera)
        log.debug("Ruta del archivo: " + input.getPathFile());


        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {

            String line = br.readLine();
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
                    dtoGenerico = this.batchService.getMapperObjectGeneric(line, input.getTypeProcess(), input.getTypeProcessMC());
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
                    saveFailError(line);

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
            saveFailErrorHead(String.valueOf(totalRegistrosFallidos));
            log.error("Error durante el procesamiento del archivo: " + e.getMessage(), e);
            throw new ProcessException("Error al procesar el archivo: " + e.getMessage());
        }
    }

    private void saveFailError(String mensaje) throws ProcessException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(responseProccessFail, true))) {
            writer.write(mensaje);
            writer.newLine();
        } catch (IOException e) {
            log.error("Error escribiendo en Archivo Fail: " + e.getMessage());
            throw new ProcessException("Error escribiendo en Archivo Fail: " + responseProccessFail.getPath());
        }
    }
    private void saveFailErrorHead(String mensaje) throws ProcessException {
        try {
            // Leer todo el contenido del archivo en una lista de líneas
            List<String> lineas = FileUtils.readLines(responseProccessFail, "UTF-8");

            // Insertar el nuevo mensaje al principio de la lista
            lineas.add(0, mensaje);

            // Escribir toda la lista de vuelta al archivo (sobreescribiendo el archivo original)
            FileUtils.writeLines(responseProccessFail, "UTF-8", lineas);
        } catch (IOException e) {
            log.error("Error escribiendo en primera fila del Archivo Fail: " + e.getMessage());
            throw new ProcessException("Error escribiendo en primera fila del Archivo Fail: " + responseProccessFail.getPath());
        }
        }
    private void initFailResponse(InputParametros input) throws ProcessException {
        try {
            this.responseProccessFail = new File(input.getPathFileFail());
            if (!this.responseProccessFail.exists())  FileUtils.touch(this.responseProccessFail);
        } catch (IOException e) {
            log.error("Error Archivo - Fail: " + e.getMessage());
            log.error("Error PROCESO: " + getTableType(input).getTableName());
            throw new ProcessException("Error creando Archivo Fail Proceso: " + input.getPathFileFail());

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
