import mill._
import mill.scalalib.publish._
import scalalib._
import scalafmt._
import coursier.maven.MavenRepository
import $ivy.`com.goyeau::mill-scalafix:0.2.5`
import com.goyeau.mill.scalafix.ScalafixModule

// third party build.sc
import $file.thirdparty.`berkeley-hardfloat`.build

// learned from https://github.com/OpenXiangShan/fudian/blob/main/build.sc
val defaultVersions = Map(
  "chisel3" -> ("edu.berkeley.cs", "3.5.0-RC1", false),
  "chisel3-plugin" -> ("edu.berkeley.cs", "3.5.0-RC1", true),
  "chiseltest" -> ("edu.berkeley.cs", "0.5.0-RC1", false),
  "scalatest" -> ("org.scalatest", "3.2.10", false),
  "spinalhdl-core" -> ("com.github.spinalhdl", "1.6.0", false),
  "spinalhdl-lib" -> ("com.github.spinalhdl", "1.6.0", false),
  "spinalhdl-idsl-plugin" -> ("com.github.spinalhdl", "1.6.0", false)
)

val commonScalaVersion = "2.12.14"

def getVersion(dep: String) = {
  val (org, ver, cross) = defaultVersions(dep)
  val version = sys.env.getOrElse(dep + "Version", ver)
  if (cross)
    ivy"$org:::$dep:$version"
  else
    ivy"$org::$dep:$version"
}

trait CommonModule extends ScalaModule {
  def scalaVersion = commonScalaVersion

  // for snapshot dependencies
  override def repositoriesTask = T.task {
    super.repositoriesTask() ++ Seq(
      MavenRepository("https://oss.sonatype.org/content/repositories/snapshots")
    )
  }

  // for scalafix rules
  override def scalacOptions =
    Seq("-Ywarn-unused", "-Ywarn-adapted-args", "-deprecation")
}

object hardfloat extends thirdparty.`berkeley-hardfloat`.build.hardfloat {
  override def scalaVersion = commonScalaVersion

  // override with our chisel3 version
  override def chisel3IvyDeps = Agg(
    getVersion("chisel3")
  )
}

object fudian extends CommonModule with PublishModule {
  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel3"),
    getVersion("scalatest")
  )

  override def millSourcePath = os.pwd / "thirdparty" / "fudian"

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel3-plugin")
  )

  // publish
  def publishVersion = "1.0-SNAPSHOT"
  def pomSettings = PomSettings(
    description = artifactName(),
    organization = "cn.cas.ict",
    url = "https://github.com/openxiangshan/fudian",
    licenses = Seq(License.MIT), // Mulan PSL v2 is not included in Mill
    versionControl = VersionControl.github("openxiangshan", "fudian"),
    developers = Seq()
  )
}

object `fpu-wrappers`
    extends CommonModule
    with PublishModule
    with ScalafmtModule
    with ScalafixModule {
  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel3"),
    getVersion("chiseltest"),
    getVersion("spinalhdl-core"),
    getVersion("spinalhdl-lib")
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("spinalhdl-idsl-plugin"),
    getVersion("chisel3-plugin")
  )

  override def moduleDeps = super.moduleDeps ++ Seq(hardfloat, fudian)

  override def scalafixIvyDeps = Agg(
    ivy"com.github.liancheng::organize-imports:0.5.0"
  )

  object test extends Tests with TestModule.ScalaTest {
    override def ivyDeps = super.ivyDeps() ++ Agg(
      getVersion("scalatest")
    )
  }

  // publish
  def publishVersion = "1.0-SNAPSHOT"
  def pomSettings = PomSettings(
    description = artifactName(),
    organization = "je.jia",
    url = "https://github.com/jiegec/fpu-wrapeprs",
    licenses = Seq(License.MIT),
    versionControl = VersionControl.github("jiegec", "fpu-wrappers"),
    developers = Seq()
  )
}
