package pe.com.bn.service;

import org.apache.log4j.Logger;
import pe.com.bn.Enum.TableType;
import pe.com.bn.customexception.ProcessException;
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
            String line = br.readLine(); // Lee y descarta la primera línea
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
            while ((line = br.readLine()) != null) {
                DtoLoteMEF dtoLoteMEF = this.batchService.saveLoteMef(line,input.getTypeProcess());
                // Extrae los valores del DTO para usarlos como parámetros
                Object[] params = {
                        dtoLoteMEF.getSecOperacion(),
                        dtoLoteMEF.getSecOperacionRef(),
                        dtoLoteMEF.getTipoOperacion(),
                        dtoLoteMEF.getCuentaCargo(),
                        dtoLoteMEF.getTipoDocumento(),
                        dtoLoteMEF.getNumDocumento(),
                        dtoLoteMEF.getFecInicioAut(),
                        dtoLoteMEF.getFecFinAut(),
                        dtoLoteMEF.getImporte(),
                        dtoLoteMEF.getFechaRegistro()
                };
               //aqui  dbUtil.insert(dtoLoteMEF);
                log.info("DtoLoteMEF: {}"+ dtoLoteMEF.toString());
                int rowsAffected = dbUtil.insert(sql, params);
                log.info("Filas insertadas: {}" + rowsAffected);
            }
        } catch (Exception e) {
            log.error("ERROR: {}"+ e.getMessage());
            throw new ProcessException(e.getMessage());
        }
    }
}
