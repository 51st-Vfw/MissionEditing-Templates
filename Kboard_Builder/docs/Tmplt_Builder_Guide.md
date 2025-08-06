# KBB Template Builder's Guide

TODO

## Building Templates

While the templates in the distribution cover a wide range of potential kneeboards, you may
want to build your own templates customized to your needs. Doing so is straight-forward and
largely a matter of creating an `.svg` file with some specific characteristics and then
building a corresponding sample description file to make it easy for others to use the
template.

There are two constructs within an `.svg` template that KBB relies on to support edits to the
template,

* A `tag`, consisting of a `key` and `arg`, appearing in the text associated with an element
  in an `.svg` file. These are rendered and visible when viewing the template.
* The element `id` (an XML property) attached to each element in an `.svg` file. As these
  identifiers are internal to the `.svg`, they are not rendered and invisible when viewing
  the template.

KBB primarily uses `tag` constructs to support
[substitution edits](#specifying-edits)
and `id` constructs to support
[replacement edits](#specifying-edits).

Both `id` and `tag` are case-insensitive and should contain only alphanumeric characters and
underscores (that is, "a"-"z", "A"-"Z", "0"-"9", or "_"). By convention, an `id` or `tag`
appearing in a description file may include spaces; these are automatically converted to
underscores by KBB behind the scenes. For example, the tag "KBB_Template" in an `.svg`
template can be written as "KBB Template" in the description.

### Using `tag` Constructs

A `tag` provides the base support for making changes to the content of a template. These always
appear when viewing an `.svg` and is the text content of a text block in the `.svg` file.
When appearing in an `.svg`, the `tag` is always part of a longer string of the form
`#tag;plist#` where the `;plist` portion is optional. When handling a
[substitution edit](#specifying-edits),
the entire `#tag;plist#` string is replaced.

The optional `;plist` portion is made up of a comma-separated list of `term` items (for
example, "a,b" is a `plist` with two `term` items: "a" and "b"). The first character of a
`term` defines its function which generally relates to text layout as discussed below.

|Function|Format|Summary|
|:-:|:-:|---|
| C | C*X* | Center-justify the edited field with the center anchor at an *x* coordinate of *X* where *X* is given by the *x* coordinate of the left edge of the field plus one-half the width of the field.
| R | R*X* | Right-justify the edited field with the right anchor at an *x* coordiante of *X* where *X* is given by the *x* coordinate of the right edge of the field.
| L | L*N* | Line *N* of the subsituted text should be placed in this field.

The `;plist` portion is not necessary for single-line, left-justified fields. It is, however,
required for right-justified, center-justified fields, or multi-line fields due to the manner
in which text layout may be encoded in `.svg` files. The `;plist` portion is necessary to help
KBB lay out the replacement text for a field. 

> Specifically, text may be laid out in spans that already account for justification and line
> breaks directly. In these case, there is not enough information in the base `.svg` for KBB
> to correctly build the layout for the new text.

The following portion of the Flight Card kneeboard template shows a single-line, left-justified
field,

![TODO](docs/images/Tag_Basic_Example.png)

Here, the `tag` is "FUEL_JOKER" and there is no `plist`. When doing a substitution, KBB
replaces "#FUEL_JOKER#" with the value of the FUEL_JOKER field from the description. If the
definition specified that "FUEL_JOKER" should be "3000", KBB would generate a kneeboard that
looks like this,

![TODO](docs/images/Tag_Basic_Example_Fill.png)

The following portion of the Flight Card kneeboard template shows a center-justified
field that requires a `;plist`,

![TODO](docs/images/Tag_Param_C_Example.png)

Here, the `tag` is "AAR_2_FLIGHT" while `plist` is "c285" (like the `tag`, `plist` is also
case-insensitive) and includes a single `term`, "c285". This example positions the substitution
for the AAR_2_FLIGHT field such that the center of the substituted text is anchored at an *x*
location of 285 units.

Finally, the following portion of the Flight Card kneeboard template shows a multi-line field
that requires a `;plist`,

![TODO](docs/images/Tag_Param_L_Example.png)

For multi-line fields, the template has tags for each line of the content as shown above. The
`plist` for each line contains a `term` that specifies which line in the field should be used
to source the content for the line. 

![TODO](docs/images/Tag_Param_L_Example_Defn.png)

TODO

![TODO](docs/images/Tag_Param_L_Example_Fill.png)

TODO

### Using `id` Constructs

TODO

### Layout Considerations

TODO

### Creating Sample Definitions

TODO

