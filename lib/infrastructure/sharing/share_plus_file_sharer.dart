import 'package:ascend/application/ports/file_sharer.dart';
import 'package:share_plus/share_plus.dart';

/// [FileSharer] con la hoja de compartir del sistema (share_plus).
class SharePlusFileSharer implements FileSharer {
  const new();

  @override
  Future<void> shareFile(String path, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], subject: subject),
    );
  }
}
