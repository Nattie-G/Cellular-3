ruleset = {}
for a = 0, 1 do
  for b = 0, 1 do
    for c = 0, 1 do
      for d = 0, 1 do
        for e = 0, 1 do
          for f = 0, 1 do
            for g = 0, 1 do
              for h = 0, 1 do
                for i = 0, 1 do
                  local bsum = 0
                  bsum = bsum + 2^8 * a 
                  bsum = bsum + 2^7 * b 
                  bsum = bsum + 2^6 * c 
                  bsum = bsum + 2^5 * d 
                  bsum = bsum + 2^4 * e
                  bsum = bsum + 2^3 * f
                  bsum = bsum + 2^2 * g
                  bsum = bsum + 2^1 * h
                  bsum = bsum + 2^0 * i
                  local neighbourhood = {
                      a, b, c,
                      d, e, f,
                      g, h, i
                  }
                  local neighbours = a + b + c + d + 0 + f + g + h + i
                  if neighbours < 2 then
                    ruleset[bsum] = 0

                  elseif neighbours == 2 then
                    if  neighbourhood[5] == 1 then
                      ruleset[bsum] = 1 -- survival
                    else
                      ruleset[bsum] = 0 -- already dead
                    end

                  elseif neighbours == 3 then
                    ruleset[bsum] = 1 -- birth or survival

                  elseif neighbours > 3 then
                    ruleset[bsum] = 0
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

print("ruleset = {")
for k, v in pairs(ruleset) do
  print("[" .. k .. "] = " .. v .. ",")
end
print("}")
