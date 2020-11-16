local colour_map = {[0] = {0.3, 0.3, 0.3}, 
                    [1] = {0.8, 0.8, 0.8},
                    [2] = {0.9, 0.3, 0.3},
                    [3] = {0.3, 0.9, 0.3}}


function new_grid(columns, rows)
  -- create a new grid of size columns + 2 x rows + 2
  -- the extra two columns and rows are padding
  local grid = {}
  for c = 0, columns + 1 do
    grid[c] = {}
    for r = 0, rows + 1 do
      if r == rows + 1 then
        grid[c][r] = 0
      else
        grid[c][r] = 0
      end
    end
  end

  return grid
end


function new_cell_buffer(grid, sx, sy)
  local w = (#grid - 1)   * sx
  local h = (#grid[1] -1) * sy
  local blank = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(blank)
  love.graphics.clear(0, 0, 0, 0.0)
  love.graphics.setCanvas()
  return blank
end

function new_bg_buffer(grid, sx, sy)
  local w = (#grid - 1)  * sx
  local h = (#grid[1] - 1)     * sy
  local img = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(img)
  love.graphics.setColor(colour_map[0])
  love.graphics.rectangle("fill", 1, 1, w, h)
  love.graphics.setColor(0, 0, 0, 1)

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
  for i = 0, #colour_map do
    love.graphics.setColor(colour_map[i])
    for c = 1, #grid - 1 do
      for r = 1, #grid[1] - 1 do
        if grid[c][r] == i then
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
  for c = 1, #board - 1 do
    for r = 1, #board[1] - 1 do
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
  for c = 1, #board - 1 do
    for r = 1, #board[1] - 1 do
      local rand = love.math.random(0, 4)
      if rand == 0 then
        board[c][r] = 1
      else
        board[c][r] = 0
      end
    end
  end
end


function split_board(board, column)
  -- helper funtion for sync_threads_clear_buffers()
  -- provides overlap of 1
  local left_board, right_board = {}, {}

  for i = 0, column + 1 do
    left_board[i] = board[i]
    right_board[i] = board[column + i]
  end
  return left_board, right_board
end

function tri_split_board(board, third)
  -- helper funtion for sync_threads_clear_buffers()
  -- provides overlap of 1
  local left_board, right_board, cent_board = {}, {}, {}

  for i = 0, third + 1 do
    left_board[i] = board[i]
    cent_board[i] = board[third + i]
    right_board[i] = board[(2 * third) + i]
  end
  return left_board, right_board, cent_board
end
