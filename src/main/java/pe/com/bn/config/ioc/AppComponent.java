package pe.com.bn.config.ioc;

import dagger.Component;
import pe.com.bn.model.InputParametros;
import pe.com.bn.service.CargaTxtService;

@Component(modules = {AppModule.class})
public interface AppComponent {
    // Métodos para obtener las dependencias principales
    InputParametros inputParametros();
    CargaTxtService cargaTxtService();
}

