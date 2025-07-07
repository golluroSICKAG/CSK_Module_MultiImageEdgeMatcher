---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local multiImagEdgeMatcherParameters = {}
  multiImagEdgeMatcherParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiImagEdgeMatcherParameters.registeredEvent = '' -- Event to register for new images to process, like 'CSK_ImagePlayer.OnNewImage'
  multiImagEdgeMatcherParameters.processingFile = 'CSK_MultiImageEdgeMatcher_Processing' -- Which file to use for processing (will be started in own thread)

  multiImagEdgeMatcherParameters.showImage = true -- Show image in UI viewer

  multiImagEdgeMatcherParameters.matcher = Image.Matching.EdgeMatcher.create() -- EdgeMatcher handle
  multiImagEdgeMatcherParameters.edgeThreshold = 30 -- EdgeMatcher edge threshold
  multiImagEdgeMatcherParameters.minScore = 0.8 -- Minimum score to count as a found object
  multiImagEdgeMatcherParameters.downsampleFactor = 2 -- EdgeMatcher downsample factor. ReTeach EdgeMatcher if setting this value.
  multiImagEdgeMatcherParameters.maxMatches = 1 -- Maximum amount of matches to accept

  multiImagEdgeMatcherParameters.backgroundClutter = 'HIGH' -- Level the live images supplied to the match function are expected to contain non-object edges
  multiImagEdgeMatcherParameters.fineSearch = true -- Status if fine sarch shuld be performed 
  multiImagEdgeMatcherParameters.minSeparation = 50.0 -- Minimum separation between the centers of object matches in image world units (typically millimeters) taking the image pixel size into account.
  multiImagEdgeMatcherParameters.rotationRange = 180 -- Angle in degrees, the maximum deviation from the original object orientation to search for.
  multiImagEdgeMatcherParameters.priorRotationRange = 0.0 -- Optional prior orientation in radians. If specified, the orientation search range is centered around this orientation
  multiImagEdgeMatcherParameters.minScaleRange = 1.0 -- The smallest scale factor to search for. Lower limit is 0.8
  multiImagEdgeMatcherParameters.maxScaleRange = 1.0 -- The largest scale factor to search for. Upper limit is 1.2
  multiImagEdgeMatcherParameters.priorScale = 1.0 -- Optional prior scale factor. Set to the expected scale of the object to find, relative to the size of the teach object. E.g. 1.25 if the object to find is 25% larger than the teach object. Min: 0.1. Max: 10
  multiImagEdgeMatcherParameters.tileCount = 0 -- Number of tile images to split into. 0 gives automatic selection. 1 disables tiling
  multiImagEdgeMatcherParameters.timeout = 5 -- Abort the match call if the match time exceeds set number of seconds.

  multiImagEdgeMatcherParameters.showImage = true -- Show image in UI

  multiImagEdgeMatcherParameters.resultTransX = 320 -- Pixel to translate the found result position in x
  multiImagEdgeMatcherParameters.resultTransY = 240 -- Pixel to translate the found result position in y

  return multiImagEdgeMatcherParameters
end
functions.getParameters = getParameters

return functions