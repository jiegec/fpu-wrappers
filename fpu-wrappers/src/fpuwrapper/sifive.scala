package sifive {
  package enterprise {
    package firrtl {
      import _root_.firrtl.annotations._

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
