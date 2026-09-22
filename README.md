# DriveWise

## Sistema móvil de gestión del vehículo

DriveWise es una aplicación móvil creada para ayudar a los usuarios a organizar la información de sus vehículos.

La aplicación busca reunir en un solo lugar información como gastos, combustible, mantenimientos, documentos y recordatorios.

## Equipo

| Integrante | GitHub |
|---|---|
| Jorge Giraldo | [@jhraldo](https://github.com/jhraldo) |
| Santiago Echeverri | https://github.com/Tiago013 |
| Alejandra Villa | Pendient |

## Grupo

**20262-IF2004-PROGRAMACIÓN MÓVIL-G602svg**

## Tecnología

- Flutter
- Dart

## Estado del proyecto

Proyecto académico para la asignatura **Programación Móvil (IF2004)**.

En esta primera entrega se presenta el esqueleto navegable de la aplicación y las principales pantallas definidas para el proyecto.

## Pantallas principales

- Login
- Inicio
- Mi vehículo
- Detalle SOAT
- Gastos
- Nuevo gasto
- Recordatorios

La aplicación permite navegar entre las principales pantallas utilizando la navegación de Flutter.

## Alcance inicial

DriveWise busca permitir que el usuario pueda:

- Registrar y consultar vehículos.
- Consultar información del vehículo.
- Registrar gastos.
- Registrar combustible.
- Registrar mantenimientos.
- Consultar documentos.
- Tener recordatorios de fechas importantes.

Las funciones se irán desarrollando durante el semestre.

## Documentación

La definición completa del proyecto se encuentra en:

[Documento de definición](docs/definicion.md)

En este documento se encuentran el problema, objetivos, alcance, funcionalidades, requerimientos, reglas de negocio, modelo de datos, pantallas, mapa de navegación, historias de usuario y la arquitectura básica del proyecto.

## Cómo ejecutar el proyecto

Primero se debe tener instalado Flutter.

Desde la carpeta del proyecto se puede ejecutar:

```bash
flutter pub get
```

Después se inicia la aplicación con:

```bash
flutter run
```

## Estructura básica

```text
drivewise_app/
├── docs/
│   ├── definicion.md
│   ├── mockup/
│   └── presentacion/
├── lib/
│   ├── main.dart
│   ├── login.dart
│   ├── mi_vehiculo.dart
│   ├── detalle_soat.dart
│   ├── gastos.dart
│   ├── nuevo_gasto.dart
│   ├── recordatorios.dart
│   └── widgets/
├── test/
├── pubspec.yaml
└── README.md
```

## Capturas y mockups

Los mockups y materiales visuales del proyecto se encuentran en la carpeta:

docs/pantallas/


## Repositorio

El proyecto se encuentra en GitHub:

https://github.com/jhraldo/drivewise_app

## Uso de inteligencia artificial

Se utilizó inteligencia artificial como apoyo para resolver dudas, revisar errores y comprender algunos conceptos durante el desarrollo.

Los integrantes revisaron y adaptaron el contenido utilizado en el proyecto.
