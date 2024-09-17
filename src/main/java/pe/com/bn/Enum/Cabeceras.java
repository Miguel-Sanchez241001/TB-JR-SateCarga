package pe.com.bn.Enum;

public enum Cabeceras {


    MC_FICTA_FECHA("Fecha",1,8),
   MC_FICTA_REGISTROS("Regitros",15,15);

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
}
