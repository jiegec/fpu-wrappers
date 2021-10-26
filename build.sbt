ThisBuild / scalaVersion := "2.12.14"
val spinalVersion = "1.6.1"

lazy val commonSettings = Seq(
  Compile / scalaSource := baseDirectory.value / "main" / "scala",
  Compile / resourceDirectory := baseDirectory.value / "main" / "resources",
  scalacOptions := Seq("-Xsource:2.11", "-unchecked", "-deprecation"),
  libraryDependencies ++= Seq(
    "edu.berkeley.cs" %% "chisel3" % "3.5-SNAPSHOT",
    "edu.berkeley.cs" %% "chiseltest" % "0.5-SNAPSHOT",
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
        )
      )
    )
    .dependsOn(hardfloat)
    .dependsOn(fudian)

fork := true
