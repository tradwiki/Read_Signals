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

def filteredLogEntry(message):
	Sensor.log[Sensor.logIndex] = message
	Sensor.logTime[Sensor.logIndex] = Sensor.logIndex
	Sensor.logIndex = (Sensor.logIndex + 1) % 100
	
	if (not (Sensor.filteredLog[Sensor.filteredLogIndex][0:2] == message[0:2])):
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
	
			
#	if(PIEZO_STATE[0] == 1 and PIEZO_STATE[2] == 1):
#		sendOSC("PLEIN PIED GAUCHE")
#	
#	elif(PIEZO_STATE[1] == 1 and PIEZO_STATE[3] == 1):
#		sendOSC("PLEIN PIED DROIT")
			
	if (FSR_STATE[0] == 1 and FSR_STATE[1] == 1):
		filteredLogEntry("PG") 
		client.send_message("/PG/Moyenne", [(PIEZO_SENSORS[0].read[Sensor.readIndex] + PIEZO_SENSORS[1].read[Sensor.readIndex] )/ 2])
		client.send_message("/PG/G", [PIEZO_SENSORS[0].read[Sensor.readIndex]])
		client.send_message("/PG/D", [PIEZO_SENSORS[1].read[Sensor.readIndex]])
		
	elif (FSR_STATE[0] == 1 and FSR_STATE[1] == 0):
		filteredLogEntry("PG GAUCHE")
		client.send_message("/PG/G", [PIEZO_SENSORS[0].read[Sensor.readIndex]])
		
	elif (FSR_STATE[0] == 0 and FSR_STATE[1] == 1):
		filteredLogEntry("PG DROITE")
		client.send_message("/PG/D", [PIEZO_SENSORS[1].read[Sensor.readIndex]])
		
	elif (FSR_STATE[2] == 1 and FSR_STATE[3] == 1):
		filteredLogEntry("PD")
		client.send_message("/PD/Moyenne", [(PIEZO_SENSORS[2].read[Sensor.readIndex] + PIEZO_SENSORS[3].read[Sensor.readIndex]) / 2])
		client.send_message("/PD/G", [PIEZO_SENSORS[2].read[Sensor.readIndex]])
		client.send_message("/PD/D", [PIEZO_SENSORS[3].read[Sensor.readIndex]])
		
	elif (FSR_STATE[2] == 1 and FSR_STATE[3] == 0):
		filteredLogEntry("PD GAUCHE")
		client.send_message("/PD/G", [PIEZO_SENSORS[2].read[Sensor.readIndex]])
	
	elif (FSR_STATE[2] == 0 and FSR_STATE[3] == 1):
		filteredLogEntry("PD DROITE")
		client.send_message("/PD/D", [PIEZO_SENSORS[3].read[Sensor.readIndex]])
		
	elif (FSR_STATE[4] == 1 and FSR_STATE[5] == 1):
		filteredLogEntry("AG")
		client.send_message("/AG/Moyenne", [([PIEZO_SENSORS[4].read[Sensor.readIndex] + PIEZO_SENSORS[5].read[Sensor.readIndex]) / 2])
		client.send_message("/AG/G", [PIEZO_SENSORS[4].read[Sensor.readIndex])
		client.send_message("/AG/D", [PIEZO_SENSORS[4].read[Sensor.readIndex]])
		
	elif (FSR_STATE[4] == 1 and FSR_STATE[5] == 0):
		filteredLogEntry("AG GAUCHE")
		client.send_message("/AG/G", [PIEZO_SENSORS[4].read[Sensor.readIndex]])
		
	elif (FSR_STATE[4] == 0 and FSR_STATE[5] == 1):
		filteredLogEntry("AG DROITE")
		client.send_message("/AG/D", [PIEZO_SENSORS[5].read[Sensor.readIndex]])
		
	elif (FSR_STATE[6] == 1 and FSR_STATE[7] == 1):
		filteredLogEntry("AD")
		client.send_message("/ADee c /Moyenne", [(PIEZO_SENSORS[4].read[Sensor.readIndex] + PIEZO_SENSORS[5].read[Sensor.readIndex]) / 2])
		client.send_message("/AD/G", [PIEZO_SENSORS[4].read[Sensor.readIndex]])
		client.send_message("/AD/D", [PIEZO_SENSORS[5].read[Sensor.readIndex]])
		
	elif (FSR_STATE[6] == 1 and FSR_STATE[7] == 0):
		filteredLogEntry("AD GAUCHE")
		client.send_message("/AD/G", [PIEZO_SENSORS[4].read[Sensor.readIndex]])
		
	elif (FSR_STATE[6] == 0 and FSR_STATE[7] == 1):
		filteredLogEntry("AD DROITE")
		client.send_message("/AD/D", [PIEZO_SENSORS[5].read[Sensor.readIndex]])
		
def analysePattern():
	
	if (findPattern(4)):
		Sensor.currentPattern = "4 temps"
		
	elif (findPattern(3)):
		Sensor.currentPattern = "3 temps"
		
	elif (findPattern(2)):
		Sensor.currentPattern = "2 temps"
	
	else:
		Sensor.currentPattern = ""		

def findPattern(n):
	pattern = [""] * n
	for i in range(n):
		pattern[i] = Sensor.filteredLog[Sensor.filteredLogIndex - i]
		
	for i in range(n * 3):
		
		if (not (Sensor.filteredLog[Sensor.filteredLogIndex - i][0:2] == Sensor.filteredLog[Sensor.filteredLogIndex - (i % n)][0:2])):
			return False
	
	if (n == 4):
		if (Sensor.filteredLog[Sensor.filteredLogIndex] == Sensor.filteredLog[Sensor.filteredLogIndex - 2] and Sensor.filteredLog[Sensor.filteredLogIndex - 1] == Sensor.filteredLog[Sensor.filteredLogIndex - 3]):
			return False
	return True
		
def sendOsc(adress, data):
	print(adress)
	