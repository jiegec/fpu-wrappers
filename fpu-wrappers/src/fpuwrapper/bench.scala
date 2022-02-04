package fpuwrapper

import spinal.core._
import spinal.lib.eda.bench._
import spinal.lib.eda.xilinx.VivadoFlow

import scala.collection.mutable.ArrayBuffer

/** Benchmark with Vivado
  */
trait VivadoBench extends App {
  def bench(name: String, paths: Seq[String], topModuleName: String) {
    val targets = ArrayBuffer[Target]()
    val vivadoPath = "/opt/Xilinx/Vivado/2020.2/bin"

    for (
      (family, device) <- Seq(
        ("Kintex 7", "xc7k325tffg900-3"),
        ("Virtex UltraScale+", "xcvu37p-fsvh2892-3-e")
      )
    ) {
      for (
        (freq, name) <- Seq(
          (50 MHz, "area"),
          (400 MHz, "fmax")
        )
      ) {
        targets += new Target {
          override def getFamilyName(): String = family
          override def synthesise(rtl: Rtl, workspace: String): Report = {
            VivadoFlow(
              frequencyTarget = freq,
              vivadoPath = vivadoPath,
              workspacePath = s"${workspace}_${name}",
              rtl = rtl,
              family = getFamilyName(),
              device = device
            )
          }
        }
      }
    }

    Bench(
      Seq(new Rtl {
        override def getName(): String = name
        override def getRtlPaths(): Seq[String] = paths
        override def getTopModuleName(): String = topModuleName
      }),
      targets,
      "/tmp/"
    )
  }
}
