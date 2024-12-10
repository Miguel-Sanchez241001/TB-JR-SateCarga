package pe.com.bn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DtoLoteMefComplete {
    private String numeroLote;
    private String fechaGeneracion;
    private String cantidadRegistros;
    private BigDecimal sumaImportes;
    private List<DtoLoteMEF> listaRegistros;
}
