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

multiImageEdgeMatcher.styleForUI = 'None' -- Optional parameter to set UI style
multiImageEdgeMatcher.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiImageEdgeMatcher.styleForUI = theme
  Script.notifyEvent("MultiImageEdgeMatcher_OnNewStatusCSKStyle", multiImageEdgeMatcher.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiImageEdgeMatcherInstanceNo int Number of instance
---@return table[] self Instance of multiImageEdgeMatcher
function multiImageEdgeMatcher.create(multiImageEdgeMatcherInstanceNo)

  local self = {}
  setmetatable(self, multiImageEdgeMatcher)

  self.multiImageEdgeMatcherInstanceNo = multiImageEdgeMatcherInstanceNo -- Number of this instance
  self.multiImageEdgeMatcherInstanceNoString = tostring(self.multiImageEdgeMatcherInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('ImageProcessing/MultiImageEdgeMatcher/helper/funcs') -- Load helper functions

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

  self.tought = false -- Status if matcher was already tought

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters = self.helperFuncs.defaultParameters.getParameters() -- Load default parameters

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

  self.multiImageEdgeMatcherProcessingParams:add('backgroundClutter', self.parameters.backgroundClutter, "STRING")
  self.multiImageEdgeMatcherProcessingParams:add('minSeparation', self.parameters.minSeparation, "FLOAT")
  self.multiImageEdgeMatcherProcessingParams:add('fineSearch', self.parameters.fineSearch, "BOOL")
  self.multiImageEdgeMatcherProcessingParams:add('rotationRange', self.parameters.rotationRange, "FLOAT")
  self.multiImageEdgeMatcherProcessingParams:add('priorRotationRange', self.parameters.priorRotationRange, "FLOAT")
  self.multiImageEdgeMatcherProcessingParams:add('minScaleRange', self.parameters.minScaleRange, "FLOAT")
  self.multiImageEdgeMatcherProcessingParams:add('maxScaleRange', self.parameters.maxScaleRange, "FLOAT")
  self.multiImageEdgeMatcherProcessingParams:add('priorScale', self.parameters.priorScale, "FLOAT")
  self.multiImageEdgeMatcherProcessingParams:add('tileCount', self.parameters.tileCount, "INT")
  self.multiImageEdgeMatcherProcessingParams:add('timeout', self.parameters.timeout, "FLOAT")

  self.multiImageEdgeMatcherProcessingParams:add('resultTransX', self.parameters.resultTransX, "INT")
  self.multiImageEdgeMatcherProcessingParams:add('resultTransY', self.parameters.resultTransY, "INT")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiImageEdgeMatcherProcessingParams)

  return self
end

return multiImageEdgeMatcher

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************