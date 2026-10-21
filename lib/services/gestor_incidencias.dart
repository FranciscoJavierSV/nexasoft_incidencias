import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  // se modifica la funcion y se le agregan los parametros y validaciones
  List<Incidencia> buscar(String texto,String prioridad,String estado) {
    if (texto.trim().isEmpty && prioridad.isEmpty && estado.isEmpty) return incidencias;
    return incidencias.where(
      (x) => x.titulo.toLowerCase().trim().contains(texto.toLowerCase().trim()) 
          || x.descripcion.toLowerCase().trim().contains(texto.toLowerCase().trim()))
          // Para completar el filtro se encadenan los demas where junto a el texto del filtro
          .where((x) => x.prioridad.toLowerCase().trim().contains(prioridad.toLowerCase().trim()))
          .where((x) => x.estado.toLowerCase().trim().contains(estado.toLowerCase().trim()))
          .toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    //linea borrada
    //if (estado == 'Pendiente') return cantidadPendientes;
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        break;
      }
    }
    // BUG_01
    // debe de guardar otra vez todos los datos del json
    await datos.guardar(incidencias);
  }

  // Replicar la funcion de cambiarEstado para cambiar la prioridad
  Future<void> cambiarPrioridad(String id, String prioridad) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].prioridad = prioridad;
        break;
      }
    }
    await datos.guardar(incidencias);
  }

  Future<void> crear(String titulo, String descripcion,String prioridad, String cliente,
      String categoria) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: prioridad,
    );
    incidencias.insert(0, nuevo);
    cantidadPendientes++;
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
