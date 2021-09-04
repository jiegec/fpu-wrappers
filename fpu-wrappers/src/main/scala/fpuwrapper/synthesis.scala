package fpuwrapper

import scala.io.Source
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.charset.StandardCharsets
import java.nio.file.StandardCopyOption
import scala.sys.process._

object Synthesis {
  def build(sources: Seq[String], toplevelName: String) {
    val dir = s"synWorkspace/${toplevelName}/"
    Files.createDirectories(Paths.get(dir))

    val names = for (file <- sources) yield {
      val name = Paths.get(file).getFileName()
      Files.copy(
        Paths.get(file),
        Paths.get(s"${dir}/${name}"),
        StandardCopyOption.REPLACE_EXISTING
      )
      name
    }

    var template = Source.fromResource("syn.tcl").mkString
    template = template.replace("INPUT_FILES", sources.mkString(" "))
    template = template.replace("TOPLEVEL_NAME", toplevelName)

    Files.write(
      Paths.get(s"${dir}/syn.tcl"),
      template.getBytes(StandardCharsets.UTF_8)
    )

    Process("dc_shell -f syn.tcl", new java.io.File(dir))!
  }
}
