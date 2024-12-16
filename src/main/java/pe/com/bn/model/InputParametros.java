package pe.com.bn.model;

import lombok.*;
import pe.com.bn.config.anotation.BeanBN;

@BeanBN
@Getter
@Setter
@ToString
public class InputParametros {
    private String urlConection;
    private String pathFile;
    private String pathFileFail;
    private String typeProcess;
    private String typeProcessMC;
}
