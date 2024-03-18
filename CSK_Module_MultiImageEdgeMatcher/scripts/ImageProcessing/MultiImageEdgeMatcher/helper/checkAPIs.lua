---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

local function loadAPIs()
  CSK_MultiImageEdgeMatcher = require 'API.CSK_MultiImageEdgeMatcher'

  Container = require 'API.Container'
  Engine = require 'API.Engine'
  Image = require 'API.Image'
  Image.Matching = {}
  Image.Matching.EdgeMatcher = require 'API.Image.Matching.EdgeMatcher'
  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'
  Object = require 'API.Object'
  Point = require 'API.Point'
  Shape = require 'API.Shape'
  Timer = require 'API.Timer'
  Transform = require 'API.Transform'
  View = require 'API.View'
  View.ShapeDecoration = require 'API.View.ShapeDecoration'
  View.TextDecoration = require 'API.View.TextDecoration'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    end
  end
end

local function loadSpecificAPIs()
  -- If you want to check for specific APIs/functions supported on the device the module is running, place relevant APIs here
  -- e.g.:
  -- NTPClient = require 'API.NTPClient'
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.specific = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly

return availableAPIs
--**************************************************************************