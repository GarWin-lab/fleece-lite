-------------------------------------------------------------------------------
--- Package     : Fleece - fast Lua to JSON module                          ---
--- File        : test/bench6a.lua                                          ---
--- Description : Fleece only: buf finder. 10 tables, 10000 elements        ---
--- Version     : 0.3.1 / alpha                                             ---
--- Copyright   : 2011 Henning Diedrich, Eonblast Corporation               ---
--- Author      : H. Diedrich <hd2010@eonblast.com>                         ---
--- License     : see file LICENSE                                          ---
--- Created     : 03 Mar 2011                                               ---
--- Changed     : 03 Mar 2011                                               ---
-------------------------------------------------------------------------------
---                                                                         ---
---  Fleece is optimized for the fastest Lua to JSON conversion and beats   ---
---  other JSON implementations by around 10 times, native Lua up to 100x.  ---
---  Please let me know about the speed you are observing.                  ---
---  hd2010@eonblast.com                                                    ---
---                                                                         ---
---  This is a 'crash test' running long and slow. It was introduced to     ---
---  find a specific bug in the buffers that could be replicated with       ---
---  the 10000/10 setting.                                                  ---
---                                                                         ---
---  This file tests Fleece                                                 ---
---                                                                         ---
---  Use: lua test/bench6a.lua                                              ---
---                                                                         ---
-------------------------------------------------------------------------------

print("Fleece Benchmarks - Long Running Crash Test")
print("=========================================================")
print("A couple of random tables are created and speed is clocked.")
print("This test was introduced to track a bug down.");

package.cpath="src/?.so"
fleece = require("fleece")

sep = "---------------------------------------------------------------------------------"

all = function() 

printcol = 0
function printf(...)
	s = string.format(...)
	if(s:find("\n")) then printcol = 0 else printcol = printcol + s:len() end
    io.write(s)
end

function tab(x)
	while(printcol < x) do io.write(" "); printcol = printcol + 1 end
end

function nanosecs_per(time, per)
	return time * 1000000000 / per
end

function microsecs_per(time, per)
	return time * 1000000 / per
end

local abc = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
function randstr(i)
      local r = {}
      local length = math.random(1,20)
      local i
      for i = 1, length do
         r[i] = abc[math.random(1, 26)]
      end

      return table.concat(r)
 end

local t = {}
local function measure(prepP, prepare, actionP, action, printPrepP)

  local items  = ELEMENTS
  local cycles = CYCLES
  local clock  = os.clock

  if(printPrepP) then
    printf("%d elements in %-25s\n", items, prepP)
  end
  printf("%dx %-12s ", cycles, actionP)

  t = {}
  local i = 1
  local size = 0
  while(i <= items) do prepare(i); i = i + 1 end

  i = 1
  local last = nil
  local tm = clock()
  while(i <= cycles) do last = action(i); i = i + 1 end
  tm = clock() - tm
  if tm ~= 0 then
  	 mspc= nanosecs_per(tm, cycles * items)
  	 tab(27)
  	 printf("%10.0fns/element ", mspc)
  else
	  mspc = nil
	  printf("%dx %-12s sample too small, could not measure ", cycles, actionP)
  end
  
  return mspc, last 
end
if(_PATCH) then io.write(_PATCH) else io.write(_VERSION .. ' official') end
print(" - Fleece 0.3.1")


local function measure3(prepP, prepare, prompt1, action1, prompt2, action2, prompt3, action3)

  print(sep)

	third, r3 = measure(prepP, prepare, prompt3, action3, true)
	printf("    %.20s.. \n", r3)
end


measure3("t[i]=i",
		function(i) t[i] = i end,
		"luajson.stringify(t)",
		function(i) return luajson.stringify(t) end,
		"json4.encode(t)",
		function(i) return json4.encode(t) end,
		"fleece.json(t)",
		function(i) return fleece.json(t) end
		)

measure3("t['x'..i]=i",
		function(i) t['x'..i] = i end,
		"luajson.stringify(t)",
		function(i) return luajson.stringify(t) end,
		"json4.encode(t)",
		function(i) return json4.encode(t) end,
		"fleece.json(t)",
		function(i) return fleece.json(t) end
		)		

measure3("t[i]=randstr(i)",
		function(i) t[i] = randstr(i) end,
		"luajson.stringify(t)",
		function(i) return luajson.stringify(t) end,
		"json4.encode(t)",
		function(i) return json4.encode(t) end,
		"fleece.json(t)",
		function(i) return fleece.json(t) end
		)		
		
measure3("t[randstr(i)]=randstr(i)",
		function(i) t[randstr(i)] = randstr(i) end,
		"luajson.stringify(t)",
		function(i) return luajson.stringify(t) end,
		"json4.encode(t)",
		function(i) return json4.encode(t) end,
		"fleece.json(t)",
		function(i) return fleece.json(t) end
		)			
print(sep)

end

ELEMENTS = 10000
CYCLES   = 100
all()

print("Note that fleece may list associative arrays in different order.")
