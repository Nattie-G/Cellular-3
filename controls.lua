local tool_opts = {['0'] = 0, ['1'] = 1, ['2'] = 2, ['3'] = 3}
function love.keypressed(key)
  if key == 'r' then
    randomise_board(my_grid)
    generation = 0
    is_modified = true
  elseif key == 'p' then
    paused = not paused
  elseif key == '.' then
    pull_updates()
    push_edges()
  elseif tool_opts[key] then
    tool = tool_opts[key]
  end
end

function love.mousepressed(x, y, button, istouch, presses)
  if button == 1 then
    tool_place_cell(x, y)
  end
end

function love.wheelmoved(x, y)
  resize(y)
end

function love.mousemoved( x, y, dx, dy, istouch )
  local drag = love.mouse.isDown(2)
  local draw = love.mouse.isDown(1)
  if drag then
    cam_x = cam_x + dx
    cam_y = cam_y + dy
  elseif draw then
    draw_path(x, y, dx, dy)
  end
end
