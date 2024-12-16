package pe.com.bn.config.ioc;

import org.apache.log4j.Logger;
import org.reflections.Reflections;
import pe.com.bn.config.anotation.BeanBN;
import pe.com.bn.config.anotation.Injectar;
import pe.com.bn.config.anotation.ServiceBN;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class ContenedorIoC {
    private Map<Class<?>, Object> beans = new HashMap<>();
    private static final Logger log = Logger.getLogger(ContenedorIoC.class);

    public void escanearPaquete(String paquete) {
        log.debug("Iniciando escaneo del paquete: " + paquete);

        Reflections reflections = new Reflections(paquete);

        // Detecta clases anotadas con @BeanBN y @ServiceBN
        Set<Class<?>> clasesBean = reflections.getTypesAnnotatedWith(BeanBN.class);
        Set<Class<?>> clasesServicio = reflections.getTypesAnnotatedWith(ServiceBN.class);

        log.debug("Clases detectadas con @BeanBN: " + clasesBean);
        log.debug("Clases detectadas con @ServiceBN: " + clasesServicio);

        // Registra primero los @BeanBN
        registrarClases(clasesBean);

        // Luego registra los @ServiceBN
        registrarClases(clasesServicio);
    }

    private void registrarClases(Set<Class<?>> clases) {
        for (Class<?> clase : clases) {
            try {
                log.debug("Registrando clase: " + clase.getName());

                Constructor<?>[] constructores = clase.getDeclaredConstructors();
                Constructor<?> constructor = constructores[0]; // Usa el primer constructor por simplicidad
                Object instancia;

                if (constructor.getParameterCount() > 0) {
                    log.debug("Clase con constructor con dependencias: " + clase.getName());
                    // Resuelve dependencias del constructor
                    Object[] dependencias = new Object[constructor.getParameterCount()];
                    Class<?>[] parametros = constructor.getParameterTypes();

                    for (int i = 0; i < parametros.length; i++) {
                        dependencias[i] = resolverDependencia(parametros[i]);
                        log.debug("Dependencia resuelta para el constructor: " + parametros[i].getName() + " -> " + dependencias[i]);
                    }
                    instancia = constructor.newInstance(dependencias);
                } else {
                    log.debug("Clase con constructor sin dependencias: " + clase.getName());
                    instancia = clase.getDeclaredConstructor().newInstance();
                }

                // Registra la instancia
                Class<?>[] interfaces = clase.getInterfaces();
                if (interfaces.length == 0) {
                    beans.put(clase, instancia);
                    log.debug("Registrada clase como bean: " + clase.getName());
                } else {
                    for (Class<?> interfaz : interfaces) {
                        beans.put(interfaz, instancia);
                        log.debug("Registrada clase como implementación de interfaz: " + interfaz.getName());
                    }
                }

                // Inyección por campos (si hay campos anotados)
                inyectarDependencias(instancia);

            } catch (Exception e) {
                log.error("Error al registrar clase: " + clase.getName(), e);
                throw new RuntimeException("Error al registrar clase: " + clase.getName(), e);
            }
        }
    }

    private Object resolverDependencia(Class<?> tipo) {
        log.debug("Resolviendo dependencia para tipo: " + tipo.getName());

        // Si es un tipo básico o común, devuelve un valor predeterminado
        if (tipo.equals(String.class)) {
            log.debug("Resuelta dependencia como valor predeterminado: String vacío");
            return ""; // Valor predeterminado para String
        } else if (tipo.isPrimitive() || Number.class.isAssignableFrom(tipo)) {
            log.debug("Resuelta dependencia como valor predeterminado: 0");
            return 0; // Valor predeterminado para números
        }

        // Busca en los beans registrados
        Object bean = beans.get(tipo);
        if (bean == null) {
            log.error("No se pudo resolver dependencia: " + tipo.getName());
            throw new RuntimeException("No se pudo resolver dependencia: " + tipo);
        }
        log.debug("Dependencia resuelta: " + tipo.getName() + " -> " + bean.getClass().getName());
        return bean;
    }

    private void inyectarDependencias(Object instancia) throws IllegalAccessException {
        log.debug("Inyectando dependencias para instancia: " + instancia.getClass().getName());

        Field[] campos = instancia.getClass().getDeclaredFields();
        for (Field campo : campos) {
            if (campo.isAnnotationPresent(Injectar.class)) {
                log.debug("Campo anotado con @Injectar detectado: " + campo.getName() + " en clase " + instancia.getClass().getName());

                Object dependencia = beans.get(campo.getType());
                if (dependencia == null) {
                    log.error("No se pudo resolver dependencia para el campo: " + campo.getName() + " de tipo: " + campo.getType().getName());
                    throw new RuntimeException("No se pudo resolver dependencia para: " + campo.getType());
                }
                campo.setAccessible(true);
                campo.set(instancia, dependencia);
                log.debug("Dependencia inyectada: " + campo.getName() + " -> " + dependencia.getClass().getName());
            }
        }
    }

    public <T> T obtenerBean(Class<T> clase) {
        log.debug("Obteniendo bean para clase: " + clase.getName());
        return (T) beans.get(clase);
    }
}
