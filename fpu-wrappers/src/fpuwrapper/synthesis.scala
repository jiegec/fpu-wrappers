package fpuwrapper

import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption
import scala.io.Source
import scala.sys.process._

/** Synthesize code with Synopsys Design Compiler
  */
object Synthesis {
  def build(
      sources: Seq[String],
      toplevelName: String,
      folderName: String = null
  ) {
    val actualFolderName = if (folderName == null) {
      toplevelName
    } else {
      folderName
    }

    val dir = s"synWorkspace/${actualFolderName}/"
    Files.createDirectories(Paths.get(dir))

    // copy files to synWorkspace
    val names = (for (file <- sources) yield {
      val name = Paths.get(file).getFileName()
      Files.copy(
        Paths.get(file),
        Paths.get(s"${dir}/${name}"),
        StandardCopyOption.REPLACE_EXISTING
      )
      name.toString()
    }).toList

    // apply template
    var template = Source.fromResource("syn.tcl").mkString
    template = template.replace(
      "INPUT_VERILOG",
      names.filter((s) => s.endsWith(".v")).mkString(" ")
    )
    template = template.replace(
      "INPUT_VHDL",
      names.filter((s) => s.endsWith(".vhdl")).mkString(" ")
    )
    template = template.replace("TOPLEVEL_NAME", toplevelName)

    Files.write(
      Paths.get(s"${dir}/syn.tcl"),
      template.getBytes(StandardCharsets.UTF_8)
    )

    Process("dc_shell -f syn.tcl", new java.io.File(dir)) !
  }
}
