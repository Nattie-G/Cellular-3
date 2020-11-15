--thread.lua (ground up)
print("thread loaded")
local ruleset = require 'sand'
require 'love.math'
require 'love.timer'
require 'grid'

local name = ...

local grid_cols = 100
local grid_rows = 300
local extra_col = name == 'right' and 0 or grid_cols + 1

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
          if grid[gx] == nil then 
            print("grid[gx] is nil", gx)
            print("name", name)
          elseif grid[gx][gy] == nil then 
            print("name", name)
            print("grid[gx][gy] is nil", gx, gy)
          end
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

if name == 'center' then

  while true do
    local msg = input_channel:demand()
    if #msg == 2 then
      global_grid[grid_cols + 1] = msg[2]
      global_grid[0] = msg[1]
    else
      global_grid = msg
    end

    if update_channel:getCount() == 0 then
      tick3()
      update_channel:push(global_grid)
    end

    love.timer.sleep(1 / 1000)
  end

else

  while true do
    local msg = input_channel:demand()
    if type(msg[1]) == 'number' then
      global_grid[extra_col] = msg
    else
      global_grid = msg
    end

    if update_channel:getCount() == 0 then
      tick3()
      update_channel:push(global_grid)
    end

    love.timer.sleep(1 / 1000)
  end

end
