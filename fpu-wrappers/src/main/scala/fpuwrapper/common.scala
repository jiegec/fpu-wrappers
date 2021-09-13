package fpuwrapper

import java.nio.file.Files
import java.nio.file.Paths

object Resource {
  def path(name: String) = {
    val tmp = Files.createTempDirectory("resource");
    val path = tmp.resolve(Paths.get(name).getFileName())

    val is = getClass().getResourceAsStream(name)
    Files.copy(is, path)
    path.toFile().getAbsolutePath()
  }
}
