import mill._
import scalalib._
import scalafmt._
import coursier.maven.MavenRepository

// learned from https://github.com/OpenXiangShan/fudian/blob/main/build.sc
val defaultVersions = Map(
  "chisel3" -> ("edu.berkeley.cs", "3.5.0-RC1", false),
  "chisel3-plugin" -> ("edu.berkeley.cs", "3.5.0-RC", false),
  "chiseltest" -> ("edu.berkeley.cs", "0.5.0-RC1", false),
  "scalatest" -> ("org.scalatest", "3.2.10", false),
  "spinalhdl-core" -> ("com.github.spinalhdl", "1.6.1", false),
  "spinalhdl-lib" -> ("com.github.spinalhdl", "1.6.1", false),
  "spinalhdl-idsl-plugin" -> ("com.github.spinalhdl", "1.6.1", false)
)

def getVersion(dep: String) = {
  val (org, ver, cross) = defaultVersions(dep)
  val version = sys.env.getOrElse(dep + "Version", ver)
  if (cross)
    ivy"$org:::$dep:$version"
  else
    ivy"$org::$dep:$version"
}

trait CommonModule extends ScalaModule {
  def scalaVersion = "2.12.14"
}

object hardfloat extends CommonModule {
  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel3"),
    getVersion("scalatest")
  )

  override def millSourcePath = os.pwd / "thirdparty" / "berkeley-hardfloat"
}

object fudian extends CommonModule {
  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel3"),
    getVersion("scalatest")
  )

  override def millSourcePath = os.pwd / "thirdparty" / "fudian"
}

object `fpu-wrappers` extends CommonModule with ScalafmtModule {
  override def ivyDeps = super.ivyDeps() ++ Agg(
    getVersion("chisel3"),
    getVersion("chiseltest"),
    getVersion("spinalhdl-core"),
    getVersion("spinalhdl-lib")
  )

  override def scalacPluginIvyDeps = super.scalacPluginIvyDeps() ++ Agg(
    getVersion("spinalhdl-idsl-plugin")
  )

  override def moduleDeps = super.moduleDeps ++ Seq(hardfloat, fudian)

  object test extends Tests with TestModule.ScalaTest {
    override def ivyDeps = super.ivyDeps() ++ Agg(
      getVersion("scalatest")
    )
  }
}
