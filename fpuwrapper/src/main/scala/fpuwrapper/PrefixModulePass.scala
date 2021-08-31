package fpuwrapper

import chisel3._
import chisel3.stage.ChiselStage

import firrtl._
import firrtl.options.Dependency
import firrtl.transforms.DedupModules
import firrtl.annotations.NoTargetAnnotation
import firrtl.passes.PassException
import firrtl.stage.RunFirrtlTransformAnnotation

// adapted from https://github.com/chipsalliance/chisel3/issues/1059#issuecomment-814353578

/** Specifies a global prefix for all module names. */
case class ModulePrefix(prefix: String) extends NoTargetAnnotation

object PrefixModulesPass extends Transform with DependencyAPIMigration {
  // we run after deduplication to save some work
  override def prerequisites = Seq(Dependency[DedupModules])

  // we do not invalidate the results of any prior passes
  override def invalidates(a: Transform) = false

  override protected def execute(state: CircuitState): CircuitState = {
    val prefixes = state.annotations.collect{ case a: ModulePrefix => a.prefix }.distinct
    prefixes match {
      case Seq() =>
        logger.info("[PrefixModulesPass] No ModulePrefix annotation found.")
        state
      case Seq("") => state
      case Seq(prefix) =>
        val c = state.circuit.mapModule(onModule(_, prefix))
        state.copy(circuit = c.copy(main = prefix + c.main))
      case other =>
        throw new PassException(s"[PrefixModulesPass] found more than one prefix annotation: $other")
    }
  }

  private def onModule(m: ir.DefModule, prefix: String): ir.DefModule = m match {
    case e : ir.ExtModule => e.copy(name = prefix + e.name)
    case mod: ir.Module =>
      val name = prefix + mod.name
      val body = onStmt(mod.body, prefix)
      mod.copy(name=name, body=body)
  }

  private def onStmt(s: ir.Statement, prefix: String): ir.Statement = s match {
    case i : ir.DefInstance => i.copy(module = prefix + i.module)
    case other => other.mapStmt(onStmt(_, prefix))
  }
}