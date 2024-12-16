package pe.com.bn.Enum;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;
@Getter
@AllArgsConstructor
public enum Cabeceras {


    MC_FICTA_FECHA("Fecha",1,8),
    MC_FICTA_REGISTROS("Regitros",15,15),

    MEF_TTPHAB_NLOTE("NumLote",2,10),
    MEF_TTPHAB_FECHA("Fecha",12,8),
    MEF_TTPHAB_REGISTROS("Regitros",26,8),
    MEF_TTPHAB_IMPORTES("Importes",34,15) ;

    private String name;
    private int posicionIncial;
    private int tamaño;


    public static List<Cabeceras> getCabeceraMEFDto() {
        List<Cabeceras> mefHead = new ArrayList<>();
        mefHead.add(MEF_TTPHAB_NLOTE);
        mefHead.add(MEF_TTPHAB_FECHA);
        mefHead.add(MEF_TTPHAB_REGISTROS);
        mefHead.add(MEF_TTPHAB_IMPORTES);
        return mefHead;
    }

    public static List<Cabeceras> getCabeceraMC() {
        List<Cabeceras> mcFitar = new ArrayList<>();
        mcFitar.add(MC_FICTA_REGISTROS);
        mcFitar.add(MC_FICTA_FECHA);
        return mcFitar;
    }
    public static List<Cabeceras> getCabeceraMEF() {
        List<Cabeceras> mefHead = new ArrayList<>();
        mefHead.add(MEF_TTPHAB_REGISTROS);
        mefHead.add(MEF_TTPHAB_FECHA);
        return mefHead;
    }



}
