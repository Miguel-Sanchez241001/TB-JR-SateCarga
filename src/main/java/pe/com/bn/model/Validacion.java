package pe.com.bn.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import pe.com.bn.Enum.CodError;

@Data
@AllArgsConstructor
public class Validacion {
    private String numeroSecuencia;
    private CodError codError;
}
