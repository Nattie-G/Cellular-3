-- main.lua
-- NO BUFFERS
require 'grid'
require 'controls'

function love.load()
  -- GAME BOARD
  grid_cols = 250
  grid_rows = 250
  my_grid = new_grid(grid_cols, grid_rows)

  -- GRAPHICS SCALE & POSITIONING
  WIDTH, HEIGHT = love.graphics.getDimensions()
  scaleX = 8
  scaleY = 8
  cam_x = 0
  cam_y = 0
  zoom = 0.50
  displayX = (WIDTH  / 2) - (#my_grid * scaleX * zoom * 0.5)
  displayY = (HEIGHT / 2) - (#my_grid[1] * scaleY * zoom * 0.5)

  -- GRAPHICS SETUP
  bg = new_bg_buffer(my_grid, scaleX, scaleY)
  cell_layer = new_cell_buffer(my_grid, scaleX, scaleY)
  love.graphics.setDefaultFilter("nearest", "nearest", 1)

  -- THREADS
  worker_thread = love.thread.newThread('thread.lua')
  worker_thread:start('worker')

  -- CHANNELS
  worker_channel = love.thread.getChannel('worker')
  worker_input = love.thread.getChannel('inputworker')

  -- MISC
  POWERS = {2^8, 2^7, 2^6, 2^5, 2^4, 2^3, 2^2, 2^1, 2^0}
  is_modified = false

  --TIME
  paused = true
  frame_count = 0
  limit = 0.00

end

function love.update(dt)
  if paused then
    frame_count = frame_count
  else
    frame_count = frame_count + dt
  end


  if frame_count > limit then
    if is_modified then
      sync_threads_clear_buffers()
      is_modified = false
      await_updates()
    else
      pull_updates()
    end
    frame_count = 0
  end

end

function sync_threads_clear_buffers()
  worker_input:push(my_grid)
  await_discard()
end


function await_discard()
  local t1 = love.timer.getTime()
  while worker_channel:getCount() == 0 do
    love.timer.sleep(1/ 1000)
    if love.timer.getTime() - t1 > 5 then error("timed out in await_discard") end
  end
  worker_channel:pop()
end

function await_updates()
  local t1 = love.timer.getTime()
  while (worker_channel:getCount() == 0) do
    if love.timer.getTime() - t1 > 5 then error("timed out in await_updates") end
    --love.timer.sleep(1/ 1000)
  end
  pull_updates()
end


function pull_updates()
  local new_board = worker_channel:pop()
  if new_board then
    my_grid = new_board
  end
end


function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
  draw_cells(my_grid, cell_layer, scaleX, scaleY)
  love.graphics.translate(cam_x, cam_y)

  love.graphics.draw(bg, displayX, displayY, 0, zoom)
  love.graphics.draw(cell_layer, displayX, displayY, 0, zoom)

  love.graphics.line(WIDTH / 2, 0, WIDTH / 2, HEIGHT)
  love.graphics.line(0, HEIGHT / 2, WIDTH, HEIGHT / 2)
end


local function flip_cell(c, r)
  if my_grid[c][r] == 0 then
    my_grid[c][r] = 1
  else
    my_grid[c][r] = 0
  end
end

function place_cell(x, y)
  c, r = cell_at_pix(x, y)
  if not c then
    return nil
  end
  print("click: ", c, r)
  flip_cell(c, r)
end

function cell_at_pix(x, y)
  local ox = (displayX - x) + cam_x
  local oy = (displayY - y) + cam_y
  local dx = scaleX * zoom
  local dy = scaleY * zoom

  local gx = -math.floor(ox / dx)
  local gy = -math.floor(oy / dy)
  local x_bounds = (gx > 0) and (gx <= grid_cols)
  local y_bounds = (gy > 0) and (gy <= grid_rows)

  if x_bounds and y_bounds then
    return gx, gy
  else
    return nil
  end
end


function draw_path(x, y, dx, dy)
  local gox, goy = cell_at_pix(x, y) -- Grid Original X/Y
  local gnx, gny = cell_at_pix(x + dx, y + dy) -- Grid New X/Y
  if (gox == gnx) and (goy == gny) or not (gox and gnx) then
  -- draw nothing if the mouse doesn't cross at least one square
  -- or cell_at_pix returns nil for either point
    return
  end

  local gdx, gdy = gnx - gox, gny - goy -- Grid Distance X / Y
  local stepX = gdx < 0 and -1    or gdx > 0 and 1    or 0
  local stepY = gdy < 0 and -1    or gdy > 0 and 1    or 0

  local c, r = gox, goy
  for i = 1, math.abs(gdx) + math.abs(gdy) do
    if math.abs(gdx) > math.abs(gdy) then
      c = c + stepX
      gdx = gdx - stepX
    else
      r = r + stepY
      gdy = gdy - stepY
    end
    flip_cell(c, r)
    is_modified = true
  end
end

function resize(wheelmotion)
  zoom = math.max(zoom + (wheelmotion * 0.125), 0.25)
  local grid_pixel_size_x = #my_grid * scaleX * zoom
  local grid_pixel_size_y = #my_grid[1] * scaleY * zoom

  displayX = (WIDTH  / 2) - (grid_pixel_size_x / 2)
  displayY = (HEIGHT / 2) - (grid_pixel_size_y / 2)
end
