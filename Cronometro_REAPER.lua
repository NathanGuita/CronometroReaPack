{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 local section = "CronometroSettings"\
local key = "Window"\
\
local elapsed = 0\
local running = false\
local last_time = reaper.time_precise()\
local mouse_down = false\
\
-- Carrega posi\'e7\'e3o anterior da janela\
local function restore_window_position()\
  local str = reaper.GetExtState(section, key)\
  if str ~= "" then\
    local x, y, w, h = str:match("(%d+),(%d+),(%d+),(%d+)")\
    if x and y and w and h then\
      gfx.init("Cron\'f4metro", tonumber(w), tonumber(h), 0, tonumber(x), tonumber(y))\
      return\
    end\
  end\
  gfx.init("Cron\'f4metro", 400, 180, 0)\
end\
\
-- Salva posi\'e7\'e3o atual da janela\
local function save_window_position()\
  if gfx.getchar() < 0 then\
    reaper.SetExtState(section, key, string.format("%d,%d,%d,%d", gfx.x, gfx.y, gfx.w, gfx.h), true)\
  end\
end\
\
restore_window_position()\
\
function format_time(seconds)\
  local h = math.floor(seconds / 3600)\
  local m = math.floor((seconds % 3600) / 60)\
  local s = math.floor(seconds % 60)\
  local ms = math.floor((seconds - math.floor(seconds)) * 1000)\
  return string.format("%02d:%02d:%02d.%03d", h, m, s, ms)\
end\
\
function is_mouse_in_rect(x, y, w, h)\
  local mx, my = gfx.mouse_x, gfx.mouse_y\
  return mx >= x and mx <= x + w and my >= y and my <= y + h\
end\
\
function draw_button_label(label, x, y, w, h)\
  gfx.set(0.3, 0.3, 0.3, 0.2)\
  gfx.rect(x, y, w, h, 1)\
\
  if is_mouse_in_rect(x, y, w, h) then\
    gfx.set(0.3, 0.8, 0.3, 0.2)\
    gfx.rect(x, y, w, h, 1)\
  end\
\
  local tw, th = gfx.measurestr(label)\
  gfx.x = x + (w - tw) / 2\
  gfx.y = y + (h - th) / 2\
  gfx.set(1, 1, 1)\
  gfx.drawstr(label)\
end\
\
function main()\
  if gfx.getchar() < 0 then\
    save_window_position()\
    return\
  end\
\
  local now = reaper.time_precise()\
  local delta = now - last_time\
  last_time = now\
\
  if running then\
    elapsed = elapsed + delta\
  end\
\
  gfx.set(0, 0, 0)\
  gfx.rect(0, 0, gfx.w, gfx.h, 1)\
\
  local font_size_time = math.floor(math.min(gfx.h * 0.3, gfx.w * 0.2))\
  font_size_time = math.max(font_size_time, 48)\
\
  local font_size_btn = math.floor(gfx.h * 0.12)\
  local btn_h = font_size_btn * 1.6\
  local btn_w = btn_h * 2.5\
  local spacing = btn_h * 0.5\
\
  local time_str = format_time(elapsed)\
  gfx.set(1, 1, 1)\
  gfx.setfont(1, "Arial", font_size_time)\
\
  local tw = gfx.measurestr(time_str)\
  local tx = (gfx.w - tw) / 2\
  local ty = gfx.h * 0.05\
\
  for dx = 0, 1 do\
    for dy = 0, 1 do\
      gfx.x = tx + dx\
      gfx.y = ty + dy\
      gfx.drawstr(time_str)\
    end\
  end\
\
  gfx.setfont(1, "Arial", font_size_btn)\
  local total_w = btn_w * 2 + spacing\
  local start_x = (gfx.w - total_w) / 2\
  local y_btn = gfx.h * 0.65\
\
  draw_button_label(running and "Pause" or "Play", start_x, y_btn, btn_w, btn_h)\
  draw_button_label("Reset", start_x + btn_w + spacing, y_btn, btn_w, btn_h)\
\
  if gfx.mouse_cap & 1 == 1 then\
    if not mouse_down then\
      mouse_down = true\
      if is_mouse_in_rect(start_x, y_btn, btn_w, btn_h) then\
        running = not running\
      elseif is_mouse_in_rect(start_x + btn_w + spacing, y_btn, btn_w, btn_h) then\
        elapsed = 0\
        running = false\
      end\
    end\
  else\
    mouse_down = false\
  end\
\
  reaper.defer(main)\
end\
\
main()}