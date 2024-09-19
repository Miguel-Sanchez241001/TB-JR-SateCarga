package pe.com.bn.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class InputParametros {
    private String urlConection;
    private String pathFile;
    private String pathFileFail;
    private String pathLogError;
    private String typeProcess;
    private String typeProcessMC;


}
