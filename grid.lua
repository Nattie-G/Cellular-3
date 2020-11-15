local colour_map = {[0] = {0.3, 0.3, 0.3}, 
                    [1] = {0.8, 0.8, 0.8},
                    [2] = {0.0, 0.0, 0.0}}


function new_grid(columns, rows)
  local grid = {}
  for c = 1, columns do
    grid[c] = {}
    for r = 1, rows do
      grid[c][r] = 0
    end
  end

  return grid
end


function new_cell_buffer(grid, sx, sy)
  local w = #grid * sx
  local h = #grid[1] * sy
  local blank = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(blank)
  love.graphics.clear(0, 0, 0, 0.0)
  love.graphics.setCanvas()
  return blank
end

function new_bg_buffer(grid, sx, sy)
  local w = #grid  * sx
  local h = #grid[1]     * sy
  local img = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(img)
  love.graphics.setColor(colour_map[0])
  love.graphics.rectangle("fill", 1, 1, w, h)
  love.graphics.setColor(colour_map[2])

  if sx > 2 then
    for px = sx, w, sx do
      love.graphics.line(px, 0, px, h)
    end
  end

  if sy > 2 then
    for py = sy, h, sy do
      love.graphics.line(0, py, w, py)
    end
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
  return img
end

function draw_cells(grid, gridBuffer, sx, sy)
  local rect = love.graphics.newMesh{{0,0}, {1,0}, {1,1}, {0,1}, {0,0}}
  rect:setAttributeEnabled("VertexColor", false)
  local lgdraw = love.graphics.draw
  love.graphics.setCanvas(gridBuffer)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.setColor(colour_map[1])
  for c, col in ipairs(grid) do
    for r, val in ipairs(col) do
      if val == 1 then
          local px = (c - 1) * sx
          local py = (r - 1) * sy
        if (sx > 3) and (sy > 3) then
          lgdraw(rect, 1 + px, 1 + py, 0, sx - 2, sy - 2)
        elseif (sx > 2) and (sy > 2) then
          lgdraw(rect, 0 + px, 0 + py, 0, sx - 1, sy - 1)
        else
          lgdraw(rect, px, py, 0, sx, sy)
        end
      end
    end
  end
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1)
end

function print_board(board)
  print ("----------------------")
  print ("----------------------")
  lines = {}
  for i=1, #board[1] do
    lines[i] = '  '
  end
  for c, col in ipairs(board) do
    for r, val in ipairs(board[1]) do
      local v = board[c][r]
      if v == nil then v = '*' end
      if v == 0 then v = '.' end
      lines[r] = lines[r] .. v .. " "
    end
  end
  for k, v in ipairs(lines) do
    print(v)
  end
end

function randomise_board(board)
  for c = 1, #board do
    for r = 1, #board[1] do
      board[c][r] = love.math.random(0, 1)
    end
  end
end


function split_board(board, column)
  -- helper funtion for sync_threads_clear_buffers()
  local half = column
  local left_board, right_board = {}, {}

  for i = 1, half do
    left_board[i] = board[i]
    right_board[i] = board[half + i]
  end
  return left_board, right_board
end
