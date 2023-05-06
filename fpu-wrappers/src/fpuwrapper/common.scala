package fpuwrapper

import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption

/** Helper class to get resource
  */
object Resource {
  def path(name: String) = {
    val tmp = Paths.get(
      System.getProperty("java.io.tmpdir"),
      System.getProperty("user.name"),
      "resource"
    );
    tmp.toFile().mkdirs()
    val path = tmp.resolve(Paths.get(name).getFileName())

    val is = getClass().getResourceAsStream(name)
    Files.copy(is, path, StandardCopyOption.REPLACE_EXISTING)
    path.toFile().getAbsolutePath()
  }
}
