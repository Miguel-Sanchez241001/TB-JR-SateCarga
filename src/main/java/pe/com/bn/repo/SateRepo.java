package pe.com.bn.repo;

import pe.com.bn.config.anotation.Injectar;
import pe.com.bn.config.anotation.ServiceBN;
import pe.com.bn.dto.DtoLoteMEF;
import pe.com.bn.model.InputParametros;
import pe.com.bn.util.DbUtil;

import java.sql.SQLException;



public class SateRepo {




    public static int verificarTarjetClienteRuc(InputParametros input,DtoLoteMEF dto) throws SQLException {
        DbUtil dbUtil = DbUtil.getInstance(input.getUrlConection());
        String sql = "SELECT COUNT(*) " +
                "FROM BN_SATE.BNSATE05_TARJETA tar " +
                "JOIN BN_SATE.BNSATE00_EMPRESA empre ON tar.B00_ID_EMP = empre.B00_ID_EMP " +
                "JOIN BN_SATE.BNSATE06_CLIENTE clie ON tar.B06_ID_CLI = clie.B06_ID_CLI " +
                "WHERE empre.B00_NUM_RUC = ? " +
                "AND LPAD(clie.B06_TIPO_DOCUMENTO, 2, '0') = ? " +
                "AND LPAD(clie.B06_NUM_DOCUMENTO, 20, '0') = ? " +
                "AND LPAD(BN_SATE.BNFN_GET_TIPO_FROM_SATE_TO_MEF(tar.B05_DISENO), 2, '0') = ? " +
                "AND tar.B05_NUM_TARJETA IS NOT NULL";

        int count =  dbUtil.ejecutarCount(sql,dto.getRucMefTemp(),dto.getTipoDocumento(),dto.getNumDocumento(),dto.getTipoTarjeta() );
        return count;
    }
}
