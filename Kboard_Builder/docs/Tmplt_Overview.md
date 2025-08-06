# KBB Base Templates

The base distribution contains a number of templates that can be used as-is or remixed to meet
your needs.  The default templates are found in the `kboard_builder\templates` directory and
include,

- [`KBT_Flight_Card.svg`](KBT_Flight_Card.md) &ndash; a fixed-format kneeboard that contains
  basic information on Mission Data, Ground Procedures, Takeoff / Departure / Enroute, SPINS,
  AAR, and Arrival & Alternates. A sample definition file for a kneeboard using this template
  is available
  [here](sdefs/Definition_Flight_Card.xlsx).
- [`KBT_Grid_Card.svg`](KBT_Grid_Card.md) &ndash; a variable-format kneeboard that provides
  a grid of empty elements that can be replaced with element templates (see the
  [elements guide](Elements.md)
  and `Elem_*.svg` templates). A sample definition file for a kneeboard using this template
  is available
  [here](sdefs/Definition_Grid_Card.xlsx).
- [`Elem_*.svg`](Elements.md) &ndash; a set of element templates that can replace elements in
  a kneeboard template using
  [replacement edits](../README.md#building-kneeboards).

By convention, the names of templates for a kneeboard start with `KBT_` while the
names of templates for an element that might appear on a kneeboard starts with `Elem_`.

KBB is not limited to supporting just these templates. The
[template builder's guide](Tmplt_Builder_Guide.md)
provides a detailed discussion of the structure of templates and can help describe how to build
your own templates for use by KBB.
