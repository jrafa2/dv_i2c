# dv
Prácticas verificación. Asignatura "Test y Verificación", máster semiconductores UV

## Descargar el repositorio

1. Crea un usuario de github.
2. Haz un fork de este repositorio. Esto creará otro repositorio igual pero en tu usuario de github.
3. En tu home, ejecuta el siguiente comando:

`git clone <dirección de tu repo>`

Podrás subir lo que vayas haciendo desde la máquina virtual al repositorio de tanto en tanto.

### Bug tracking

Si ves bugs, ve a **Issues** y abre un ticket reportando el bug. Recuerda añadir el enlace del ticket en la tarea subida al aula virtual.

## Entorno

En el directorio bin/ hay otras utilidades que podrían ser útiles en algún caso.

En docs/ tenéis el documento de especificaciones del chip. El mismo del aula virtual.

En rtl/ tenéis el diseño a verificar.

En dv/ es donde trabajareis. Dentro de dv/vPlan/ debéis dejar vuestro vplan hecho en la práctica 2. En dv/coverage/ guardaréis ficheros de refinements.

### Compilación
Se ha creado el fichero *compile.sh* para poder compilar y simular tests. Ver:

`compile.sh -h`

Para compilar un test:

`compile.sh test_dummy`

Para compilar una regresión:

`compile.sh -r`

Y lee el fichero regr.list, donde se añadirá una línea por cada test que se quiera ejecutar. Puede haber más de un test repetido (varias líneas iguales).

A la hora de compilar **siempre** se generan las gráficas en waves.shm. Si se lanza otro test, se sobreescriben (incluido regresiones).

Para ver las gráficas:

`simvision waves.shm &`

Se pueden generar los ficheros de coverage con:

`compile.sh test_dummy -c`

Este flag es válido tanto para un test individual como para una regresión. En el caso de regresión, se tiene el coverage de cada test y uno llamado **all** con la suma de todos ellos.