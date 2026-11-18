/// Compartir un archivo con otra app (correo, Drive, PC por USB…). El
/// usuario decide el destino; la app no envía nada por sí misma.
abstract interface class FileSharer {
  Future<void> shareFile(String path, {String? subject});
}
