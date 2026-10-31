-- Use Omarchy's 1.6x preset for displays not covered by a specific layout.
-- 1.6 is a clean fractional scale for 4K panels (1.4 snaps to 1.333, which
-- makes the shell bar and GTK apps too small). GDK_SCALE keeps GTK apps crisp
-- at the same apparent size.
hl.env("GDK_SCALE", "2")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
