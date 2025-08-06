# `KBT_Grid_Card`: General "Grid-Based" Card

The `KBT_Grid_Card.svg` template provides a "grid-based" layout format that can support general
collections of images, tables, and so on using elements defined in an element template such as
the `Elem_*.svg` templates that are part of the default set of templates. `KBT_Grid_Card.svg`
supports a wide range of kneeboards with potentially different looks. For example,

![](images/KBT_Grid_Card_Example.png)

The content of this kneeboard is assembled from one or more *elements* as described in the
elements
[documentation](./Elements.md)
and, as a result, the final kneeboard can take on any number of different looks.

## Overview

This template provides a generic "grid" that can be filled in with interchangable elements that
allow you to construct tables of different formats, include images, present airbase
information, and so on. The elements
[documentation](./Elements.md)
describes the elements available in the distribution in greater detail. You can also build your
own element templates as
[KBB Template Builder's Guide](Tmplt_Builder_Guide.md)
describes.

The grid that `KBT_Grid_Card.svg` provides is consistent with the setup that the grid elements
use (see the
[elements documentation](./Elements.md)).
That is, the "grid" on the `KBT_Grid_Card.svg` template has 50px vertical spacing and 720px
horizontal spacing. Horizontal placement depends on the element.

## Descriptions

This template uses
[replacement and substitution edits](../README.md#specifying-edits)
to specify the content for the kneeboard. An `.xlsx` description file that generates the
sample kneeboard shown above is located
[here](sdefs/sdef_kbt_grid_card_example.xlsx)
and a `.csv` version is available
[here](sdefs/sdef_kbt_grid_card_example.csv).
Either may be useful as a starting point for your own kneeboards.

> For correct operation, do **not** change field names in Column B.

### Basic Fields

The `KBT_Flight_Card.svg` template supports the
[common kneebarod fields](../README.md#common-fields)
including *KBB Template*, *KBB Output*, *KBB Tinted*, *Card Title*, and *Card Version*.

### Layout Grid

The `KBT_Grid_Card.svg` is set up to work with the standard grid elements
[documented here](./Elements.md).
To quote from that documentation,

> To allow flexibility and interchangability, an element is a multiple of 50px high and has a
> width of either *W* or *W*/2 where *W* is the width of the kneeboard template, 1440px.
> Elements also support substitution via `#tag;plist#` constructs (see the template builder
> [documentation](Tmplt_Builder_Guide.md)
> for additional details).

For `KBT_Grid_Card.svg`, the template has a coordinate system made up of 36 rows, each with two
columns. Elements span one or two columns across one or more rows. To use the grid template, you
perform a
[replacement edit](../README.md#specifying-edits)
to place elements within the template's coodinate system and then optionally perform
[substitution edits](../README.md#specifying-edits)
to fill in content.

The coordinate system uses a row/column notation to locate cells within the grid similar to
a spreadsheet. A cell can be described by a coordinate ( *row*, *column* ), where the top/left
cell on the template is at coordinate (0, 0) while the bottom/right cell on the template is at
coordinate (35, 1). A
[replacement edit](../README.md#specifying-edits)
places an element at a cell. The element may cover multiple rows and columns from that location
to down and to the left. The `id` in the replacement edit is a coordinate in the form
`R [r] C [c]` where `[r]` and `[c]` specify the row and column numbers as follows,

|Format|Description|
|:----:|-----------|
| V    | An integer "V" identifies a specific row or column by its index.
| "N"  | The text "N" advances the row or column from the position specified by the previous *V* format `id`.

For example, given a list of replacement `id`, 

|Index|`id`|Coordinate|Notes|
|:---:|:--:|:--------:|-----|
| 1   |`R 1 C 0`| ( 1, 0 ) | Absolute row (1), absolute column (0)
| 2   |`R N C N`| ( 2, 1 ) | Next row (2), next column (1) from previous edit (index 1)
| 3   |`R N C 1`| ( 3, 1 ) | Next row (3) from previous edit (index 2), absolute column (0)
| 4   |`R 5 C 1`| ( 5, 1 ) | Absolute row (5), absolute column (1)

For example, consider the following rows from a definition file that uses `KBT_Grid_Card.svg`
as a template,

|Row|A|B|C|Notes
|:-:|:-|:-|:-|:-|
|N  |<code>Edits</code>|<code> R 0 C 0 : Replace </code>|<code> Elem A : Elems.svg </code>|Replaces (0, 0)
|N+1|                  |<code>  : FA             </code>|<code> Value 1            </code>|
|N+2|                  |<code> R N C 1 : Replace </code>|<code> Elem B : Elems.svg </code>|
|N+3|                  |<code>  : FB             </code>|<code> Value 2            </code>|
|N+4|                  |<code> R 3 C 0 : Replace </code>|<code> Elem C : Elems.svg </code>|
|N+5|                  |<code>  : FC             </code>|<code> Value 2            </code>|

