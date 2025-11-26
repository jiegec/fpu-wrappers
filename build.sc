import mill._
import mill.scalalib.publish._
import scalalib._
import scalafmt._
import coursier.maven.MavenRepository

// learned from https://github.com/OpenXiangShan/fudian/blob/main/build.sc
val defaultVersions = Map(
  "chisel" -> ("org.chipsalliance", "6.2.0", false),
  "chisel-plugin" -> ("org.chipsalliance", "6.2.0", true),
  "scalatest" -> ("org.scalatest", "3.2.10", false),
  "spinalhdl-core" -> ("com.github.spinalhdl", "1.13.0", false),
  "spinalhdl-lib" -> ("com.github.spinalhdl", "1.13.0", false),
  "spinalhdl-idsl-plugin" -> ("com.github.spinalhdl", "1.13.0", false)
)

val commonScalaVersion = "2.13.10"

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

  override def scalacOptions =
    Seq("-deprecation", "-feature", "-language:reflectiveCalls")
}

object hardfloat extends SbtModule with PublishModule {
  override def scalaVersion = commonScalaVersion
  override def millSourcePath =
    os.pwd / "thirdparty" / "berkeley-hardfloat" / "hardfloat"

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel")
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
  )

  // publish
  def publishVersion = "1.5-SNAPSHOT"
  def pomSettings = PomSettings(
    description = artifactName(),
    organization = "edu.berkeley.cs",
    url = "http://chisel.eecs.berkeley.edu",
    licenses = Seq(License.`BSD-3-Clause`),
    versionControl = VersionControl.github("ucb-bar", "berkeley-hardfloat"),
    developers = Seq(
      Developer(
        "jhauser-ucberkeley",
        "John Hauser",
        "https://www.colorado.edu/faculty/hauser/about/"
      ),
      Developer(
        "aswaterman",
        "Andrew Waterman",
        "https://aspire.eecs.berkeley.edu/author/waterman/"
      ),
      Developer(
        "yunsup",
        "Yunsup Lee",
        "https://aspire.eecs.berkeley.edu/author/yunsup/"
      )
    )
  )
}

object fudian extends CommonModule with PublishModule {
  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel"),
    getVersion("scalatest")
  )

  override def millSourcePath = os.pwd / "thirdparty" / "fudian"

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("chisel-plugin")
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
    with ScalafmtModule {
  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel"),
    getVersion("spinalhdl-core"),
    getVersion("spinalhdl-lib")
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("spinalhdl-idsl-plugin"),
    getVersion("chisel-plugin")
  )

  override def moduleDeps = super.moduleDeps ++ Seq(hardfloat, fudian)

  object test extends ScalaTests with TestModule.ScalaTest {
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
