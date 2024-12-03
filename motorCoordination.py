#Import libraries
import RPi.GPIO as GPIO
import time
import json
from RpiMotorLib import RpiMotorLib
import concurrent.futures

#Translate XY draw plane point to step positions
def pointToSteps(point, motorStepCounts):
    #Declare variables to hold step conversion and steps needed to execute
    pointInSteps = [0,0]
    steps = [0,0]
    
    #Convert point X and Y to steps
    pointInSteps[0] = point[0]
    pointInSteps[1] = point[1]
    
    
    #Calculate step differential to get to point
    steps[0] = motorStepCounts[0] - pointInSteps[0]
    steps[1] = motorStepCounts[1] - pointInSteps[1]
    
    #Return steps needed and new motor positions
    return steps, pointInSteps

def declareMotors():    
    #Define GPIO pins for motor bicep
    msPinsB = (14,15,18)
    dirPinB = 20
    stepPinB = 21

    #Define GPIO pins for motor forearm
    msPinsF = (17,27,22)
    dirPinF = 23
    stepPinF = 24

    #Declare motor instances
    motForearm = RpiMotorLib.A4988Nema(dirPinB, stepPinB, msPinsB, "A4988")
    motBicep = RpiMotorLib.A4988Nema(dirPinF, stepPinF, msPinsF, "A4988")
    
    return motForearm, motBicep

def executeDesign(motForearm, motBicep, pointsJson):
    motorStepCounts = [0,0]
    prevSteps = [0,0]
    
    #Declare bool to determine direction (Clockwise = True)
    stepDirB = True
    stepDirF = True
    
    #Iterate through every point in design
    for point in pointsJson[0]:
        with concurrent.futures.ThreadPoolExecutor() as executor:
            threadB = executor.submit(motBicep.motor_go, stepDirB, "Full", int(abs(prevSteps[0])), .005, False, .05)
            threadF = executor.submit(motForearm.motor_go, stepDirF, "Full", int(abs(prevSteps[1])), .005, False, .05)
            
        pointReal = []
        pointReal.append(int(point[0]))
        pointReal.append(int(point[1]))
    
        #Calculate step differential to get to point
        prevSteps[0] = motorStepCounts[0] - pointReal[0]
        prevSteps[1] = motorStepCounts[1] - pointReal[1]
        motorStepCounts = pointReal
        
        print(prevSteps)
        
        #Reverse direction if step amount is positive
        if (prevSteps[0] > 0):
            stepDirB = False    
        if (prevSteps[1] > 0):
            stepDirF = False
            
        while(not threadB.done() or not threadF.done()):
           continue
            
