package pe.com.bn.config.ioc;

import dagger.Module;
import dagger.Provides;
import pe.com.bn.model.InputParametros;
import pe.com.bn.service.ArchivosService;
import pe.com.bn.util.componen.BeanMapperObject;
import pe.com.bn.service.CargaTxtService;

@Module
public class AppModule {

    @Provides
    InputParametros provideInputParametros() {
        return new InputParametros();
    }

    @Provides
    BeanMapperObject provideBeanMapperObject() {
        return new BeanMapperObject();
    }

    @Provides
    ArchivosService provideArchivosService() {
        return new ArchivosService();
    }

    @Provides
    CargaTxtService provideCargaTxtService(InputParametros inputParametros,
                                           ArchivosService archivosService,
                                           BeanMapperObject beanMapperObject) {
        // Ajusta el constructor según tu implementación.
        return new CargaTxtService(inputParametros, archivosService, beanMapperObject);
    }
}

