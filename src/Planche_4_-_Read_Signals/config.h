#pragma once
const bool DEBUG = false;
const bool FSR_DEBUG = false;

const int BAUD_RATE = 9600;
const int MIDI_CHANNEL = 1;

const unsigned long MICROSECOND = 1;
const unsigned long MILLISECOND = 1000;
const unsigned long SECOND = 1000000;
const int PRINT_DELAY = 50 * MICROSECOND;

const int LED_PIN = 13;

// FSR VALUES
const bool READ_RESISTANCE = true;
const static int NUM_FSR_SENSORS = 8;
const int FSR_SENSORS_PINS[] = {25, 26, 27, 39, 15, 16, 17, 18};
const int FSR_NOTES[] = {74, 76, 81, 83, 85, 86, 79, 78, 10, 11, 12, 13};

// MOTOR VALUES
const int TAPS_PER_PULSE = 1;
const bool WITH_MOTORS = true;
const int NUM_MOTORS = 2;
const int MOTOR_PINS[NUM_MOTORS] = {1, 2};
const int SENSOR_TO_MOTOR[] = {1, 1, -1, -1, -1, -1, 0, 0};
unsigned const long MAX_MOTOR_PULSE_DURATION = 400 * MILLISECOND;
