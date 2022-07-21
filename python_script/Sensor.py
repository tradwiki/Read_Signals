#!/usr/bin/env python3
import numpy as np
import time
from pythonosc.udp_client import SimpleUDPClient

BUFFER_SIZE = 100

NUM_FSR = 8
NUM_PIEZO = 4
NUM_PAD = 4
FSR_NOTES = [74, 76, 78, 79, 81, 83, 85, 86]
PIEZO_NOTES = [100, 101, 102, 103]

FSR_REF = ["/FSR/PG", "/FSR/PG", "/FSR/PD", "/FSR/PD", "/FSR/AG", "/FSR/AG", "/FSR/AD", "/FSR/AD"]
PIEZO_REF = ["/PIEZO/PG", "/PIEZO/PD", "/PIEZO/AG", "/PIEZO/AD"]

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
	currPatternType = ""
	currTempo = 0
	currPattern = ""
	prevPadState = [False] * NUM_PAD
	
	
	def __init__(self,type, id, note, ref):
		
		self.type = type
		self.id = id
		self.note = note
		self.read = [0] * BUFFER_SIZE
		self.max = 0
		self.timer = 0
		self.ref = ref
		self.state = False
		
		if (type == "FSR"):
			self.threshold = Sensor.fsr_threshold
		
		elif (type == "PIEZO"):
			self.threshold = Sensor.piezo_threshold
	
	
	def setValue(self, val = 0):
		self.read[Sensor.readIndex] = val
		
		if not (self.state == (self.read[Sensor.readIndex] > 0)):
			self.state = not self.state
			
			if (not self.state):
				self.sendOSC()
			print(str(id) + " is now ")
			print(self.state)
	
	
#	maps currRead to a color value
	def getColor(self):
		return (255, 255 - int(self.read[Sensor.readIndex] / 127 * 255), 0)
	
	def getMax(self):
		return np.max(self.read)
	
	def relMax(self, val):
		return int(np.max(self.read) / 127 * val)
	
	def sendOSC(self):
		if ((self.id % 2) == 0):
			client.send_message(self.ref, [self.read[Sensor.readIndex], 0])
		else:
			client.send_message(self.ref, [0, self.read[Sensor.readIndex]])


FSR_SENSORS = [Sensor("FSR", i, FSR_NOTES[i], FSR_REF[i]) for i in range(NUM_FSR)]
PIEZO_SENSORS = [Sensor("Piezo", i, PIEZO_NOTES[i], PIEZO_REF[i]) for i in range(NUM_PIEZO)]
	
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

def filteredLogEntry(message, n):
	
	if (not Sensor.prevPadState[n]):
		Sensor.filteredLogIndex = (Sensor.filteredLogIndex + 1) % 100
		Sensor.filteredLog[Sensor.filteredLogIndex] = message
		Sensor.filteredLogTime[Sensor.filteredLogIndex] = Sensor.logIndex
		
	Sensor.log[Sensor.logIndex] = message
	Sensor.logTime[Sensor.logIndex] = Sensor.logIndex
	Sensor.logIndex = (Sensor.logIndex + 1) % 100
	
def sensorToLog():
	
	FSR_STATE = [0] * 8
	PIEZO_STATE = [0] * 4
	
	for i in range(NUM_FSR):
		
		if FSR_SENSORS[i].read[Sensor.readIndex] > 0:
			FSR_STATE[i] = 1
	
	for i in range(NUM_PIEZO):
		
		if PIEZO_SENSORS[i].read[Sensor.readIndex] > 0:
			PIEZO_STATE[i] = 1
			PIEZO_SENSORS[i].sendOSC()
	
			
#	if(PIEZO_STATE[0] == 1 and PIEZO_STATE[2] == 1):
#		sendOSC("PLEIN PIED GAUCHE")
#	
#	elif(PIEZO_STATE[1] == 1 and PIEZO_STATE[3] == 1):
#		sendOSC("PLEIN PIED DROIT")
			
	if (FSR_STATE[0] == 1 and FSR_STATE[1] == 1):
		filteredLogEntry("PG", 0)
		client.send_message("/FSR/PG", [FSR_SENSORS[0].read[Sensor.readIndex], FSR_SENSORS[1].read[Sensor.readIndex]])
		
	elif (FSR_STATE[0] == 1 and FSR_STATE[1] == 0):
		filteredLogEntry("PG GAUCHE", 0)
		FSR_SENSORS[0].sendOSC()
		
	elif (FSR_STATE[0] == 0 and FSR_STATE[1] == 1):
		filteredLogEntry("PG DROITE", 0)
		FSR_SENSORS[1].sendOSC()
		
	elif (FSR_STATE[2] == 1 and FSR_STATE[3] == 1):
		filteredLogEntry("PD", 1)
		client.send_message("/FSR/PD",[FSR_SENSORS[2].read[Sensor.readIndex], FSR_SENSORS[3].read[Sensor.readIndex]])
		
	elif (FSR_STATE[2] == 1 and FSR_STATE[3] == 0):
		filteredLogEntry("PD GAUCHE", 1)
		FSR_SENSORS[2].sendOSC()
	
	elif (FSR_STATE[2] == 0 and FSR_STATE[3] == 1):
		filteredLogEntry("PD DROITE", 1)
		FSR_SENSORS[3].sendOSC()
		
	elif (FSR_STATE[4] == 1 and FSR_STATE[5] == 1):
		filteredLogEntry("AG", 2)
		client.send_message("/FSR/AG",[FSR_SENSORS[4].read[Sensor.readIndex], FSR_SENSORS[5].read[Sensor.readIndex]])
		
	elif (FSR_STATE[4] == 1 and FSR_STATE[5] == 0):
		filteredLogEntry("AG GAUCHE", 2)
		FSR_SENSORS[4].sendOSC()
		
	elif (FSR_STATE[4] == 0 and FSR_STATE[5] == 1):
		filteredLogEntry("AG DROITE", 2)
		FSR_SENSORS[5].sendOSC()
		
	elif (FSR_STATE[6] == 1 and FSR_STATE[7] == 1):
		filteredLogEntry("AD", 3)
		client.send_message("/FSR/AD",[FSR_SENSORS[6].read[Sensor.readIndex], FSR_SENSORS[7].read[Sensor.readIndex]])
		
	elif (FSR_STATE[6] == 1 and FSR_STATE[7] == 0):
		filteredLogEntry("AD GAUCHE", 3)
		FSR_SENSORS[6].sendOSC()
		
	elif (FSR_STATE[6] == 0 and FSR_STATE[7] == 1):
		filteredLogEntry("AD DROITE", 3)
		FSR_SENSORS[7].sendOSC()
	
	for i in range(NUM_PAD):
		Sensor.prevPadState[i] = False
		if (FSR_STATE[i * 2] or FSR_STATE[i * 2 + 1]):
			Sensor.prevPadState[i] = True
		
def analysePattern():
	
	if (findPattern(4)):
		Sensor.currPatternType = "4 temps"
		
	elif (findPattern(3)):
		Sensor.currPatternType = "3 temps"
		
	elif (findPattern(2)):
		Sensor.currPatternType = "2 temps"
	
	else:
		Sensor.currentPatternType = ""		

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
	
	Sensor.currPattern = ""
	
	for i in range(n):
		Sensor.currPattern += Sensor.filteredLog[Sensor.filteredLogIndex - i][0:2]
		Sensor.currPattern += "-"
	Sensor.currPattern = Sensor.currPattern[0:(len(Sensor.currPattern) -1)]
	
	if ((Sensor.filteredLogTime[Sensor.filteredLogIndex] - Sensor.filteredLogTime[Sensor.filteredLogIndex - (n * 3)]) > 0):
		Sensor.currTempo = (n * n  * 3 * 60) / (Sensor.filteredLogTime[Sensor.filteredLogIndex] - Sensor.filteredLogTime[Sensor.filteredLogIndex - (n * 3)])
	return True
		
def sendOsc(adress, data):
	print(adress)
	