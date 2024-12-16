package pe.com.bn.model;

import lombok.*;

import java.io.File;

@Getter
@Setter
@ToString
public class InputParametros {
    // Instancia única de la clase
    private static InputParametros instance;
    private String urlConection;
    private String pathFile;
    private String pathFileFail;
    private String pathLogError;
    private String typeProcess;
    private String typeProcessMC;
    private File responseProccessFail;
    private File responseProccessOK;



}
