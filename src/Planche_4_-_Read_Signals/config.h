#pragma once
const bool DEBUG = false;
const bool FSR_DEBUG = true;
const bool PIEZO_DEBUG = true;
const bool MIDI_RECEIVE_DEBUG = true;

const int BAUD_RATE = 9600;
const int MIDI_CHANNEL = 1;
bool WITH_MIDI_INPUT = true;
bool WITH_MIDI_OUTPUT = true;


const unsigned long MICROSECOND = 1;
const unsigned long MILLISECOND = 1000;
const unsigned long SECOND = 1000000;
const int PRINT_DELAY = 50 * MICROSECOND;

const int LED_PIN = 13;

// FSR VALUES
const bool READ_RESISTANCE = true;
const static int NUM_FSR_SENSORS = 8;
const int FSR_SENSOR_PINS[] = {25, 26, 27, 39, 15, 16, 17, 18};
const int FSR_NOTES[] = {74, 76, 81, 83, 85, 86, 79, 78};

// FSR thresholds
const int FSR_MAX_READING = 1023;
const int FSR_MIN_THRESHOLD = 100;
const int FSR_MAX_THRESHOLD = 150;
const int FSR_MIN_JUMPING_RANGE = 80;

// FSR CONST
static const int BASELINE_BUFFER_SIZE = 400;
unsigned const long NOTE_VELOCITY_DELAY = 2 * MILLISECOND;
unsigned const long NOTE_ON_DELAY = 50 * MILLISECOND;
unsigned const long NOTE_OFF_DELAY = 50 * MILLISECOND;
unsigned const long SUSTAIN_DELAY = 100 * MILLISECOND;
unsigned const long BASELINE_SAMPLE_DELAY = 0.5 * MILLISECOND;
unsigned const long BASELINE_BLOWBACK_DELAY = 40 * MILLISECOND;
const int RETRO_JUMP_BLOWBACK_SAMPLES = (0.5 * MILLISECOND) / BASELINE_SAMPLE_DELAY;
const int MAX_CONSECUTIVE_SUSTAINS = (10 * SECOND) / SUSTAIN_DELAY;


// PIEZO VALUES
const static int NUM_PIEZO_SENSORS = 4;
const int PIEZO_SENSOR_PINS[] = {24, 19, 40, 41};
const int PIEZO_NOTES[] = {100, 101, 102, 103};
const int MAX_PIEZO_TIME = 10;

// MOTOR VALUES
const int TAPS_PER_PULSE = 1;
const bool WITH_MOTORS = true;
const int NUM_MOTORS = 2;
const int MOTOR_PINS[NUM_MOTORS] = {1, 2};
const int SENSOR_TO_MOTOR[] = {1, 1, -1, -1, -1, -1, -1, -1};
const int MOTOR_NOTES[2][2] = {{74, 76}, {79, 78}};
unsigned const long MAX_MOTOR_PULSE_DURATION = 400 * MILLISECOND;
unsigned const long MAX_MOTOR_PULSE_BREAK = 400 * MILLISECOND;
const int MOTOR_THRESHOLD = 20;

//External Midi
unsigned long lastExternalMidiOn[NUM_FSR_SENSORS];
