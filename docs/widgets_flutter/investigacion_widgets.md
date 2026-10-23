# Investigación de widgets en Flutter

**Estudiante:** Jorge Giraldo  
**Grupo:** 602  
**Proyecto:** Pausa

## Introducción

Para esta actividad escogí tres widgets de Flutter que no había utilizado de esta manera en un mismo proyecto. La idea fue hacer una aplicación sencilla llamada Pausa, donde se pudiera elegir el tiempo para descansar, seleccionar un rango de energía y mostrar un mensaje al presionar un botón.

Los widgets que utilicé fueron Slider, RangeSlider y SnackBar. Busqué información en la documentación de Flutter para entender cómo se usan y después los puse a funcionar en la aplicación.

## 1. Slider

El Slider es una barra que permite escoger un valor moviendo un pequeño círculo hacia los lados. Se puede utilizar en diferentes situaciones, por ejemplo, para ajustar el volumen o elegir cuánto tiempo queremos dedicar a una actividad.

En mi aplicación lo utilicé para seleccionar la duración de una pausa. El usuario puede elegir entre 5 y 60 minutos sin tener que escribir el número.

Este es el código que utilicé:

```dart
Slider(
  value: minutos,
  min: 5,
  max: 60,
  divisions: 11,
  label: '${minutos.round()} min',
  onChanged: (valor) {
    setState(() {
      minutos = valor;
    });
  },
)
```

Lo que hace que funcione es la variable `minutos`, que guarda el valor seleccionado. Con `min` y `max` establezco los límites, mientras que `divisions` permite avanzar en intervalos de 5 minutos.

La parte de `onChanged` se ejecuta cuando muevo el control. Allí utilizo `setState()` para actualizar el valor y hacer que el cambio se vea en pantalla.

Después de probarlo, entendí que este widget es útil cuando necesitamos que una persona seleccione un solo valor dentro de unos límites.

**Fuente consultada:** Flutter. *Slider class*. https://api.flutter.dev/flutter/material/Slider-class.html

## 2. RangeSlider

El RangeSlider se parece al Slider, pero tiene dos controles en lugar de uno. Esto permite escoger un valor inicial y uno final, formando un rango.

Lo utilicé en Pausa para seleccionar un rango de energía entre 1 y 10. Por ejemplo, puedo dejar el control entre 2 y 6 y ver esos valores en pantalla.

Este es el código principal:

```dart
RangeSlider(
  values: energia,
  min: 1,
  max: 10,
  divisions: 9,
  labels: RangeLabels(
    '${energia.start.round()}',
    '${energia.end.round()}',
  ),
  onChanged: (valores) {
    setState(() {
      energia = valores;
    });
  },
)
```

La diferencia con el widget anterior está en que aquí utilizo `RangeValues` para manejar los dos números. `energia.start` representa el valor inicial y `energia.end` el valor final.

Cuando muevo cualquiera de los controles, `onChanged` recibe el nuevo rango y `setState()` actualiza la pantalla.

Este widget me pareció interesante porque se puede utilizar, por ejemplo, para filtrar productos por precio mínimo y máximo. En mi aplicación solo representa un rango de energía; todavía no se usa para hacer otros cálculos.

**Fuente consultada:** Flutter. *RangeSlider class*. https://api.flutter.dev/flutter/material/RangeSlider-class.html

## 3. SnackBar

El SnackBar sirve para mostrar mensajes que aparecen durante un tiempo y después desaparecen. Es una forma de informar al usuario sobre algo que acaba de pasar sin tener que abrir otra pantalla.

En Pausa lo utilicé para mostrar un mensaje cuando se presiona el botón «Guardar mi momento».

Este es el código que utilicé:

```dart
ElevatedButton(
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tu pausa ha sido registrada.'),
      ),
    );
  },
  child: const Text('Guardar mi momento'),
)
```

En este caso, `onPressed` indica qué debe pasar cuando se presiona el botón. Después, `ScaffoldMessenger` permite mostrar el mensaje mediante `showSnackBar()`, y en `content` escribo el texto que quiero que aparezca.

Este widget también podría servir para avisar que se copió un texto o que se completó una acción.

Hay algo que debo aclarar sobre mi aplicación: el mensaje aparece cuando se presiona el botón, pero eso no significa que la pausa se guarde realmente. Por ahora, solo muestra una confirmación en pantalla.

**Fuentes consultadas:**

- Flutter. *SnackBar class*. https://api.flutter.dev/flutter/material/SnackBar-class.html
- Flutter. *Display a snackbar*. https://docs.flutter.dev/cookbook/design/snackbars

## ¿Qué diferencia hay entre los tres?

El Slider permite escoger un solo valor, el RangeSlider permite escoger dos valores para formar un rango y el SnackBar muestra un mensaje temporal.

Los tres cumplen funciones diferentes, pero pude utilizarlos juntos en la aplicación Pausa. Así, el usuario puede elegir cuánto tiempo quiere descansar, seleccionar su rango de energía y recibir una respuesta visual al presionar el botón.

## Pruebas en la aplicación

Para probar los widgets, los agregué a la pantalla principal de Pausa y los separé en archivos diferentes para mantener el código organizado.

- Con el Slider comprobé que podía cambiar la duración de la pausa y que el número se actualizaba.
- Con el RangeSlider comprobé que podía mover los dos extremos y cambiar el rango seleccionado.
- Con el SnackBar preparé un botón que muestra un mensaje al presionarlo.


## Referencias

Flutter. (s. f.). *Slider class*. https://api.flutter.dev/flutter/material/Slider-class.html

Flutter. (s. f.). *RangeSlider class*. https://api.flutter.dev/flutter/material/RangeSlider-class.html

Flutter. (s. f.). *SnackBar class*. https://api.flutter.dev/flutter/material/SnackBar-class.html

Flutter. (s. f.). *Display a snackbar*. https://docs.flutter.dev/cookbook/design/snackbars
