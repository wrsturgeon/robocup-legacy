/**
 * @file MessageIDs.h
 *
 * Declaration of ids for debug messages.
 *
 * @author Martin Lötzsch
 */

#pragma once

#include "Tools/Streams/Enum.h"

/**
 * IDs for debug messages
 *
 * To distinguish debug messages, they all have an id.
 */
ENUM(MessageID,
{,
  undefined,
  idFrameBegin,
  idFrameFinished,

  idActivationGraph,
  idAlternativeRobotPoseHypothesis,
  idAnnotation,
  idAudioData,
  idBallModel,
  idBallPercept,
  idBallSpots,
  idBehaviorStatus,
  idBodyContour,
  idCameraImage,
  idCameraInfo,
  idCameraMatrix,
  idCirclePercept,
  idConfirmedBallSpot,
  idDebuggingOutput,
  idExternStrategyInput,
  idFallDownState,
  idFieldBoundary,
  idFieldColors,
  idFieldCoverage,
  idFieldFeatureOverview,
  idFrameInfo,
  idFsrSensorData,
  idGameInfo,
  idGetUpEngineOutput,
  idGetUpEngineOutputLog,
  idGlobalOptions,
  idGroundTruthOdometryData,
  idGroundTruthWorldState,
  idImageCoordinateSystem,
  idImagePatches,
  idInertialData,
  idInertialSensorData,
  idJointAngles,
  idJointCalibration,
  idJointLimits,
  idJointRequest,
  idJointSensorData,
  idJPEGImage,
  idKeyStates,
  idKickPose,
  idLabelImage,
  idLinesPercept,
  idLowFrameRateImage,
  idMotionInfo,
  idMotionRequest,
  idObstacleModel,
  idObstaclesFieldPercept,
  idObstaclesImagePercept,
  idOdometer,
  idOdometryData,
  idOdometryOffset,
  idOpponentTeamInfo,
  idOwnTeamInfo,
  idPenaltyMarkPercept,
  idRobotDimensions,
  idRobotHealth,
  idRobotInfo,
  idRobotPose,
  idScanlineRegions,
  idSelfLocalizationHypotheses,
  idSideConfidence,
  idStableStand,
  idStopwatch,
  idSystemSensorData,
  idTeamActivationGraph,
  idTeamBallModel,
  idTeamBehaviorStatus,
  idTeamData,
  idTeamPlayersModel,
  idThumbnail,
  idWalkGenerator,
  idWalkingEngineOutput,
  idWalkLearner,
  idWhistle,
  numOfDataMessageIDs, /**< everything below this does not belong into log files */

  // infrastructure
  idRobot = numOfDataMessageIDs,
  idConsole,
  idDebugDataChangeRequest,
  idDebugDataResponse,
  idDebugDrawing,
  idDebugDrawing3D,
  idDebugImage,
  idDebugJPEGImage,
  idDebugRequest,
  idDebugResponse,
  idDrawingManager,
  idDrawingManager3D,
  idLogResponse,
  idModuleRequest,
  idModuleTable,
  idMotionNet,
  idPlot,
  idQueueFillRequest,
  idRobotname,
  idText,
  idTypeInfo,
  idTypeInfoRequest,
  idColorCalibration,
});
