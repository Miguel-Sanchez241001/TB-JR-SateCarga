package pe.com.bn.service;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import pe.com.bn.Enum.Cabeceras;
import pe.com.bn.Enum.CodError;
import pe.com.bn.Enum.TableType;
import pe.com.bn.config.anotation.Injectar;
import pe.com.bn.config.anotation.ServiceBN;
import pe.com.bn.customexception.ProcessException;
import pe.com.bn.dto.DtoLoteMEF;
import pe.com.bn.dto.DtoLoteMefComplete;
import pe.com.bn.model.InputParametros;
import pe.com.bn.model.Validacion;
import pe.com.bn.repo.SateRepo;
import pe.com.bn.util.ArchivoUtil;
import pe.com.bn.util.DbUtil;
import pe.com.bn.util.MapperObject;
import pe.com.bn.util.QueryUtil;

import java.io.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


import static pe.com.bn.repo.SateRepo.verificarTarjetClienteRuc;
import static pe.com.bn.util.ArchivoUtil.escribirAlFinal;
import static pe.com.bn.util.ArchivoUtil.escribirLineas;
import static pe.com.bn.util.QueryUtil.getInsertParams;
import static pe.com.bn.util.TramaUtils.lpad;
import static pe.com.bn.util.TramaUtils.rpad;

@ServiceBN
public class CargaTxtService {
    private static final Logger log = Logger.getLogger(CargaTxtService.class);

    @Injectar
    private MapperObject mapperObject;
    private File responseProccessFail;
    @Injectar
    private InputParametros input;




    public void process() throws Exception {
        initFailResponse();


        String filePath = input.getPathFile();
        DbUtil dbUtil = DbUtil.getInstance(input.getUrlConection());
        int totalRegistrosProcesados = 0;  // Contador de registros procesados
        int totalRegistrosFallidos = 0;    // Contador de registros fallidos
        int totalRegistrosEsperados = 0;   // Total de registros que deberían procesarse (según la cabecera)
        log.debug("Ruta del archivo: " + input.getPathFile());


        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {

            TableType tableType = getTableType();
            log.info("Tipo de proceso identificado: " + tableType);
            String sql = QueryUtil.generateInsertQuery(tableType);
            log.debug("Consulta SQL de inserción generada para la tabla: " + tableType);
            String line = br.readLine();
            totalRegistrosEsperados = descripcionArchivo(line, tableType);
            DtoLoteMefComplete loteComplete = descripcionArchivoHeader(line, tableType);
            if (loteComplete != null) {

                List<String> lineasProcesar =  ArchivoUtil.leerLineasExceptoPrimera(filePath);
                if (! (loteComplete.getCantidadRegistros().compareTo(new BigDecimal(lineasProcesar.size())) == 0) ){
                    DtoLoteMEF dtoGenerico = (DtoLoteMEF) mapperObject.getMapperObjectGeneric(lineasProcesar.get(0), input.getTypeProcess(), input.getTypeProcessMC());
                    List<String> informacionValidacion = new ArrayList<>();
                    String descripcionError = "E" +
                            loteComplete.getNumeroLote() +
                            dtoGenerico.getSecOperacion() +
                            CodError.CodREGISTROS_ERRRADOS.getCodigo()+
                            rpad(CodError.CodREGISTROS_ERRRADOS.getDescricion(),30,' ');
                    informacionValidacion.add(descripcionError);
                    String cantidad = "C" +

                            lpad("1",6,'0');
                    informacionValidacion.add(cantidad);
                    escribirLineas(input.getPathFileFail(),informacionValidacion);
                    return;
                }

                /*
                *   1 leer cada linea
                *   2 Comvertir a objeto
                *   3 verficio si fechas es nula o inicio es mayor que final y agrego a lista validacioens e ignoro
                *   4 si todo esta esta bien valido recien valida la cuenta  si esta mal agrego a lista de validaicon e  ignoro
                *   5 verifico si existe la tarjeta y el cliente y el ruc si esta mal agrego a lsita e ignoro
                *   6 Si paso todas las validaciones. Inserto a la base de datos
                *   7 verifico si lsita esta vacia si es asi agrego mensaje de ok sino imprimo erroes de lsita
                * */
                List<Validacion> validacioens = new ArrayList<>();
                for (String linea:lineasProcesar ){
                    DtoLoteMEF dto= (DtoLoteMEF) mapperObject.getMapperObjectGeneric(linea, input.getTypeProcess(), input.getTypeProcessMC());

                    if (dto.getFecFinAut() == null || dto.getFecInicioAut() == null){
                        validacioens.add(new Validacion(dto.getSecOperacion(),CodError.CodFechasInvalidas));
                            continue;
                    }
                    if (dto.getFecInicioAut().compareTo(dto.getFecFinAut()) > 0) {
                        validacioens.add(new Validacion(dto.getSecOperacion(),CodError.CodRangoFechasInvalidas));
                        continue;
                    }
                    if (isValidCount(dto.getCuentaCargo())) {
                        validacioens.add(new Validacion(dto.getSecOperacion(),CodError.CodCuentaCerrada));
                        continue;
                    }

                     if(verificarTarjetClienteRuc(input,dto) == 0){
                         validacioens.add(new Validacion(dto.getSecOperacion(),CodError.CodClienteNoExiste));
                         continue;
                    }


                    Object[] params = getInsertParams(dto, tableType);

                    int rowsAffected = dbUtil.insert(sql, params);
                    if (rowsAffected > 0) {
                        totalRegistrosProcesados++;
                    } else {
                        totalRegistrosFallidos++;
                    }
                }

                if (validacioens.isEmpty()){
                    List<String> informacionValidacion = new ArrayList<>();
                    String descripcionError = "P" +
                            loteComplete.getNumeroLote() +
                             CodError.CodOK.getCodigo()+
                            rpad(CodError.CodOK.getDescricion(),30,' ');
                    informacionValidacion.add(descripcionError);
                    String cantidad = "C" +

                            lpad("1",6,'0');
                    informacionValidacion.add(cantidad);
                    escribirLineas(input.getPathFileFail(),informacionValidacion);
                }else{
                    List<String> informacionValidacion = new ArrayList<>();
                    for ( Validacion val :validacioens){
                        String descripcionError = "E" +
                                loteComplete.getNumeroLote() +
                                val.getNumeroSecuencia() +
                                val.getCodError().getCodigo()+
                                rpad(val.getCodError().getDescricion(),30,' ');
                        informacionValidacion.add(descripcionError);
                    }
                    escribirLineas(input.getPathFileFail(),informacionValidacion);
                    String cantidad = "C" +  lpad( String.valueOf(informacionValidacion.size()),6,'0');
                    escribirAlFinal(input.getPathFileFail(),cantidad);
                }


                return;
            }



            while ((line = br.readLine()) != null) {
                Object dtoGenerico = null;
                try {
                    dtoGenerico = this.mapperObject.getMapperObjectGeneric(line, input.getTypeProcess(), input.getTypeProcessMC());
                    log.debug("Línea procesada y objeto DTO generado correctamente.");
                    Object[] params = getInsertParams(dtoGenerico, tableType);

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
            log.error("Error durante el procesamiento del archivo: " + e.getMessage(), e);
            throw new ProcessException("Error al procesar el archivo: " + e.getMessage());
        }finally {
            dbUtil.close();
        }
    }

    private boolean isValidCount(String cuentaCargo) {
        // Lista de cuentas válidas en duro (elegidas de tu imagen)
        Set<String> cuentasValidas = new HashSet<>();
        cuentasValidas.add("00000000000000301019");
        cuentasValidas.add("00000000000000299294");


        // Validar si la cuenta está dentro de la lista
        return cuentasValidas.contains(cuentaCargo);
    }


    private DtoLoteMefComplete descripcionArchivoHeader(String line, TableType tableType) throws ProcessException {
        if (!tableType.equals(TableType.RPTA_MEF_TEMP)) {
            return null;
        }
        try {
            DtoLoteMefComplete loteMef = this.mapperObject.getMapperObject(line);
            return loteMef;
        } catch (Exception e) {
            throw new ProcessException(e.getMessage());
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

    private void initFailResponse() throws ProcessException {
        try {
            this.responseProccessFail = new File(input.getPathFileFail());
            if (!this.responseProccessFail.exists()) FileUtils.touch(this.responseProccessFail);
        } catch (IOException e) {
            log.error("Error Archivo - Fail: " + e.getMessage());
            log.error("Error PROCESO: " + getTableType().getTableName());
            throw new ProcessException("Error creando Archivo Fail Proceso: " + input.getPathFileFail());

        }
    }


    private TableType getTableType() throws ProcessException {
        if ("1".equals(input.getTypeProcess())) {
            return TableType.RPTA_MC_TEMP;
        } else if ("2".equals(input.getTypeProcess())) {
            return TableType.RPTA_MEF_TEMP;
        } else {
            throw new ProcessException("Tipo de proceso no soportado.");
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
