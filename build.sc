import mill._
import scalalib._
import scalafmt._
import coursier.maven.MavenRepository

// learned from https://github.com/OpenXiangShan/fudian/blob/main/build.sc
val defaultVersions = Map(
  "scala" -> "2.12.14",
  "chisel3" -> "3.5.0-RC1",
  "chisel3-plugin" -> "3.5.0-RC",
  "chiseltest" -> "0.5.0-RC1",
  "scalatest" -> "3.2.10",
  "spinalhdl-core" -> "1.6.1",
  "spinalhdl-lib" -> "1.6.1",
  "spinalhdl-idsl-plugin" -> "1.6.1"
)

def getVersion(org: String, dep: String, cross: Boolean = false) = {
  val version = sys.env.getOrElse(dep + "Version", defaultVersions(dep))
  if (cross)
    ivy"$org:::$dep:$version"
  else
    ivy"$org::$dep:$version"
}

object hardfloat extends ScalaModule {
  def scalaVersion = defaultVersions("scala")

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("edu.berkeley.cs", "chisel3"),
    getVersion("org.scalatest", "scalatest")
  )

  override def millSourcePath = os.pwd / "thirdparty" / "berkeley-hardfloat"
}

object fudian extends ScalaModule {
  def scalaVersion = defaultVersions("scala")

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("edu.berkeley.cs", "chisel3"),
    getVersion("org.scalatest", "scalatest")
  )

  override def millSourcePath = os.pwd / "thirdparty" / "fudian"
}

object `fpu-wrappers` extends ScalaModule with ScalafmtModule {
  def scalaVersion = defaultVersions("scala")

  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("edu.berkeley.cs", "chisel3"),
    getVersion("edu.berkeley.cs", "chiseltest"),
    getVersion("com.github.spinalhdl", "spinalhdl-core"),
    getVersion("com.github.spinalhdl", "spinalhdl-lib")
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("com.github.spinalhdl", "spinalhdl-idsl-plugin")
  )

  override def moduleDeps = super.moduleDeps ++ Seq(hardfloat, fudian)

  object test extends Tests with TestModule.ScalaTest {
    override def ivyDeps = super.ivyDeps() ++ Agg(
      getVersion("org.scalatest", "scalatest")
    )
  }
}
