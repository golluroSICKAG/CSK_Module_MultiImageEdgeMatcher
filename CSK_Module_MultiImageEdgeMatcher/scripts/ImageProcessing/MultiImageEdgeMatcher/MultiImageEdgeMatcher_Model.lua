---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiImageEdgeMatcher'

-- Create kind of "class"
local multiImageEdgeMatcher = {}
multiImageEdgeMatcher.__index = multiImageEdgeMatcher

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to create new instance
---@param multiImageEdgeMatcherInstanceNo int Number of instance
---@return table[] self Instance of multiImageEdgeMatcher
function multiImageEdgeMatcher.create(multiImageEdgeMatcherInstanceNo)

  local self = {}
  setmetatable(self, multiImageEdgeMatcher)

  self.multiImageEdgeMatcherInstanceNo = multiImageEdgeMatcherInstanceNo -- Number of this instance
  self.multiImageEdgeMatcherInstanceNoString = tostring(self.multiImageEdgeMatcherInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('ImageProcessing/MultiImageEdgeMatcher/helper/funcs') -- Load helper functions

  -- Optionally check if specific API was loaded via
  --[[
  if _G.availableAPIs.specific then
  -- ... doSomething ...
  end
  ]]

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Check if this instance is currently active in UI

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiImageEdgeMatcher_Parameter' .. self.multiImageEdgeMatcherInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.registeredEvent = '' -- Event to register for new images to process, like 'CSK_ImagePlayer.OnNewImage'
  self.parameters.processingFile = 'CSK_MultiImageEdgeMatcher_Processing' -- Which file to use for processing (will be started in own thread)

  self.parameters.showImage = true -- Show image in UI viewer

  self.parameters.matcher = Image.Matching.EdgeMatcher.create() -- EdgeMatcher handle
  self.parameters.edgeThreshold = 30 -- EdgeMatcher edge threshold
  self.parameters.minScore = 0.8 -- Minimum score to count as a found object
  self.parameters.downsampleFactor = 2 -- EdgeMatcher downsample factor. ReTeach EdgeMatcher if setting this value.
  self.parameters.maxMatches = 1 -- Maximum amount of matches to accept
  self.parameters.showImage = true -- Show image in UI

  -- Parameters to give to the processing script
  self.multiImageEdgeMatcherProcessingParams = Container.create()
  self.multiImageEdgeMatcherProcessingParams:add('multiImageEdgeMatcherInstanceNumber', multiImageEdgeMatcherInstanceNo, "INT")
  self.multiImageEdgeMatcherProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")
  self.multiImageEdgeMatcherProcessingParams:add('showImage', self.parameters.showImage, "BOOL")
  self.multiImageEdgeMatcherProcessingParams:add('viewerId', 'multiImageEdgeMatcherViewer' .. self.multiImageEdgeMatcherInstanceNoString, "STRING")

  self.multiImageEdgeMatcherProcessingParams:add('edgeThreshold', self.parameters.edgeThreshold, "INT")
  self.multiImageEdgeMatcherProcessingParams:add('minScore', self.parameters.minScore, "FLOAT")
  self.multiImageEdgeMatcherProcessingParams:add('downsampleFactor', self.parameters.downsampleFactor, "INT")
  self.multiImageEdgeMatcherProcessingParams:add('maxMatches', self.parameters.maxMatches, "INT")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiImageEdgeMatcherProcessingParams)

  return self
end

return multiImageEdgeMatcher

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************