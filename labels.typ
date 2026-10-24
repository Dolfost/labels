// labels.typ — spice label sheet. Data: spices.toml. Build: ./build.sh
//
// Each [[spice]] entry produces up to three labels:
//   front   28 × 22 mm   name, subtitle, note, origin         (always)
//   back    28 × 30 mm   name + ratio table                   (only if `contents`)
//   bottom  ⌀ 25 mm      QR code only, sits in the recess            (only if `url`)
//
// Every sheet is duplex (flip on long edge): the reverse carries the same
// outlines mirrored, as a guide for the double-sided tape, and the spice name
// behind each QR circle.
// Everything about the LOOK lives in the STYLE block; WHAT is printed is spices.toml.

#import "@preview/tiaoma:0.3.0": qrcode

// ───────────────────────────── STYLE ─────────────────────────────
// Bottle: 30 mm face, 70 mm tall, 27 mm ⌀ × 3 mm deep recess underneath.
#let front-w = 28mm            // 1 mm clearance each side of the 30 mm face
#let front-h = 22mm            // ~⅓ of the bottle; contents stay visible
#let back-w = 28mm
#let back-h = 30mm
#let bottom-d = 25mm           // 1 mm slack inside the 27 mm recess
#let pad = 2mm                 // inner padding of rectangular labels
#let gutter = 0mm              // gap between labels; 0 = shared cut lines, least tape
#let page-margin = 10mm
#let cut-stroke = 0.2pt + luma(185)   // faint cut line — cut just INSIDE it

// Typography. "Roboto" on this machine resolves to the Roboto Condensed files;
// DejaVu Sans is the fallback (full Cyrillic / Latin coverage).
#let font-main = ("Roboto", "DejaVu Sans")
#let ink = luma(15)
#let muted = luma(105)
#let rule = 0.3pt + luma(170)
#let name-max = 14pt           // front title: start here …
#let name-one-line-min = 10pt  // … shrink to here on one line …
#let name-min = 8.5pt          // … then allow 2 lines down to here
#let back-name = (9pt, 7pt, 6pt)        // same three steps for the back label
#let bottom-name = (9pt, 7pt, 6pt)      // and for the name on the reverse of the circle
#let body-size = 6.5pt         // ratio table
#let small-size = 5.5pt        // subtitle, source, note
#let qr-size = 16mm            // inscribed square of a 25 mm circle is 17.7 mm; keep ≥ 1 mm white at the corners
#let bottom-name-w = 18mm      // text width on the reverse of the circle
#let head-h = 5mm              // band reserved for a section heading
#let section-gap = 3mm         // space above a heading when it is not at the page top
// ─────────────────────────────────────────────────────────────────

// ── data ──
#let spices = toml("spices.toml").at("spice", default: ())

// optional filter: --input only=paprika,cumin  (substring match on the name)
#let only = sys.inputs.at("only", default: "").split(",").map(s => s.trim()).filter(s => s != "")
#let wanted(sp) = only.len() == 0 or only.any(w => lower(sp.name).contains(lower(w)))

#let items = ()
#for sp in spices.filter(wanted) {
  for _ in range(sp.at("copies", default: 1)) { items.push(sp) }
}

// ── pieces ──

// Bold text that fits `width`: one line from `max` down to `one-min`,
// then up to two lines down to `min`.
#let fit-text(s, width, max, one-min, min) = context {
  let mk(sz) = text(size: sz, weight: "bold", s)
  let chosen = none
  let sz = max
  while chosen == none and sz >= one-min {
    if measure(mk(sz)).width <= width { chosen = sz }
    sz -= 0.5pt
  }
  sz = one-min + 1pt
  while chosen == none and sz >= min {
    let two-lines = measure(box(width: width, mk(sz) + linebreak() + mk(sz))).height
    let actual = measure(box(width: width, mk(sz))).height
    if actual <= two-lines + 0.01pt { chosen = sz }
    sz -= 0.5pt
  }
  if chosen == none { chosen = min }
  block(width: width, mk(chosen))
}

#let fmt-amount(v) = if type(v) == str { v } else { str(v) }

#let contents-table(c) = {
  set text(size: body-size)
  grid(
    columns: (1fr, auto),
    column-gutter: 1.5mm,
    row-gutter: 0.7mm,
    align: (left, right),
    ..c.pairs().map(((k, v)) => (text(k), text(fill: muted, fmt-amount(v)))).flatten(),
  )
}

// Rectangular card: `top` flows from the top, `bottom` is pinned to the bottom.
// Red frame if the content does not fit — shorten the text or enlarge the label.
#let card(w, h, top, bottom) = context {
  let inner-w = w - 2 * pad
  let inner-h = h - 2 * pad
  let used = measure(box(width: inner-w, top)).height + measure(box(width: inner-w, bottom)).height + 1mm
  let overflow = used > inner-h
  box(
    width: w, height: h, inset: pad, clip: true,
    stroke: if overflow { 0.6pt + red } else { cut-stroke },
  )[#top #v(1fr) #bottom]
}

#let front-card(sp) = {
  let inner-w = front-w - 2 * pad
  let top = {
    set align(center)
    fit-text(sp.name, inner-w, name-max, name-one-line-min, name-min)
    if "subtitle" in sp {
      v(1mm)
      text(size: small-size, fill: muted, style: "italic", sp.subtitle)
    }
  }
  let bottom = {
    set align(center)
    set text(size: small-size, fill: muted)
    if "note" in sp { block(sp.note) }
    if "source" in sp { v(0.6mm); block(text(style: "italic", sp.source)) }
  }
  card(front-w, front-h, top, bottom)
}

#let back-card(sp) = {
  let inner-w = back-w - 2 * pad
  let top = {
    set align(center)
    fit-text(sp.name, inner-w, ..back-name)
    v(1.5mm)
    line(length: 100%, stroke: rule)
    v(1.5mm)
    contents-table(sp.contents)
  }
  card(back-w, back-h, top, none)
}

#let qr-circle(sp) = box(width: bottom-d, height: bottom-d, {
  place(center + horizon, circle(radius: bottom-d / 2, stroke: cut-stroke))
  place(center + horizon, qrcode(sp.url, width: qr-size))
})

#let name-circle(sp) = box(width: bottom-d, height: bottom-d, {
  place(center + horizon, circle(radius: bottom-d / 2, stroke: cut-stroke))
  place(center + horizon, block(width: bottom-d, {
    set align(center)
    fit-text(sp.name, bottom-name-w, ..bottom-name)
  }))
})

// 50 mm calibration ruler so a wrong print scale is caught before cutting.
#let ruler = box(width: 50mm, height: 2.5mm, {
  place(bottom + left, rect(width: 50mm, height: 0.4pt, fill: ink))
  for i in range(6) {
    place(bottom + left, dx: i * 10mm - 0.2pt,
      rect(width: 0.4pt, height: if calc.rem(i, 5) == 0 { 2.5mm } else { 1.5mm }, fill: ink))
  }
})

// ── sheet ──
#set page(
  paper: "a4",
  margin: (x: page-margin, top: page-margin, bottom: page-margin + 4mm),
  footer: context {
    set text(size: 6pt, fill: muted)
    grid(
      columns: (auto, 1fr, auto),
      align: (left + bottom, center + bottom, right + bottom),
      [#ruler #h(2mm) 50 mm · if this is not 50 mm, print at 100 % ("actual size")],
      [front #front-w.mm() × #front-h.mm() · back #back-w.mm() × #back-h.mm() · bottom ⌀ #bottom-d.mm() mm · duplex, flip on long edge · #datetime.today().display()],
      counter(page).display("1 / 1", both: true),
    )
  },
)
#set text(font: font-main, fill: ink)
#set par(leading: 0.35em, spacing: 0pt, justify: false)
#set block(spacing: 0pt)   // all vertical spacing inside a label is explicit v(...)

#let usable-w = 210mm - 2 * page-margin
#let usable-h = 297mm - 2 * page-margin - 4mm

#let section-title(s) = text(size: 7pt, fill: muted, s)
#let outline(w, h) = box(width: w, height: h, stroke: cut-stroke)

// Each item: size, what to print on the front, what to print on the reverse.
#let groups = (
  ("FRONT · side of the bottle",
    items.map(sp => (w: front-w, h: front-h, front: front-card(sp), back: outline(front-w, front-h)))),
  ("BACK · opposite side, blends only",
    items.filter(sp => "contents" in sp).map(sp => (w: back-w, h: back-h, front: back-card(sp), back: outline(back-w, back-h)))),
  ("BOTTOM · QR codes, go in the recess under the bottle",
    items.filter(sp => "url" in sp).map(sp => (w: bottom-d, h: bottom-d, front: qr-circle(sp), back: name-circle(sp)))),
)

// Pack left-to-right, top-to-bottom, with `gutter` between items.
// Returns one array of placements per page.
#let pack(groups) = {
  let pages = ()
  let cur = ()
  let (x, y, row-h) = (0mm, 0mm, 0mm)
  for (title, its) in groups {
    if its.len() == 0 { continue }
    if x > 0mm { y += row-h; x = 0mm; row-h = 0mm }
    if y > 0mm { y += section-gap }
    if y + head-h + its.first().h > usable-h { pages.push(cur); cur = (); y = 0mm }
    cur.push((kind: "title", title: title, x: 0mm, y: y))
    y += head-h
    for it in its {
      if x + it.w > usable-w + 0.01mm { y += row-h; x = 0mm; row-h = 0mm }
      if y + it.h > usable-h + 0.01mm { pages.push(cur); cur = (); x = 0mm; y = 0mm; row-h = 0mm }
      cur.push((kind: "item", x: x, y: y, ..it))
      x += it.w + gutter
      row-h = calc.max(row-h, it.h + gutter)
    }
  }
  if cur.len() > 0 { pages.push(cur) }
  pages
}

// Front side as packed; reverse side mirrored left-to-right so that, printed
// duplex with a long-edge flip, every outline lands behind its own label.
#let sheet(placements, mirrored: false) = block(width: 100%, height: usable-h - 0.1mm, {
  for p in placements {
    if p.kind == "title" {
      if mirrored { place(top + right, dy: p.y, section-title(p.title + " · reverse: tape guide")) }
      else { place(top + left, dy: p.y, section-title(p.title)) }
    } else if mirrored {
      place(top + left, dx: usable-w - p.x - p.w, dy: p.y, p.back)
    } else {
      place(top + left, dx: p.x, dy: p.y, p.front)
    }
  }
})

#for (i, placements) in pack(groups).enumerate() {
  if i > 0 { pagebreak() }
  sheet(placements)
  pagebreak()
  sheet(placements, mirrored: true)
}
