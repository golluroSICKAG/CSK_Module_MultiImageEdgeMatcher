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
  self.parameters.registeredEvent = '' -- Event to register for new images to process, like 'CSK_ImagePlayer.OnNewImage'
  self.parameters.processingFile = 'CSK_MultiImageEdgeMatcher_Processing' -- Which file to use for processing (will be started in own thread)

  self.parameters.showImage = true -- Show image in UI viewer

  self.parameters.matcher = Image.Matching.EdgeMatcher.create() -- EdgeMatcher handle
  self.parameters.edgeThreshold = 30 -- EdgeMatcher edge threshold
  self.parameters.minScore = 0.8 -- Minimum score to count as a found object
  self.parameters.downsampleFactor = 2 -- EdgeMatcher downsample factor. ReTeach EdgeMatcher if setting this value.
  self.parameters.maxMatches = 1 -- Maximum amount of matches to accept

  self.parameters.backgroundClutter = 'HIGH' -- Level the live images supplied to the match function are expected to contain non-object edges
  self.parameters.fineSearch = true -- Status if fine sarch shuld be performed 
  self.parameters.minSeparation = 50.0 -- Minimum separation between the centers of object matches in image world units (typically millimeters) taking the image pixel size into account.
  self.parameters.rotationRange = 180 -- Angle in degrees, the maximum deviation from the original object orientation to search for.
  self.parameters.priorRotationRange = 0.0 -- Optional prior orientation in radians. If specified, the orientation search range is centered around this orientation
  self.parameters.minScaleRange = 1.0 -- The smallest scale factor to search for. Lower limit is 0.8
  self.parameters.maxScaleRange = 1.0 -- The largest scale factor to search for. Upper limit is 1.2
  self.parameters.priorScale = 1.0 -- Optional prior scale factor. Set to the expected scale of the object to find, relative to the size of the teach object. E.g. 1.25 if the object to find is 25% larger than the teach object. Min: 0.1. Max: 10
  self.parameters.tileCount = 0 -- Number of tile images to split into. 0 gives automatic selection. 1 disables tiling
  self.parameters.timeout = 5 -- Abort the match call if the match time exceeds set number of seconds.

  self.parameters.showImage = true -- Show image in UI

  self.parameters.resultTransX = 320 -- Pixel to translate the found result position in x
  self.parameters.resultTransY = 240 -- Pixel to translate the found result position in y

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