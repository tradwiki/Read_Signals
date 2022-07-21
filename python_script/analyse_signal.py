#!/usr/bin/env python
"""
Script python transformant le signal MIDI de la planche de Podorythmie 5 à un signal OSC.
Les signaux Midi sont interpretés afin de générer des signaux complexs

NOTES:
74 : PUBLIC GAUCHE GAUCHE
76 : PUBLIC GAUCHE DROITE
81 : PUBLIC DROITE GAUCHE
83 : PUBLIC DROITE DROITE
85 : ARTISTE GAUCHE GAUCHE
86 : ARTISTE GAUCHE DROITE
79 : ARTISTE DROITE GAUCHE
78 : ARTISTE DROITE DROITE


"""
import sys
import os
import time

import pygame as pg
import pygame.midi

import pythonosc.udp_client

from Sensor import *
from display import *


def print_device_info():
    pygame.midi.init()
    _print_device_info()
    pygame.midi.quit()
    
    
def _print_device_info():
    for i in range(pygame.midi.get_count()):
        r = pygame.midi.get_device_info(i)
        (interf, name, input, output, opened) = r
        
        in_out = ""
        if input:
            in_out = "(input)"
        if output:
            in_out = "(output)"
            
        print(
            "%2i: interface :%s:, name :%s:, opened :%s:  %s"
            % (i, interf, name, opened, in_out)
        )
        
        
def input_main(device_id=None):
    pg.init()
    pg.fastevent.init()
    event_get = pg.fastevent.get
    event_post = pg.fastevent.post
    
    pygame.midi.init()
    
    _print_device_info()
    
    if device_id is None:
        input_id = pygame.midi.get_default_input_id()
    else:
        input_id = device_id
        
    print("using input_id :%s:" % input_id)
    midi_input = pygame.midi.Input(input_id)

    running = True
    while running:
        events = event_get()
        for e in events:
            if e.type in [pg.QUIT]:
                running = False
            if e.type in [pg.KEYDOWN]:
                
                if (e.key == pg.K_ESCAPE):
                    running = False
                
                elif (e.key == pg.K_SPACE):
                    for sensor in FSR_SENSORS:
                        print(alternanceTriple())
                        
            if e.type in [pygame.midi.MIDIIN]:
                print(e)
        
#       default sensors to 0 if there is no midi signal
        setSensorValues()
                
        if midi_input.poll():
            midi_events = midi_input.read(10)
            midi_evs = pygame.midi.midis2events(midi_events, midi_input.device_id)
            
            
            for m_e in midi_evs:
                midiToSensor(m_e)
                    
                        
    
                    
        screen.fill((0, 0, 0))
        drawBoard(20, 20)
        drawGraph(380, 20)
        sensorToLog()
        showLog()
        analysePattern()
        pg.display.update()
        time.sleep(0.01)
        incrementReadIndex()
        
        
    del midi_input
    pygame.midi.quit()
    
input_main(1)


