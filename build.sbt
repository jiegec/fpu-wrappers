ThisBuild / scalaVersion := "2.12.14"
val spinalVersion = "1.6.1"
val chisel3Version = "3.5.0-RC1"
val chiselTestVersion = "0.5.0-RC1"
scalacOptions := Seq("-Xsource:2.11", "-unchecked", "-deprecation")

lazy val commonSettings = Seq(
  Compile / scalaSource := baseDirectory.value / "main" / "scala",
  Compile / resourceDirectory := baseDirectory.value / "main" / "resources",
  libraryDependencies ++= Seq(
    "edu.berkeley.cs" %% "chisel3" % chisel3Version,
    "edu.berkeley.cs" %% "chiseltest" % chiselTestVersion,
    "org.scalatest" %% "scalatest-funsuite" % "3.2.10" % "test"
  ),
  resolvers ++= Seq(
    Resolver.sonatypeRepo("snapshots"),
    Resolver.sonatypeRepo("releases")
  )
)

lazy val hardfloat =
  Project(
    id = "hardfloat",
    base = file("thirdparty/berkeley-hardfloat") / "src"
  ).settings(commonSettings)

lazy val fudian =
  Project(id = "fudian", base = file("thirdparty/fudian") / "src")
    .settings(commonSettings)

lazy val core =
  Project(id = "fpu-wrappers", base = file("fpu-wrappers") / "src")
    .settings(commonSettings)
    .settings(
      Test / scalaSource := baseDirectory.value / "test" / "scala",
      libraryDependencies ++= Seq(
        "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion,
        "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion,
        compilerPlugin(
          "com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion
        ),
        compilerPlugin(
          "edu.berkeley.cs" %% "chisel3-plugin" % chisel3Version cross CrossVersion.full
        )
      )
    )
    .dependsOn(hardfloat)
    .dependsOn(fudian)

fork := true
