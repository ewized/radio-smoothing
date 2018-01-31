-- Copyright 2018 Joshua "ewized" Rodriguez
-- Version: 1.1
--
local INPUTS = {
  {"T Filter", VALUE, 0, 99, 20},
  {"YPR Filter", VALUE, 0, 99, 40},
  {"Throttle", SOURCE}, -- Thr = Thr
  {"Yaw/Rud", SOURCE}, -- Yaw = Rud
  {"Pitch/Ele", SOURCE}, -- Pitch = Ele
  {"Roll/Ail", SOURCE} -- Roll = Ail
}
local OUTPUTS = {"Throttle", "Yaw", "Pitch", "Roll"}
local INT_TO_DEC = 0.01

local lastValues = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}

-- localised the math functions to avoid hashtable looksups
local min = math.min
local ceil = math.ceil
local abs = math.abs

-- Smooth the value that we are given with a decrease of filtering dependent on the higher derivative of the values
local function filter(percent, index, value)
  -- If percent is zero/disabled just return the value
  if percent == 0 then
    return value
  end
  -- proced to caculate the filtering and store the derivatives
  local lastValue = lastValues[index]
  local delta = min(lastValue[2], percent - 1)
  local smooth = ceil((lastValue[1] * (percent - delta) * INT_TO_DEC) + (value * (100 - percent + delta) * INT_TO_DEC))
  lastValues[index] = {smooth, (abs(smooth - value) * (1 / percent))}
  return smooth
end

-- The function that runs during the mixer function routine
local function smoothingFilter(tFilter, yprFilter, a, b, c, d)
  -- todo see if we can use lua features to unpack the args
  local outputs = {}
  outputs[1] = filter(tFilter, 1, a)
  outputs[2] = filter(yprFilter, 2, b)
  outputs[3] = filter(yprFilter, 3, c)
  outputs[4] = filter(yprFilter, 4, d)
  return outputs[1], outputs[2], outputs[3], outputs[4]
  -- return arg
end

return {input=INPUTS, output=OUTPUTS, run=smoothingFilter}
