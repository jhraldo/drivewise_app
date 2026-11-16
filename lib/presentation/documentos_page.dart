import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../domain/entities/documento.dart';

import '../data/firestore/firestore_documento_repository.dart';

import '../data/sqlite/sqlite_documento_repository.dart';

import '../data/repositories/documento_repository_coordinador.dart';

import '../services/documento_archivo_service.dart';

class DocumentosPage extends StatefulWidget {

  const DocumentosPage({

    super.key,

    required this.vehiculoId,

  });

  final String vehiculoId;

  @override

  State<DocumentosPage> createState() => _DocumentosPageState();

}

class _DocumentosPageState extends State<DocumentosPage> {

  DocumentoRepositoryCoordinador? _repositorio;

  final DocumentoArchivoService _archivoService =

      DocumentoArchivoService();

  List<Documento> _documentos = [];

  bool _cargando = true;

  String? _error;

  @override

  void initState() {

    super.initState();

    _inicializar();

  }

  // Inicializa SQLite y conecta los repositorios.

  Future<void> _inicializar() async {

    try {

      final sqlite = await SqliteDocumentoRepository.abrir();

      final repositorio = DocumentoRepositoryCoordinador(

        firestore: FirestoreDocumentoRepository(),

        sqlite: sqlite,

      );

      _repositorio = repositorio;

      await _cargarDocumentos();

    } catch (e) {

      if (!mounted) return;

      setState(() {

        _error = 'No fue posible inicializar los documentos: $e';

        _cargando = false;

      });

    }

  }

  // Consulta los documentos del vehículo.

  Future<void> _cargarDocumentos() async {

    if (_repositorio == null) return;

    try {

      final documentos = await _repositorio!.obtenerPorVehiculo(

        widget.vehiculoId,

      );

      if (!mounted) return;

      setState(() {

        _documentos = documentos;

        _cargando = false;

        _error = null;

      });

    } catch (e) {

      if (!mounted) return;

      setState(() {

        _error = 'Error al consultar los documentos: $e';

        _cargando = false;

      });

    }

  }

  // Registra o actualiza un documento.

  Future<void> _guardarDocumento(Documento documento) async {

    try {

      if (documento.id.isEmpty) return;

      final existente = _documentos.any(

        (item) => item.id == documento.id,

      );

      if (existente) {

        await _repositorio!.actualizar(documento);

      } else {

        await _repositorio!.guardar(documento);

      }

      await _cargarDocumentos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            existente

                ? 'Documento actualizado correctamente.'

                : 'Documento registrado correctamente.',

          ),

        ),

      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text('No fue posible guardar el documento: $e'),

        ),

      );

    }

  }

  // Elimina un documento.

  Future<void> _eliminarDocumento(Documento documento) async {

    final confirmar = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text('Eliminar documento'),

        content: const Text(

          '¿Estás seguro de que deseas eliminar este documento?',

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(context, false),

            child: const Text('Cancelar'),

          ),

          FilledButton(

            onPressed: () => Navigator.pop(context, true),

            child: const Text('Eliminar'),

          ),

        ],

      ),

    );

    if (confirmar != true) return;

    try {

      await _repositorio!.eliminar(

        documento.id,

        documento.vehiculoId,

      );

      await _cargarDocumentos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text('Documento eliminado correctamente.'),

        ),

      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text('No fue posible eliminar el documento: $e'),

        ),

      );

    }

  }

  // Abre el formulario para crear o editar un documento.

  Future<void> _mostrarFormulario({Documento? documento}) async {

    final resultado = await showDialog<Documento>(

      context: context,

      builder: (context) {

        return _FormularioDocumento(

          vehiculoId: widget.vehiculoId,

          documento: documento,

          archivoService: _archivoService,

        );

      },

    );

    if (resultado != null) {

      await _guardarDocumento(resultado);

    }

  }

  String _formatearFecha(DateTime fecha) {

    final dia = fecha.day.toString().padLeft(2, '0');

    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Documentos del vehículo'),

        actions: [

          IconButton(

            onPressed: _cargarDocumentos,

            icon: const Icon(Icons.refresh),

            tooltip: 'Actualizar',

          ),

        ],

      ),

      floatingActionButton: FloatingActionButton.extended(

        onPressed: _repositorio == null

            ? null

            : () => _mostrarFormulario(),

        icon: const Icon(Icons.add),

        label: const Text('Agregar documento'),

      ),

      body: _construirContenido(),

    );

  }

  Widget _construirContenido() {

    if (_cargando) {

      return const Center(

        child: CircularProgressIndicator(),

      );

    }

    if (_error != null) {

      return Center(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const Icon(

                Icons.error_outline,

                size: 48,

                color: Colors.red,

              ),

              const SizedBox(height: 12),

              Text(

                _error!,

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 16),

              FilledButton(

                onPressed: _inicializar,

                child: const Text('Intentar nuevamente'),

              ),

            ],

          ),

        ),

      );

    }

    if (_documentos.isEmpty) {

      return Center(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Icon(

                Icons.folder_open,

                size: 72,

                color: Colors.grey.shade500,

              ),

              const SizedBox(height: 16),

              const Text(

                'No hay documentos registrados',

                style: TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 8),

              const Text(

                'Agrega los documentos de tu vehículo '

                'para mantenerlos organizados.',

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 20),

              FilledButton.icon(

                onPressed: () => _mostrarFormulario(),

                icon: const Icon(Icons.add),

                label: const Text('Registrar documento'),

              ),

            ],

          ),

        ),

      );

    }

    return RefreshIndicator(

      onRefresh: _cargarDocumentos,

      child: ListView(

        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),

        children: [

          Text(

            '${_documentos.length} documento(s) registrado(s)',

            style: Theme.of(context).textTheme.titleMedium,

          ),

          const SizedBox(height: 12),

          ..._documentos.map(_construirTarjeta),

        ],

      ),

    );

  }


  Future<void> _abrirVistaPrevia(Documento documento) async {
  final bytes = documento.soporteBytes;

  if (bytes == null || bytes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se encontraron los datos del archivo.'),
      ),
    );
    return;
  }

  final nombre = documento.soporteNombre ?? 'Documento';
  final nombreLower = nombre.toLowerCase();
  final mime = documento.soporteMimeType?.toLowerCase() ?? '';

  final esPdf = mime == 'application/pdf' ||
      nombreLower.endsWith('.pdf');

  final esImagen = mime.startsWith('image/') ||
      nombreLower.endsWith('.jpg') ||
      nombreLower.endsWith('.jpeg') ||
      nombreLower.endsWith('.png') ||
      nombreLower.endsWith('.webp');

  if (!esPdf && !esImagen) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este formato no tiene vista previa disponible.'),
      ),
    );
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(
            nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: esPdf
            ? SfPdfViewer.memory(bytes)
            : Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      ),
    ),
  );
}

  Widget _construirTarjeta(Documento documento) {
    final tieneSoporte =
        documento.soporteBytes != null ||
        documento.soporteLocalPath != null ||
        documento.soporteUrl != null;

    final nombreArchivo = documento.soporteNombre ??
        (documento.soporteLocalPath == null
            ? null
            : documento.soporteLocalPath!
                .split(RegExp(r'[/\\]'))
                .last);

    final estado = documento.estado;

    final colorEstado = estado == 'Vencido'
        ? Colors.red
        : estado == 'Vigente'
            ? Colors.green
            : Colors.blueGrey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documento.tipo.isEmpty
                            ? 'Documento adjunto'
                            : documento.tipo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (documento.numero.isNotEmpty)
                        Text('Número: ${documento.numero}'),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (opcion) {
                    if (opcion == 'editar') {
                      _mostrarFormulario(documento: documento);
                    } else if (opcion == 'eliminar') {
                      _eliminarDocumento(documento);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Expedición: ${_formatearFecha(documento.fechaExpedicion)}',
            ),
            const SizedBox(height: 5),
            Text(
              documento.fechaVencimiento == null
                  ? 'Vencimiento: No especificado'
                  : 'Vencimiento: '
                      '${_formatearFecha(documento.fechaVencimiento!)}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 11,
                  color: colorEstado,
                ),
                const SizedBox(width: 7),
                Text(
                  estado,
                  style: TextStyle(
                    color: colorEstado,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (tieneSoporte)
                  const Row(
                    children: [
                      Icon(Icons.attach_file, size: 17),
                      SizedBox(width: 4),
                      Text('Tiene soporte'),
                    ],
                  )
                else
                  const Text('Sin soporte'),
              ],
            ),
                        if (nombreArchivo != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _abrirVistaPrevia(documento),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          nombreArchivo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// Formulario para registrar y editar documentos.

class _FormularioDocumento extends StatefulWidget {

  const _FormularioDocumento({

    required this.vehiculoId,

    required this.archivoService,

    this.documento,

  });

  final String vehiculoId;

  final DocumentoArchivoService archivoService;

  final Documento? documento;

  @override

  State<_FormularioDocumento> createState() =>

      _FormularioDocumentoState();

}

class _FormularioDocumentoState extends State<_FormularioDocumento> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tipoController;

  late final TextEditingController _numeroController;

  late DateTime _fechaExpedicion;

  DateTime? _fechaVencimiento;

  String? _soporteLocalPath;

  String? _soporteUrl;

  Uint8List? _soporteBytes;

  String? _soporteNombre;

  String? _soporteMimeType;

  bool _seleccionandoArchivo = false;

  @override

  void initState() {

    super.initState();

    final documento = widget.documento;

    _tipoController = TextEditingController(

      text: documento?.tipo ?? '',

    );

    _numeroController = TextEditingController(

      text: documento?.numero ?? '',

    );

    _fechaExpedicion =

        documento?.fechaExpedicion ?? DateTime.now();

    _fechaVencimiento = documento?.fechaVencimiento;

    _soporteLocalPath = documento?.soporteLocalPath;

    _soporteUrl = documento?.soporteUrl;

    _soporteBytes = documento?.soporteBytes;

    _soporteNombre = documento?.soporteNombre;

    _soporteMimeType = documento?.soporteMimeType;

  }

  @override

  void dispose() {

    _tipoController.dispose();

    _numeroController.dispose();

    super.dispose();

  }

  String _formatearFecha(DateTime fecha) {

    final dia = fecha.day.toString().padLeft(2, '0');

    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';

  }

  Future<void> _seleccionarFecha({

    required bool esVencimiento,

  }) async {

    final fechaActual =

        esVencimiento ? _fechaVencimiento : _fechaExpedicion;

    final fecha = await showDatePicker(

      context: context,

      initialDate: fechaActual ?? DateTime.now(),

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),

      helpText: esVencimiento

          ? 'Fecha de vencimiento'

          : 'Fecha de expedición',

    );

    if (fecha == null || !mounted) return;

    setState(() {

      if (esVencimiento) {

        _fechaVencimiento = fecha;

      } else {

        _fechaExpedicion = fecha;

      }

    });

  }

  Future<void> _seleccionarArchivo(String tipo) async {
    setState(() {
      _seleccionandoArchivo = true;
    });

    try {
      DocumentoArchivo? archivo;

      if (tipo == 'pdf') {
        archivo = await widget.archivoService.seleccionarPdf();
      } else if (tipo == 'galeria') {
        archivo = await widget.archivoService.seleccionarFotografia();
      } else if (tipo == 'camara') {
        archivo = await widget.archivoService.tomarFotografia();
      }

      if (!mounted) return;

      final archivoSeleccionado = archivo;
      if (archivoSeleccionado != null) {
        setState(() {
          _soporteBytes = archivoSeleccionado.bytes;
          _soporteNombre = archivoSeleccionado.nombre;
          _soporteMimeType = archivoSeleccionado.mimeType;
          _soporteLocalPath = null;
          _soporteUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible seleccionar el archivo: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _seleccionandoArchivo = false;
        });
      }
    }
  }

  void _quitarSoporte() {
    setState(() {
      _soporteLocalPath = null;
      _soporteUrl = null;
      _soporteBytes = null;
      _soporteNombre = null;
      _soporteMimeType = null;
    });
  }

  void _guardar() {
    final tipo = _tipoController.text.trim();
    final numero = _numeroController.text.trim();

    final tieneArchivo =
        _soporteBytes != null ||
        _soporteLocalPath != null ||
        (_soporteUrl?.isNotEmpty ?? false);

    // Se permite registrar únicamente un archivo o los datos manuales.
    if (!tieneArchivo && (tipo.isEmpty || numero.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa el tipo y número del documento o adjunta un archivo.',
          ),
        ),
      );
      return;
    }

    if (_fechaVencimiento != null &&
        _fechaVencimiento!.isBefore(_fechaExpedicion)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de vencimiento no puede ser anterior '
            'a la fecha de expedición.',
          ),
        ),
      );
      return;
    }

    final documento = Documento(
      id: widget.documento?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      vehiculoId: widget.vehiculoId,
      tipo: tipo,
      numero: numero,
      fechaExpedicion: _fechaExpedicion,
      fechaVencimiento: _fechaVencimiento,
      soporteUrl: _soporteUrl,
      soporteLocalPath: _soporteLocalPath,
      soporteBytes: _soporteBytes,
      soporteNombre: _soporteNombre,
      soporteMimeType: _soporteMimeType,
    );

    Navigator.pop(context, documento);
  }

  @override

  Widget build(BuildContext context) {

    final nombreArchivo = _soporteNombre ??
        (_soporteLocalPath == null
            ? null
            : _soporteLocalPath!.split(RegExp(r'[/\\]')).last);

    return AlertDialog(

      title: Text(

        widget.documento == null

            ? 'Registrar documento'

            : 'Editar documento',

      ),

      content: SizedBox(

        width: 450,

        child: SingleChildScrollView(

          child: Form(

            key: _formKey,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                TextFormField(

                  controller: _tipoController,

                  decoration: const InputDecoration(

                    labelText: 'Tipo de documento',

                    hintText: 'Ej. SOAT, revisión técnico-mecánica',

                    prefixIcon: Icon(Icons.description_outlined),

                    border: OutlineInputBorder(),

                  ),

                ),

                const SizedBox(height: 14),

                TextFormField(

                  controller: _numeroController,

                  decoration: const InputDecoration(

                    labelText: 'Número del documento',

                    prefixIcon: Icon(Icons.numbers),

                    border: OutlineInputBorder(),

                  ),

                ),

                const SizedBox(height: 18),

                const Text(

                  'Fecha de expedición',

                  style: TextStyle(fontWeight: FontWeight.w600),

                ),

                const SizedBox(height: 6),

                OutlinedButton.icon(

                  onPressed: () => _seleccionarFecha(

                    esVencimiento: false,

                  ),

                  icon: const Icon(Icons.calendar_today),

                  label: Text(_formatearFecha(_fechaExpedicion)),

                ),

                const SizedBox(height: 12),

                const Text(

                  'Fecha de vencimiento (opcional)',

                  style: TextStyle(fontWeight: FontWeight.w600),

                ),

                const SizedBox(height: 6),

                Row(

                  children: [

                    Expanded(

                      child: OutlinedButton.icon(

                        onPressed: () => _seleccionarFecha(

                          esVencimiento: true,

                        ),

                        icon: const Icon(Icons.event),

                        label: Text(

                          _fechaVencimiento == null

                              ? 'Seleccionar fecha'

                              : _formatearFecha(_fechaVencimiento!),

                          overflow: TextOverflow.ellipsis,

                        ),

                      ),

                    ),

                    if (_fechaVencimiento != null)

                      IconButton(

                        onPressed: () {

                          setState(() {

                            _fechaVencimiento = null;

                          });

                        },

                        icon: const Icon(Icons.clear),

                        tooltip: 'Quitar vencimiento',

                      ),

                  ],

                ),

                const SizedBox(height: 22),

                const Text(

                  'Soporte del documento',

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                    fontSize: 16,

                  ),

                ),

                const SizedBox(height: 10),

                Wrap(

                  spacing: 8,

                  runSpacing: 8,

                  children: [

                    OutlinedButton.icon(

                      onPressed: _seleccionandoArchivo

                          ? null

                          : () => _seleccionarArchivo('pdf'),

                      icon: const Icon(Icons.picture_as_pdf),

                      label: const Text('PDF'),

                    ),

                    OutlinedButton.icon(

                      onPressed: _seleccionandoArchivo

                          ? null

                          : () => _seleccionarArchivo('galeria'),

                      icon: const Icon(Icons.photo_library),

                      label: const Text('Galería'),

                    ),

                    OutlinedButton.icon(

                      onPressed: _seleccionandoArchivo

                          ? null

                          : () => _seleccionarArchivo('camara'),

                      icon: const Icon(Icons.camera_alt),

                      label: const Text('Cámara'),

                    ),

                  ],

                ),

                if (_seleccionandoArchivo) ...[

                  const SizedBox(height: 12),

                  const LinearProgressIndicator(),

                ],

                if (nombreArchivo != null) ...[

                  const SizedBox(height: 12),

                  Container(

                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(

                      color: Theme.of(context)

                          .colorScheme

                          .surfaceContainerHighest,

                      borderRadius: BorderRadius.circular(8),

                    ),

                    child: Row(

                      children: [

                        const Icon(Icons.attach_file),

                        const SizedBox(width: 8),

                        Expanded(

                          child: Text(

                            nombreArchivo,

                            maxLines: 2,

                            overflow: TextOverflow.ellipsis,

                          ),

                        ),

                        IconButton(

                          onPressed: _quitarSoporte,

                          icon: const Icon(Icons.close),

                          tooltip: 'Quitar archivo',

                        ),

                      ],

                    ),

                  ),

                ] else if (_soporteUrl?.isNotEmpty == true) ...[

                  const SizedBox(height: 12),

                  const Text(

                    'Este documento tiene un soporte registrado.',

                  ),

                  TextButton.icon(

                    onPressed: _quitarSoporte,

                    icon: const Icon(Icons.delete_outline),

                    label: const Text('Quitar soporte'),

                  ),

                ],

                const SizedBox(height: 8),

                const Text(

                  'El archivo se conservará en el dispositivo. '

                  'Los datos del documento se sincronizarán con Firestore.',

                  style: TextStyle(fontSize: 12),

                ),

              ],

            ),

          ),

        ),

      ),

      actions: [

        TextButton(

          onPressed: _seleccionandoArchivo

              ? null

              : () => Navigator.pop(context),

          child: const Text('Cancelar'),

        ),

        FilledButton(

          onPressed: _seleccionandoArchivo ? null : _guardar,

          child: const Text('Guardar'),

        ),

      ],

    );

  }

}
