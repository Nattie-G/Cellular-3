ruleset = {}
for a = 0, 3 do
  for b = 0, 3 do
    for c = 0, 3 do
      for d = 0, 3 do
        for e = 0, 3 do
          for f = 0, 3 do
            for g = 0, 3 do
              for h = 0, 3 do
                for i = 0, 3 do
                  local bsum = 0
                  bsum = bsum + 4^8 * a 
                  bsum = bsum + 4^7 * b 
                  bsum = bsum + 4^6 * c 
                  bsum = bsum + 4^5 * d 
                  bsum = bsum + 4^4 * e
                  bsum = bsum + 4^3 * f
                  bsum = bsum + 4^2 * g
                  bsum = bsum + 4^1 * h
                  bsum = bsum + 4^0 * i
                  local neighbourhood = {
                      a, b, c,
                      d, e, f,
                      g, h, i
                  }
                  local neighbours = a + b + c + d + 0 + f + g + h + i
                  -- 4 state sand thing
                  -- 0 -> empty
                  -- 1 -> falling sand
                  -- 2 -> push-left sand
                  -- 3 -> push-right sand

                  if e == 0 then
                    if (b > 0) then
                      ruleset[bsum] = b
                    elseif (d == 3) and (a > 0) then
                      ruleset[bsum] = a
                    elseif (f == 2) and (c > 0) then
                      ruleset[bsum] = c
                    else
                      ruleset[bsum] = 0
                    end
                  elseif (e == 1) then
                    if h == 0 then
                      ruleset[bsum] = 0
                    elseif (h == 2) and (g == 0) and (a == 0) then
                      ruleset[bsum] = 0
                    elseif (h == 3) and (i == 0) and (c == 0) then
                      ruleset[bsum] = 0
                    elseif (h > 0) and (g > 0) then
                      ruleset[bsum] = 2
                    elseif (h > 0) and (i > 0) then
                      ruleset[bsum] = 3
                    else
                      ruleset[bsum] = 1
                    end
                  elseif (e > 1) then
                    if h == 0 then
                      ruleset[bsum] = 0
                    elseif (h == 2) and (g == 0) and (a == 0) then
                      ruleset[bsum] = 0
                    elseif (h == 3) and (i == 0) and (c == 0) then
                      ruleset[bsum] = 0
                    elseif (b > 0) then
                      local left_col  = 0
                      local right_col = 0
                      if (a > 0) then left_col = left_col + 1 end
                      if (d > 0) then left_col = left_col + 1 end
                      if (g > 0) then left_col = left_col + 1 end
                      if (c > 0) then right_col = right_col + 1 end
                      if (f > 0) then right_col = right_col + 1 end
                      if (i > 0) then right_col = right_col + 1 end

                      if (e == 2) and right_col < 2 then
                        ruleset[bsum] = 3
                      elseif (e == 3) and left_col < 2 then
                        ruleset[bsum] = 2
                      else
                        ruleset[bsum] = e
                      end
                    else
                      ruleset[bsum] = e
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

print("return {")
print("[0] = " .. ruleset[0] .. ",")
for k, v in ipairs(ruleset) do
  print("[" .. k .. "] = " .. v .. ",")
end
print("}")
