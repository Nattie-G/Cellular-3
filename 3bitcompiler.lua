rs = {}
states = 6
pow = states - 1
for a = 0, pow do
  for b = 0, pow do
    for c = 0, pow do
      for d = 0, pow do
        for e = 0, pow do
          for f = 0, pow do
            for g = 0, pow do
              for h = 0, pow do
                for i = 0, pow do
                  local sum = 0
                  sum = sum + 2^8 * a 
                  sum = sum + 2^7 * b 
                  sum = sum + 2^6 * c 
                  sum = sum + 2^5 * d 
                  sum = sum + 2^4 * e
                  sum = sum + 2^3 * f
                  sum = sum + 2^2 * g
                  sum = sum + 2^1 * h
                  sum = sum + 2^0 * i
                  --[[
                      a, b, c,
                      d, e, f,
                      g, h, i

                  0 -> empty
                  1 -> trail
                  2 -> head facing left
                  3 -> head facing up
                  4 -> head facing right
                  5 -> head facing down
                  --]]
                  if (e == 2) or (e == 3) or (e == 4) or (e == 5) then
                    rs[sum] 
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
for k, v in pairs(ruleset) do
  print("[" .. k .. "] = " .. v .. ",")
end
print("}")
