-- main.lua
require 'grid'
require 'controls'

function love.load()
  -- GAME BOARD
  grid_cols = 300
  grid_rows = 300
  my_grid = new_grid(grid_cols, grid_rows)

  -- GRAPHICS SCALE & POSITIONING
  WIDTH, HEIGHT = love.graphics.getDimensions()
  scaleX = 8
  scaleY = 8
  cam_x = 0
  cam_y = 0
  zoom = 2.50
  displayX = (WIDTH  / 2) - (grid_cols * scaleX * zoom * 0.5)
  displayY = (HEIGHT / 2) - (grid_rows * scaleY * zoom * 0.5)

  -- GRAPHICS SETUP
  bg = new_bg_buffer(my_grid, scaleX, scaleY)
  cell_layer = new_cell_buffer(my_grid, scaleX, scaleY)
  love.graphics.setDefaultFilter("nearest", "nearest", 1)

  -- THREADS
  left_thread  = love.thread.newThread('thread.lua')
  right_thread = love.thread.newThread('thread.lua')
  cent_thread  = love.thread.newThread('thread.lua')
  left_thread:start('left')
  right_thread:start('right')
  cent_thread:start('center')

  -- CHANNELS
  left_channel = love.thread.getChannel('left')
  left_input = love.thread.getChannel('inputleft')

  right_channel = love.thread.getChannel('right')
  right_input = love.thread.getChannel('inputright')

  cent_channel = love.thread.getChannel('center')
  cent_input = love.thread.getChannel('inputcenter')

  push_edges()

  -- MISC
  POWERS = {2^8, 2^7, 2^6, 2^5, 2^4, 2^3, 2^2, 2^1, 2^0}
  is_modified = false
  tool = 1

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
    if is_modified then
      await_discard()
      push_input()
      is_modified = false
    end
  end

  if frame_count > limit then
    await_updates()
    push_edges()
    frame_count = 0
    --print_board(my_grid)
  end

end

function push_edges()
  local third = grid_cols / 3
  local left_center_edge = my_grid[third]
  local center_left_edge = my_grid[third + 1]
  local center_right_edge = my_grid[2 * third]
  local right_center_edge = my_grid[2 * third + 1]
  left_input:push(center_left_edge)
  right_input:push(center_right_edge)
  cent_input:push({left_center_edge, right_center_edge})
end


function push_input()
  local third = grid_cols / 3
  local lb, rb, cb = tri_split_board(my_grid, third)
  left_input:push(lb)
  right_input:push(rb)
  cent_input:push(cb)
end


function await_discard()
  local t1 = love.timer.getTime()
  local lc, rc, cc = left_channel, right_channel, cent_channel
  while (lc:getCount() < 1 or rc:getCount() < 1 or cc:getCount() < 1) do
    if love.timer.getTime() - t1 > 5 then error("timed out in await_discard") end
    --love.timer.sleep(1/ 1000)
  end
  left_channel:clear()
  right_channel:clear()
  cent_channel:clear()
end

function await_updates()
  local t1 = love.timer.getTime()
  local lc, rc, cc = left_channel, right_channel, cent_channel
  while (lc:getCount() < 1 or rc:getCount() < 1 or cc:getCount() < 1) do
    if love.timer.getTime() - t1 > 5 then error("timed out in await_updates") end
    --love.timer.sleep(1/ 1000)
  end
  pull_updates()
end


function pull_updates()
  local third = grid_cols / 3
  local lc, rc, cc = left_channel, right_channel, cent_channel
  local cond = lc:getCount() > 0 and rc:getCount() > 0 and cc:getCount() > 0
  if cond then
    local left_board  = lc:pop()
    local right_board = rc:pop()
    local cent_board  = cc:pop()
    for c = 1, third do
      for r = 1, grid_rows do
        my_grid[c][r] = left_board[c][r]
        my_grid[third + c][r] = cent_board[c][r]
        my_grid[2 * third + c][r] = right_board[c][r]
      end
    end
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

  love.graphics.print(tostring(love.timer.getFPS()))
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
  is_modified = true
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

function tool_place_cell(x, y)
  c, r = cell_at_pix(x, y)
  if not c then
    return nil
  end
  tool_flip_cell(c, r)
  is_modified = true
end

function tool_flip_cell(c, r)
  if my_grid[c][r] == tool then
    my_grid[c][r] = 0
  else
    my_grid[c][r] = tool
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
    tool_flip_cell(c, r)
    is_modified = true
  end
end

function resize(wheelmotion)
  zoom = math.max(zoom + (wheelmotion * 0.125), 0.25)
  local grid_pixel_size_x = grid_cols * scaleX * zoom
  local grid_pixel_size_y = grid_rows * scaleY * zoom

  displayX = (WIDTH  / 2) - (grid_pixel_size_x / 2)
  displayY = (HEIGHT / 2) - (grid_pixel_size_y / 2)
end
