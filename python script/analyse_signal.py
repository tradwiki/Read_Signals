#!/usr/bin/env python
"""
Script python transformant le signal MIDI de la planche de Podorythmie 5 à un signal OSC.
Les signaux Midi sont interpretés afin de générer des signaux complexs
"""
import sys
import os
import time

import pygame as pg
import pygame.midi

from Sensor import *

IP = "127.0.0.1"
PORT = "5005"

NUM_FSR = 8
NUM_PIEZO = 4
FSR_NOTES = [74, 76, 81, 83, 85, 86, 79, 78]
PIEZO_NOTES = [100, 101, 102, 103]

FSR_SENSORS = [Sensor("FSR", i, FSR_NOTES[i]) for i in range(NUM_FSR)]
PIEZO_SENSORS = [Sensor("Piezo", i, PIEZO_NOTES[i]) for i in range(NUM_PIEZO)]

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
    
    pg.display.set_mode((1, 1))
    
    running = True
    while running:
        events = event_get()
        for e in events:
            if e.type in [pg.QUIT]:
                running = False
            if e.type in [pg.KEYDOWN]:
                running = False
            if e.type in [pygame.midi.MIDIIN]:
                print(e)
                
                
                
        if midi_input.poll():
            midi_events = midi_input.read(10)
            midi_evs = pygame.midi.midis2events(midi_events, midi_input.device_id)
            
            for m_e in midi_evs:
                event_post(m_e)
                
        print('X')
        time.sleep(0.5)
        
    del midi_input
    pygame.midi.quit()
    
input_main(1)