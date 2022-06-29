#!/usr/bin/env python3

BUFFER_SIZE = 100

class  Sensor:
	
	fsr_threshold = 100
	piezo_threshold = 100
	readIndex = 0
	
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
	
	
