--thread.lua (ground up)
print("thread loaded")
local ruleset = require 'sand'
require 'love.math'
require 'love.timer'
require 'grid'

local name = ...

local grid_cols = 100
local grid_rows = 200
local extra_col = name == 'left' and grid_cols + 1 or 0

local update_channel = love.thread.getChannel(name)
local input_channel = love.thread.getChannel('input' .. name)

global_grid  = new_grid(grid_cols, grid_rows)
global_grid2 = new_grid(grid_cols, grid_rows)
randomise_board(global_grid)

local POWERS = {2^0, 2^1, 2^2, 2^3, 2^4, 2^5, 2^6, 2^7, 2^8}


function tick3()
  local insert = table.insert
  local grid, grid2 = global_grid, global_grid2

  for c = 1, grid_cols do
    for r = 1, grid_rows do
      local rule_index = 0
      local pow_iter = 10

      for dy = -1, 1 do
        for dx = -1, 1 do
          pow_iter = pow_iter - 1

          local gy = r + dy
          local gx = c + dx
          rule_index = rule_index + (grid[gx][gy] * POWERS[pow_iter])

        end
      end

    local state = ruleset[rule_index]
    grid2[c][r] = state

    end
  end

  local old = global_grid -- backup present state into old
  global_grid = grid2     -- update present state from grid2
  global_grid2 = old      -- set grid2 to point to the backup
end

while true do
  local msg = input_channel:demand()
  if type(msg[1]) == 'number' then
    global_grid[extra_col] = msg
  else
    global_grid = msg
  end

  tick3()
  update_channel:push(global_grid)


  love.timer.sleep(1 / 60)
end
