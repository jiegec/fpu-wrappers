package sifive {
  package enterprise {
    package firrtl {
      import _root_.firrtl.annotations._
      import _root_.firrtl.RenameMap
      import chisel3.RawModule

      case class NestedPrefixModulesAnnotation(
          val target: Target,
          prefix: String,
          inclusive: Boolean
      ) extends SingleTargetAnnotation[Target] {

        def duplicate(n: Target): Annotation =
          NestedPrefixModulesAnnotation(target, prefix, inclusive)
      }
    }

  }

}
