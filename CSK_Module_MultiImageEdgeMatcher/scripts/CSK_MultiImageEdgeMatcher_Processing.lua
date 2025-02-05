---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('ImageProcessing/MultiImageEdgeMatcher/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiImageEdgeMatcher'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiImageEdgeMatcherInstanceNumber = scriptParams:get('multiImageEdgeMatcherInstanceNumber') -- number of this instance
local multiImageEdgeMatcherInstanceNumberString = tostring(multiImageEdgeMatcherInstanceNumber) -- number of this instance as string
local viewerId = scriptParams:get('viewerId')
local viewer = View.create(viewerId) --> if needed
local transViewer = View.create('viewer')
local latestImage = nil -- holds image to post process e.g. after changing parameters

local imageQueue = Script.Queue.create() -- Queue to stop processing if increasing too much
local lastQueueSize = nil -- Size of queue

local imageID = 'Image' -- image ID for viewer
local roiID = 'ROI' -- ID of ROI in viewer
local matcherID = 'matcherID'
local roiEditorActive = false -- is ROI editor in viewer active
local installedEditorIconic = nil -- is editor in viewer installed on an object like pipette, ROI, mask

local decorationOK = View.ShapeDecoration.create()
decorationOK:setFillColor(0, 127, 195, 100)
decorationOK:setLineWidth(3)

local tought = false

local centerX_ROI = 100.0 -- xPos of ROI
local centerY_ROI = 100.0 -- yPos of ROI
local radius_ROI = 100.0 -- radius of ROI if circle
local width_ROI = 100.0 -- width of ROI
local height_ROI = 100.0 -- height of ROI
local center_ROI = Point.create(centerX_ROI, centerY_ROI) -- centerPoint of ROI
local roi = Shape.createRectangle(center_ROI, width_ROI, height_ROI) -- ROI itself
local gotImageSize = false -- Flag to check if image size was checked

-- Event to notify amount of found matches
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewStatusFoundMatches" .. multiImageEdgeMatcherInstanceNumberString, "MultiImageEdgeMatcher_OnNewStatusFoundMatches" .. multiImageEdgeMatcherInstanceNumberString, 'int')
-- Event to notify amount of found matches with valid score
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewStatusFoundValidMatches" .. multiImageEdgeMatcherInstanceNumberString, "MultiImageEdgeMatcher_OnNewStatusFoundValidMatches" .. multiImageEdgeMatcherInstanceNumberString, 'int')
-- Event to notify score of match.
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewStatusMatchScoreResult" .. multiImageEdgeMatcherInstanceNumberString, "MultiImageEdgeMatcher_OnNewStatusMatchScoreResult" .. multiImageEdgeMatcherInstanceNumberString, 'float:*')

-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewValueToForward".. multiImageEdgeMatcherInstanceNumberString, "MultiImageEdgeMatcher_OnNewValueToForward" .. multiImageEdgeMatcherInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewValueUpdate" .. multiImageEdgeMatcherInstanceNumberString, "MultiImageEdgeMatcher_OnNewValueUpdate" .. multiImageEdgeMatcherInstanceNumberString, 'int, string, auto, int:?')

-- Event to forward aligned image
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewAlignedImage" .. multiImageEdgeMatcherInstanceNumberString, "MultiImageEdgeMatcher_OnNewAlignedImage" .. multiImageEdgeMatcherInstanceNumberString, 'object:1:Image')

-- Event to forward transformation
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewTransformation" .. multiImageEdgeMatcherInstanceNumberString, "MultiImageEdgeMatcher_OnNewTransformation" .. multiImageEdgeMatcherInstanceNumberString, 'object:[?*]:Transform')

local processingParams = {}
processingParams.matcher = Image.Matching.EdgeMatcher.create() -- EdgeMatcher
processingParams.matcher:setProcessingUnit('CPU')
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false
processingParams.showImage = scriptParams:get('showImage')

processingParams.edgeThreshold = scriptParams:get('edgeThreshold')
processingParams.minScore = scriptParams:get('minScore')
processingParams.downsampleFactor = scriptParams:get('downsampleFactor')
processingParams.maxMatches = scriptParams:get('maxMatches')

processingParams.backgroundClutter = scriptParams:get('backgroundClutter') -- makes invalid
processingParams.minSeparation = scriptParams:get('minSeparation')
processingParams.fineSearch = scriptParams:get('fineSearch')
processingParams.rotationRange = scriptParams:get('rotationRange')
processingParams.priorRotationRange = scriptParams:get('priorRotationRange')
processingParams.minScaleRange = scriptParams:get('minScaleRange')
processingParams.maxScaleRange = scriptParams:get('maxScaleRange')
processingParams.priorScale = scriptParams:get('priorScale')
processingParams.tileCount = scriptParams:get('tileCount')
processingParams.timeout = scriptParams:get('timeout')

processingParams.matcher:setEdgeThreshold(processingParams.edgeThreshold)
processingParams.matcher:setDownsampleFactor(processingParams.downsampleFactor)
processingParams.matcher:setMaxMatches(processingParams.maxMatches)
processingParams.matcher:setBackgroundClutter(processingParams.backgroundClutter)
processingParams.matcher:setMinSeparation(processingParams.minSeparation)
processingParams.matcher:setPerformFineSearch(processingParams.fineSearch)
processingParams.matcher:setMinSeparation(processingParams.minSeparation)
processingParams.matcher:setRotationRange(processingParams.rotationRange*(math.pi/180), processingParams.priorRotationRange*(math.pi/180))
processingParams.matcher:setScaleRange(processingParams.minScaleRange, processingParams.maxScaleRange, processingParams.priorScale)
processingParams.matcher:setTileCount(processingParams.tileCount)
processingParams.matcher:setTimeout(processingParams.timeout)

processingParams.resultTransX = scriptParams:get('resultTransX')
processingParams.resultTransY = scriptParams:get('resultTransY')

--- Function to create ROI related to image size
---@param img Image Image to process
local function checkForImageSize(img)
  width_ROI = Image.getWidth(img)
  height_ROI = Image.getHeight(img)

  centerX_ROI = width_ROI/2
  centerY_ROI = height_ROI/2

  center_ROI = Point.create(centerX_ROI, centerY_ROI)
  roi = Shape.createRectangle(center_ROI, width_ROI/6, height_ROI/6)

  gotImageSize = true
end

---------------------------

--- Function to teach the EdgeMachter instance.
---@param img Image Image to process
local function teachEdgeMatcher(img)

  viewer:clear()
  local parentID = viewer:addImage(img, nil, imageID)
  if not gotImageSize then
    checkForImageSize(img)
  end
  viewer:addShape(roi, decorationOK, roiID, parentID)
  viewer:installEditor(roiID)
  installedEditorIconic = roiID

  local teachRegion = roi:toPixelRegion(img)

  -- Check if wanted downsample factor is supported by device
  local minDsf,_ = processingParams.matcher:getDownsampleFactorLimits(img)
  if (minDsf > processingParams.downsampleFactor) then
    _G.logger:info("Cannot use downsample factor " .. tostring(processingParams.downsampleFactor) .. " will use " .. minDsf .. " instead")
    processingParams.downsampleFactor = minDsf
    processingParams.matcher:setDownsampleFactor(minDsf)
  end

  -- Teaching edge matcher
  local teachPose = processingParams.matcher:teach(img, teachRegion)
  if teachPose then
    _G.logger:info("Teach OK")
    tought = true

    local serMatcher = Object.serialize(processingParams.matcher, 'JSON')
    Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueUpdate" .. multiImageEdgeMatcherInstanceNumberString, multiImageEdgeMatcherInstanceNumber, 'matcher', serMatcher)

    -- Viewing model points overlayed in teach image
    local modelContour = processingParams.matcher:getModelContours() -- Model contour in model's local coord syst

    local teachContour = Shape.transform(modelContour, teachPose)

    for _, point in ipairs(teachContour) do
      viewer:addShape(point, decorationOK, nil, imageID)
    end

    viewer:present()
  else
    _G.logger:warning(nameOfModule .. ": Edge Matcher teaching not succesfull.")
    tought = false
  end
end

local function handleOnNewProcessing(image)

  _G.logger:fine(nameOfModule .. ": Check object on instance No." .. multiImageEdgeMatcherInstanceNumberString)

  -- Set ROI for actual color if just configured
  if roiEditorActive == true then
    if installedEditorIconic == nil then
      viewer:clear()
      local parentEditorID = viewer:addImage(image, nil, imageID)
      if not gotImageSize then
        checkForImageSize(image)
      end
      viewer:addShape(roi, decorationOK, roiID, parentEditorID)
      viewer:installEditor(roiID)
      installedEditorIconic = roiID
      viewer:present()

      latestImage = image

    end

    return
  end

  -- Future improvement
  --[[
  -- Check size of queue
  local imageQueueSize = imageQueue:getSize()
  if processingParams.activeInUI == true and imageQueueSize ~= lastQueueSize then
      Script.notifyEvent('MultiImageEdgeMatcher_OnNewValueToForward' .. multiImageEdgeMatcherInstanceNumberString, 'MultiImageEdgeMatcher_OnNewImageQueue', tostring(imageQueueSize))
      lastQueueSize = imageQueueSize
  end

  if imageQueueSize >= processingParams.maxImageQueueSize then
    _G.logger:warning(nameOfModule .. ": Warning! ImageQueue of instance " .. multiImageEdgeMatcherInstanceNumberString .. "is >= " .. tostring(processingParams.maxImageQueueSize) .. "! Stop processing images! Data loss possible...")
  else
  ]]

  local parentID
  if processingParams.showImage and processingParams.activeInUI then
    viewer:clear()
    parentID = viewer:addImage(image)
  end

  if tought then

    -- Finding object pose
    local poses, scores = processingParams.matcher:match(image)

    if poses then
      -- Finding index of first match with score less than minimum score
      local validScores = 0 -- Valid object counter
      local scoreList = '' -- List of scores
      for k = 1, #scores do
        if k == 1 then
          scoreList = scoreList .. string.format('%.2f',scores[k])
        else
          scoreList = scoreList .. ', ' .. string.format('%.2f',scores[k])
        end
        if scores[k] >= processingParams.minScore then
          validScores = validScores + 1
        end
      end

      Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusFoundMatches' .. multiImageEdgeMatcherInstanceNumberString, #poses)
      Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusFoundValidMatches' .. multiImageEdgeMatcherInstanceNumberString, validScores)
      Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusMatchScoreResult' .. multiImageEdgeMatcherInstanceNumberString, scores)

      if processingParams['activeInUI'] then
        Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueToForward" .. multiImageEdgeMatcherInstanceNumberString, 'MultiImageEdgeMatcher_OnNewStatusFoundMatches', tostring(#poses))
        Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueToForward" .. multiImageEdgeMatcherInstanceNumberString, 'MultiImageEdgeMatcher_OnNewStatusFoundValidMatches', tostring(validScores))
        Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueToForward" .. multiImageEdgeMatcherInstanceNumberString, 'MultiImageEdgeMatcher_OnNewStatusMatchScoreResult', tostring(scoreList))
      end
    else
      Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusFoundMatches' .. multiImageEdgeMatcherInstanceNumberString, 0)
      Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusFoundValidMatches' .. multiImageEdgeMatcherInstanceNumberString, 0)
      Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusMatchScoreResult' .. multiImageEdgeMatcherInstanceNumberString, nil)

      if processingParams['activeInUI'] then
        Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueToForward" .. multiImageEdgeMatcherInstanceNumberString, 'MultiImageEdgeMatcher_OnNewStatusFoundMatches', '0')
        Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueToForward" .. multiImageEdgeMatcherInstanceNumberString, 'MultiImageEdgeMatcher_OnNewStatusFoundValidMatches', '0')
        Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueToForward" .. multiImageEdgeMatcherInstanceNumberString, 'MultiImageEdgeMatcher_OnNewStatusMatchScoreResult', '-')
      end
    end

    Script.notifyEvent('MultiImageEdgeMatcher_OnNewTransformation' .. multiImageEdgeMatcherInstanceNumberString, poses)

    -- Visualizing found objects
    for j = 1, #scores do
      if scores[j] >= processingParams.minScore then
        local outlines = Shape.transform(processingParams.matcher:getModelContours(), poses[j])
        if processingParams.showImage and processingParams.activeInUI then
          for _, outline in ipairs(outlines) do
            viewer:addShape(outline, decorationOK, nil, parentID)
            local currentPose
            if Transform.getType(poses[j]) == 'SIMILARITY' then
              _, currentPose = Transform.decomposeSimilarity2D(poses[j])
            else
              currentPose = poses[j]
            end
            local _, xTrans, yTrans = Transform.decomposeRigid2D(currentPose)
            local textDeco = View.TextDecoration.create()
            textDeco:setPosition(xTrans, yTrans)
            textDeco:setColor(0, 255, 0, 255)
            textDeco:setSize(15)
            viewer:addText('No.' .. tostring(j) .. ', Score:' .. string.format('%.2f',scores[j]), textDeco, nil, parentID)
          end
        end

        if j == 1 then
          local transPose = poses[j]:invert()
          local movedPose = Transform.translate2D(transPose, processingParams.resultTransX, processingParams.resultTransY)
          local transImage = image:transform(movedPose)

          Script.notifyEvent('MultiImageEdgeMatcher_OnNewAlignedImage' .. multiImageEdgeMatcherInstanceNumberString, transImage)
          if processingParams.showImage and processingParams.activeInUI then
            transViewer:addImage(transImage)
            transViewer:present()
          end
        end
      end
    end
  end
  viewer:present("LIVE")

  if latestImage == nil then
    latestImage = image
  end

end
Script.serveFunction("CSK_MultiImageEdgeMatcher.processInstance"..multiImageEdgeMatcherInstanceNumberString, handleOnNewProcessing, 'object:1:Image', 'bool:?')

--**********************************
-- Region of Interest Functions
--**********************************

--- Function to call if the installed editor detects changes of the iconic in the viewer
---@param iconicID string ID of the modified iconic
---@param iconic object The modified iconic
local function handleOnChangeEditor(iconicID, iconic)

  -- Checking if selected iconic is the added rectangle
  if iconicID == roiID then
    -- Updating rectangle in script with the one defined in the viewer and teach edge matcher
    roi = iconic
    teachEdgeMatcher(latestImage)
  end
end
View.register(viewer, 'OnChange', handleOnChangeEditor)

---------------------------------------------------

--- Function only used to forward the content from events to the served function.
--- This is only needed, as deregistering from the event would internally release the served function and would make it uncallable from external.
---@param image Image Image to process
local function tempHandleOnNewProcessing(image)
  handleOnNewProcessing(image)
end

--- Function to handle updates of processing parameters from Controller
---@param multiImageEdgeMatcherNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiImageEdgeMatcherNo, parameter, value, internalObjectNo)

  if multiImageEdgeMatcherNo == multiImageEdgeMatcherInstanceNumber then -- set parameter only in selected script
    _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiImageEdgeMatcherInstanceNo." .. tostring(multiImageEdgeMatcherNo) .. " to value = " .. tostring(value))

    if parameter == 'registeredEvent' then
      _G.logger:fine(nameOfModule .. ": Register instance " .. multiImageEdgeMatcherInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent and processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, tempHandleOnNewProcessing)
        imageQueue:clear()
      end
      processingParams.registeredEvent = value
      Script.register(value, tempHandleOnNewProcessing)
      imageQueue:setFunction(tempHandleOnNewProcessing)

    elseif parameter == 'deregisterFromEvent' then
      _G.logger:fine(nameOfModule .. ": Deregister instance " .. multiImageEdgeMatcherInstanceNumberString .. " from event")
      Script.deregister(processingParams.registeredEvent, tempHandleOnNewProcessing)
      processingParams.registeredEvent = ''

    elseif parameter == 'cancelEditors' then
      roiEditorActive = false

    elseif parameter == 'unteach' then
      processingParams.matcher = Image.Matching.EdgeMatcher.create()
      processingParams.matcher:setProcessingUnit('CPU')
      processingParams.matcher:setEdgeThreshold(processingParams.edgeThreshold)
      processingParams.matcher:setDownsampleFactor(processingParams.downsampleFactor)
      processingParams.matcher:setBackgroundClutter(processingParams.backgroundClutter)
      processingParams.matcher:setMaxMatches(processingParams.maxMatches)
      processingParams.matcher:setBackgroundClutter(processingParams.backgroundClutter)
      processingParams.matcher:setMinSeparation(processingParams.minSeparation)
      processingParams.matcher:setPerformFineSearch(processingParams.minSeparation)
      processingParams.matcher:setMinSeparation(processingParams.fineSearch)
      processingParams.matcher:setRotationRange(processingParams.rotationRange*(math.pi/180), processingParams.priorRotationRange*(math.pi/180))
      processingParams.matcher:setScaleRange(processingParams.minScaleRange, processingParams.maxScaleRange, processingParams.priorScale)
      processingParams.matcher:setTileCount(processingParams.tileCount)
      processingParams.matcher:setTimeout(processingParams.timeout)

      tought = false

    elseif parameter == 'roiEditorActive' then
      roiEditorActive = value
      if value == true then
        installedEditorIconic = nil
      else
        if latestImage then
          tempHandleOnNewProcessing(latestImage)
        else
          viewer:clear()
          viewer:present('LIVE')
        end
        Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueUpdate" .. multiImageEdgeMatcherInstanceNumberString, multiImageEdgeMatcherInstanceNumber, 'tought', tought)
      end

    elseif parameter == 'matcher' then
      processingParams.matcher = value

      -- Check if new matcher was tought.
      local suc = Image.Matching.EdgeMatcher.getTeachPose(value)
      if suc then
        tought = true
        -- Future improvement: Get Values from matcher?
      else
        tought = false
      end
      Script.notifyEvent("MultiImageEdgeMatcher_OnNewValueUpdate" .. multiImageEdgeMatcherInstanceNumberString, multiImageEdgeMatcherInstanceNumber, 'tought', tought)

    else
      processingParams[parameter] = value
      if parameter == 'edgeThreshold' then
        processingParams.matcher:setEdgeThreshold(processingParams.edgeThreshold)
      elseif parameter == 'downsampleFactor' then
        processingParams.matcher:setDownsampleFactor(processingParams.downsampleFactor)
        tought = false
      elseif parameter == 'maxMatches' then
        processingParams.matcher:setMaxMatches(processingParams.maxMatches)
      elseif parameter == 'backgroundClutter' then
        processingParams.matcher:setBackgroundClutter(processingParams.backgroundClutter)
      elseif parameter == 'minSeparation' then
        processingParams.matcher:setMinSeparation(processingParams.minSeparation)
      elseif parameter == 'fineSearch' then
        processingParams.matcher:setPerformFineSearch(processingParams.fineSearch)
        processingParams.matcher:setMaxMatches(processingParams.maxMatches)
      elseif parameter == 'rotationRange' or parameter == 'priorRotationRange' then
        processingParams.matcher:setRotationRange(processingParams.rotationRange*(math.pi/180), processingParams.priorRotationRange*(math.pi/180))
      elseif parameter == 'minScaleRange' or  parameter == 'maxScaleRange' or  parameter == 'priorScale' then
        processingParams.matcher:setScaleRange(processingParams.minScaleRange, processingParams.maxScaleRange, processingParams.priorScale)
      elseif parameter == 'tileCount' then
        processingParams.matcher:setTileCount(processingParams.tileCount)
      elseif parameter == 'timeout' then
        processingParams.matcher:setTimeout(processingParams.timeout)
      end
      if  parameter == 'showImage' and value == false then
        viewer:clear()
        viewer:present()
      end
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end

  -- Future improvement
  --[[
  if processingParams['activeInUI'] and latestImage and imageQueue:getSize() == 0 then -- and gotImageSize == true then -- parameter ~= 'imageSize' then
    if roiEditorActive then
      teachEdgeMatcher(latestImage)
    else
      handleOnNewProcessing(latestImage)
    end
  end
  ]]
end
Script.register("CSK_MultiImageEdgeMatcher.OnNewProcessingParameter", handleOnNewProcessingParameter)
