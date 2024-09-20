package pe.com.bn.Enum;

import java.util.ArrayList;
import java.util.List;

public enum Cabeceras {


    MC_FICTA_FECHA("Fecha",12,8),
   MC_FICTA_REGISTROS("Regitros",26,8),

    MEF_TTPHAB_FECHA("Fecha",1,8),
    MEF_TTPHAB_REGISTROS("Regitros",15,15);

    private String name;
    private int posicionIncial;
    private int tamaño;

    Cabeceras(String name, int posicionIncial, int tamaño) {
        this.name = name;
        this.posicionIncial = posicionIncial;
        this.tamaño = tamaño;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getPosicionIncial() {
        return posicionIncial;
    }

    public void setPosicionIncial(int posicionIncial) {
        this.posicionIncial = posicionIncial;
    }

    public int getTamaño() {
        return tamaño;
    }

    public void setTamaño(int tamaño) {
        this.tamaño = tamaño;
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
