import 'package:flutter_test/flutter_test.dart';

import 'package:drivewise_app/domain/models/llamado_revision.dart';
import 'package:drivewise_app/domain/models/modelo_vehiculo.dart';

void main() {
  group('ModeloVehiculo.fromJson', () {
    test('convierte un elemento del catálogo vPIC', () {
      final modelo = ModeloVehiculo.fromJson({
        'Make_ID': 473,
        'Make_Name': 'MAZDA',
        'Model_ID': 2072,
        'Model_Name': ' CX-5 ',
      });

      expect(modelo.idMarca, 473);
      expect(modelo.marca, 'MAZDA');
      expect(modelo.idModelo, 2072);
      expect(modelo.nombre, 'CX-5'); // sin espacios sobrantes
    });

    test('falla si falta el nombre del modelo', () {
      expect(
        () => ModeloVehiculo.fromJson({
          'Make_ID': 473,
          'Make_Name': 'MAZDA',
          'Model_ID': 2072,
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('LlamadoRevision.fromJson', () {
    test('convierte un llamado completo', () {
      final llamado = LlamadoRevision.fromJson({
        'NHTSACampaignNumber': '23V735000',
        'Manufacturer': 'Honda (American Honda Motor Co.)',
        'ReportReceivedDate': '02/11/2023',
        'Component': 'STEERING:RACK AND PINION:RACK',
        'Summary': 'Honda is recalling certain 2023-2024 Pilot vehicles.',
        'Consequence': 'Increases the risk of a crash.',
        'Remedy': 'Dealers will replace the part, free of charge.',
      });

      expect(llamado.numeroCampania, '23V735000');
      expect(llamado.componente, 'STEERING:RACK AND PINION:RACK');
      expect(llamado.solucion, contains('free of charge'));
    });

    test('usa valores por defecto en los textos que faltan', () {
      final llamado = LlamadoRevision.fromJson({
        'NHTSACampaignNumber': '20V001000',
      });

      expect(llamado.componente, 'Componente no indicado');
      expect(llamado.resumen, '');
      expect(llamado.fechaReporte, '');
    });
  });
}
