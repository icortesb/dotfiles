// Wallpaper picker — AGS/Astal (GTK3).  ags run -d <dir> [-- favs]
import app from "ags/gtk3/app"
import { Astal, Gtk, Gdk } from "ags/gtk3"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import Gio from "gi://Gio"
import GdkPixbuf from "gi://GdkPixbuf"

const HOME    = GLib.get_home_dir()
const POOLS   = [`${HOME}/Pictures/wallpapers/images`, `${HOME}/Pictures/wallpapers`]
const THUMBS  = `${HOME}/.cache/wallpaper-thumbs`
const HIST    = `${HOME}/.cache/wallpaper-history`
const FAVFILE = `${HOME}/.config/hyprpanel/wallpaper-favs`
const CW = 340, CH = 191
const dec = new TextDecoder()

function readLines(f: string): string[] {
  try {
    const [ok, bytes] = GLib.file_get_contents(f)
    return ok ? dec.decode(bytes).split("\n").filter(Boolean) : []
  } catch { return [] }
}
function writeLines(f: string, arr: string[]) {
  try { GLib.file_set_contents(f, arr.join("\n") + "\n") } catch {}
}
function listImages(d: string): string[] {
  const out: string[] = []
  let en
  try {
    en = Gio.File.new_for_path(d).enumerate_children(
      "standard::name,standard::type", Gio.FileQueryInfoFlags.NONE, null)
  } catch { return out }
  let info
  while ((info = en.next_file(null)) !== null) {
    const n = info.get_name()
    if (info.get_file_type() === Gio.FileType.REGULAR && /\.(jpe?g|png|webp)$/i.test(n))
      out.push(`${d}/${n}`)
  }
  en.close(null)
  return out.sort()
}
function pool(): string[] {
  for (const d of POOLS) { const a = listImages(d); if (a.length) return a }
  return []
}

const sha     = (s: string) => GLib.compute_checksum_for_string(GLib.ChecksumType.SHA1, s, -1)!.slice(0, 16)
const thumbOf = (p: string) => `${THUMBS}/${sha(p)}.png`
const blurOf  = (p: string) => `${THUMBS}/${sha(p)}_b.png`
const base    = (p: string) => GLib.path_get_basename(p)

const favSet = new Set(readLines(FAVFILE))
const isFav = (p: string) => favSet.has(base(p))
function toggleFav(p: string) {
  favSet.has(base(p)) ? favSet.delete(base(p)) : favSet.add(base(p))
  writeLines(FAVFILE, [...favSet])
}
function applyWallpaper(p: string) {
  execAsync(["hyprpanel", "setWallpaper", p]).catch(() => {})
  const h = readLines(HIST)
  if (h[h.length - 1] !== p) writeLines(HIST, [...h, p])
}
function ensureBlur(p: string) {
  if (GLib.file_test(blurOf(p), GLib.FileTest.EXISTS)) return
  const src = GLib.file_test(thumbOf(p), GLib.FileTest.EXISTS) ? thumbOf(p) : p
  execAsync(["magick", src, "-thumbnail", `${CW}x${CH}^`, "-gravity", "center",
    "-extent", `${CW}x${CH}`, "-blur", "0x12", blurOf(p)]).catch(() => {})
}

const CSS = `
.wp-win, .wp-root { background-color: #2e3440; color: #d8dee9;
  font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace; }
.wp-root { padding: 18px; }
.wp-tabs { margin-bottom: 14px; }
.wp-tab { background-color: #3b4252; color: #d8dee9; padding: 8px 20px;
  border-radius: 999px; margin: 0 5px; border: 2px solid transparent; }
.wp-tab:hover { border-color: #4c566a; }
.wp-tab.active { background-color: #88c0d0; color: #2e3440; }
.wp-empty { color: #7b88a1; padding: 60px; }
scrolledwindow.wp-scroll, flowbox.wp-grid, flowboxchild { background-color: transparent; }
flowboxchild { padding: 7px; }
.wp-card { border-radius: 15px; border: 3px solid transparent; background-color: #3b4252; }
.wp-card.fav { border-color: #bf616a; }
.wp-blur, .wp-scrim, .wp-pills { opacity: 0; transition: opacity 140ms ease; }
.wp-scrim { background-color: rgba(30,34,42,0.28); }
.wp-card.hover .wp-blur,
.wp-card.hover .wp-scrim,
.wp-card.hover .wp-pills { opacity: 1; }
.pill { background-color: rgba(46,52,64,0.94); color: #eceff4; font-size: 16px;
  border-radius: 999px; padding: 10px 20px; margin: 0 7px;
  border: 2px solid rgba(216,222,233,0.20); }
.pill:hover { background-color: #88c0d0; color: #2e3440; border-color: #88c0d0; }
.pill.heart.on { background-color: #bf616a; color: #eceff4; border-color: #bf616a; }
`

function pic(file: string, cls: string): Gtk.Image {
  const im = new Gtk.Image()
  im.get_style_context().add_class(cls)
  try { im.set_from_pixbuf(GdkPixbuf.Pixbuf.new_from_file_at_scale(file, CW, CH, false)) }
  catch {}
  im.set_size_request(CW, CH)
  return im
}

function Card(path: string): Gtk.Widget {
  ensureBlur(path)

  const sharp = pic(thumbOf(path), "wp-img")
  const blur  = pic(blurOf(path),  "wp-blur")
  const scrim = new Gtk.Box();  scrim.get_style_context().add_class("wp-scrim")

  const heart = new Gtk.Button({ label: isFav(path) ? "♥" : "♡" })
  heart.get_style_context().add_class("pill"); heart.get_style_context().add_class("heart")
  if (isFav(path)) heart.get_style_context().add_class("on")

  const setb = new Gtk.Button({ label: "Set" })
  setb.get_style_context().add_class("pill")
  setb.connect("clicked", () => { applyWallpaper(path); app.quit() })

  const pills = new Gtk.Box({ halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER })
  pills.get_style_context().add_class("wp-pills")
  pills.add(heart); pills.add(setb)

  const overlay = new Gtk.Overlay()
  overlay.add(sharp)
  overlay.add_overlay(blur)
  overlay.add_overlay(scrim)
  overlay.add_overlay(pills)

  const card = new Gtk.EventBox({ visible_window: true })
  card.get_style_context().add_class("wp-card")
  if (isFav(path)) card.get_style_context().add_class("fav")
  card.add(overlay)

  heart.connect("clicked", () => {
    toggleFav(path)
    const on = isFav(path)
    heart.label = on ? "♥" : "♡"
    const c = card.get_style_context(), h = heart.get_style_context()
    on ? h.add_class("on")  : h.remove_class("on")
    on ? c.add_class("fav") : c.remove_class("fav")
  })

  const cx = card.get_style_context()
  card.connect("enter-notify-event", () => { cx.add_class("hover"); return false })
  card.connect("leave-notify-event", (_w: any, ev: any) => {
    try { if (ev.detail === Gdk.NotifyType.INFERIOR) return false } catch {}
    cx.remove_class("hover"); return false
  })

  card.show_all()
  return card
}

function Grid(items: string[]): Gtk.Widget {
  const fb = new Gtk.FlowBox({
    selection_mode: Gtk.SelectionMode.NONE,
    max_children_per_line: 4, min_children_per_line: 2,
    homogeneous: true, row_spacing: 6, column_spacing: 6, valign: Gtk.Align.START,
  })
  fb.get_style_context().add_class("wp-grid")
  if (!items.length) {
    const l = new Gtk.Label({ label: "no favourites yet — hover a wallpaper and tap ♡" })
    l.get_style_context().add_class("wp-empty")
    fb.add(l); fb.show_all()
    return fb
  }
  let i = 0
  const batch = () => {
    const end = Math.min(i + 20, items.length)
    for (; i < end; i++) fb.add(Card(items[i]))
    fb.show_all()
    if (i < items.length) return GLib.SOURCE_CONTINUE
    return GLib.SOURCE_REMOVE
  }
  batch()
  if (i < items.length) GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, batch)
  return fb
}

function Main() {
  const all = pool()
  const scroller = () => {
    const s = new Gtk.ScrolledWindow({ hscrollbar_policy: Gtk.PolicyType.NEVER })
    s.get_style_context().add_class("wp-scroll")
    s.set_min_content_width(1180); s.set_min_content_height(690)
    s.set_propagate_natural_width(true)
    return s
  }
  const stack = new Gtk.Stack({
    transition_type: Gtk.StackTransitionType.CROSSFADE, transition_duration: 130,
  })
  const sAll = scroller(); sAll.add(Grid(all)); stack.add_named(sAll, "all")
  const sFav = scroller(); sFav.add(Grid(all.filter(isFav))); stack.add_named(sFav, "favs")

  const tabAll = new Gtk.Button({ label: "All" })
  const tabFav = new Gtk.Button({ label: "★ Favourites" })
  ;[tabAll, tabFav].forEach((t) => t.get_style_context().add_class("wp-tab"))
  tabAll.get_style_context().add_class("active")
  const setTab = (name: string) => {
    if (name === "favs") {
      const old = sFav.get_child(); if (old) sFav.remove(old)
      sFav.add(Grid(all.filter(isFav))); sFav.show_all()
    }
    stack.set_visible_child_name(name)
    tabAll.get_style_context().remove_class("active")
    tabFav.get_style_context().remove_class("active")
    ;(name === "all" ? tabAll : tabFav).get_style_context().add_class("active")
  }
  tabAll.connect("clicked", () => setTab("all"))
  tabFav.connect("clicked", () => setTab("favs"))

  const tabs = new Gtk.Box({ halign: Gtk.Align.CENTER })
  tabs.get_style_context().add_class("wp-tabs")
  tabs.add(tabAll); tabs.add(tabFav)

  const root = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL })
  root.get_style_context().add_class("wp-root")
  root.add(tabs); root.add(stack)
  root.show_all()

  try {
    const a = (globalThis as any).imports?.system?.programArgs || []
    if (a.includes("favs")) setTab("favs")
  } catch {}

  return (
    <window
      name="wallpaper-picker"
      namespace="wallpaper-picker"
      class="wp-win"
      keymode={Astal.Keymode.EXCLUSIVE}
      application={app}
      onKeyPressEvent={(_w: any, ev: any) => {
        if (ev.get_keyval()[1] === Gdk.KEY_Escape) app.quit()
      }}
    >
      {root}
    </window>
  )
}

app.start({ instanceName: "wallpaper-picker", css: CSS, main: Main })
