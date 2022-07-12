#!/usr/bin/env python3
import numpy as np
import time
from pythonosc.udp_client import SimpleUDPClient

BUFFER_SIZE = 100

NUM_FSR = 8
NUM_PIEZO = 4
FSR_NOTES = [74, 76, 78, 79, 81, 83, 85, 86]
PIEZO_NOTES = [100, 101, 102, 103]

IP = "127.0.0.1"
PORT = 5005

LOG_BUFFER_SIZE = 100

client = SimpleUDPClient(IP, PORT)

startTime = time.time()

class  Sensor:
	
	fsr_threshold = 100
	piezo_threshold = 100
	readIndex = 0
	log = [""] * LOG_BUFFER_SIZE
	filteredLog = [""] * LOG_BUFFER_SIZE
	logTime = [0] * LOG_BUFFER_SIZE
	logIndex = 0
	filteredLogIndex = 0
	filteredLogTime = [0] * LOG_BUFFER_SIZE
	currentPattern = ""
	
	def __init__(self,type, id, note):
		
		self.type = type
		self.id = id
		self.note = note
		self.read = [0] * BUFFER_SIZE
		self.max = 0
		self.timer = 0
		
		if (type == "FSR"):
			self.threshold = Sensor.fsr_threshold
		
		elif (type == "PIEZO"):
			self.threshold = Sensor.piezo_threshold
	
	
	def setValue(self, val = 0):
		self.read[Sensor.readIndex] = val
	
	
#	maps currRead to a color value
	def getColor(self):
		return (255, 255 - int(self.read[Sensor.readIndex] / 127 * 255), 0)
	
	def getMax(self):
		return np.max(self.read)
	
	def relMax(self, val):
		return int(np.max(self.read) / 127 * val)
	
FSR_SENSORS = [Sensor("FSR", i, FSR_NOTES[i]) for i in range(NUM_FSR)]
PIEZO_SENSORS = [Sensor("Piezo", i, PIEZO_NOTES[i]) for i in range(NUM_PIEZO)]
	
def incrementReadIndex():
	Sensor.readIndex = (Sensor.readIndex + 1) % BUFFER_SIZE

def setSensorValues():
	for sensor in FSR_SENSORS:
		sensor.setValue()
		
	for sensor in PIEZO_SENSORS:
		sensor.setValue()

def midiToSensor(m_e):
		for sensor in FSR_SENSORS:		
			if (m_e.data1 == sensor.note):
					sensor.setValue(m_e.data2)
						
		for sensor in PIEZO_SENSORS:
					
			if (m_e.data1 == sensor.note):
				sensor.setValue(m_e.data2)

def sendOSC(message):
	Sensor.log[Sensor.logIndex] = message
	Sensor.logTime[Sensor.logIndex] = Sensor.logIndex
	Sensor.logIndex = (Sensor.logIndex + 1) % 100
	
	if (not (Sensor.filteredLog[Sensor.filteredLogIndex][0:14] == message[0:14])):
		Sensor.filteredLogIndex = (Sensor.filteredLogIndex + 1) % 100
		Sensor.filteredLog[Sensor.filteredLogIndex] = message
		Sensor.filteredLogTime[Sensor.filteredLogIndex] = Sensor.logIndex
		
def sensorToLog():
	
	FSR_STATE = [0] * 8
	PIEZO_STATE = [0] * 4
	
	for i in range(NUM_FSR):
		
		if FSR_SENSORS[i].read[Sensor.readIndex] > 0:
			FSR_STATE[i] = 1
	
	for i in range(NUM_PIEZO):
		
		if PIEZO_SENSORS[i].read[Sensor.readIndex] > 0:
			PIEZO_STATE[i] = 1
	
			
	if (FSR_STATE[0] == 1 and FSR_STATE[1] == 1):
		sendOSC("PUBLIC GAUCHE")
		client.send_message("/FSR/GAUCHE", [100]) 
	elif (FSR_STATE[0] == 1 and FSR_STATE[1] == 0):
		sendOSC("PUBLIC GAUCHE GAUCHE")
		
	elif (FSR_STATE[0] == 0 and FSR_STATE[1] == 1):
		sendOSC("PUBLIC GAUCHE DROITE")
		
	elif (FSR_STATE[2] == 1 and FSR_STATE[3] == 1):
		sendOSC("PUBLIC DROITE")
		
	elif (FSR_STATE[2] == 1 and FSR_STATE[3] == 0):
		sendOSC("PUBLIC DROITE GAUCHE")
	
	elif (FSR_STATE[2] == 0 and FSR_STATE[3] == 1):
		sendOSC("PUBLIC DROITE DROITE")
		
	elif (FSR_STATE[4] == 1 and FSR_STATE[5] == 1):
		sendOSC("ARTISTE GAUCHE")
		
	elif (FSR_STATE[4] == 1 and FSR_STATE[5] == 0):
		sendOSC("ARTISTE GAUCHE GAUCHE")
		
	elif (FSR_STATE[4] == 0 and FSR_STATE[5] == 1):
		sendOSC("ARTISTE GAUCHE DROITE")
		
	elif (FSR_STATE[6] == 1 and FSR_STATE[7] == 1):
		sendOSC("ARTISTE DROITE")
		
	elif (FSR_STATE[6] == 1 and FSR_STATE[7] == 0):
		sendOSC("ARTISTE DROITE GAUCHE")
		
	elif (FSR_STATE[6] == 0 and FSR_STATE[7] == 1):
		sendOSC("ARTISTE DROITE DROITE")

def analysePattern():
	
	#detecter un droite gauche talon
	
	if(alternanceDouble("ARTISTE GAUCHE", "ARTISTE DROITE") or alternanceDouble("ARTISTE DROITE", "ARTISTE GAUCHE")):
		Sensor.currentPattern = "Alternance talon"
	
	elif(alternanceDouble("PUBLIC GAUCHE", "PUBLIC DROITE") or alternanceDouble("PUBLIC DROITE", "PUBLIC GAUCHE")):
		Sensor.currentPattern = "Alternance pointe"
		
	else:
		Sensor.currentPattern = ""
		
def alternanceDouble(t1, t2):
	
	c1 = Sensor.filteredLog[Sensor.filteredLogIndex][0:14] == t1
	c2 = Sensor.filteredLog[Sensor.filteredLogIndex - 1][0:14] == t2
	c3 = Sensor.filteredLog[Sensor.filteredLogIndex - 2][0:14] == t1
	c4 = Sensor.filteredLog[Sensor.filteredLogIndex - 3][0:14] == t2
	c5 = Sensor.filteredLog[Sensor.filteredLogIndex - 4][0:14] == t1
	c6 = Sensor.filteredLog[Sensor.filteredLogIndex - 5][0:14] == t2
	
	return (c1 and c2 and c3 and c4 and c5 and c6)