val spinalVersion = "1.6.1"

name := "fpu-wrappers"
version := "1.0"

scalacOptions += "-Xsource:2.11"
libraryDependencies ++= Seq(
  "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion,
  "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion,
  compilerPlugin(
    "com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion
  ),
  "org.scalatest" %% "scalatest-funsuite" % "3.2.3" % "test",
  "edu.berkeley.cs" %% "chisel3" % "3.4.3",
  "edu.berkeley.cs" %% "chiseltest" % "0.3.3" % "test"
)
