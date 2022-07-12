import pygame as pg
from Sensor import *

pg.init()
pg.font.init()

screenH = 640
screenW = 640
screen = pg.display.set_mode([screenW, screenH])

# COLORS
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
RED = (255, 0, 0)
GREEN = (0, 127, 0)

# FONT
BIG_FONT = pg.font.SysFont("menlo", 20)
SMALL_FONT = pg.font.SysFont("menlo", 14)

def drawBoard(x, y):
  pg.draw.rect(screen, WHITE, pg.Rect(x, y, 300, 300), 1)
  pg.draw.line(screen, WHITE, [x, y + 150], [x + 300, y + 150], 2)
  pg.draw.rect(screen, BLACK, pg.Rect(x + 125, y, 50, 300))
  pg.draw.rect(screen, WHITE, pg.Rect(x + 125, y, 50, 300), 1)
  
  
  pg.draw.rect(screen, FSR_SENSORS[0].getColor(), pg.Rect(x + 10, y + 15, 40, 40))
  pg.draw.rect(screen, FSR_SENSORS[1].getColor(), pg.Rect(x + 75, y + 15, 40, 40))
  pg.draw.rect(screen, FSR_SENSORS[2].getColor(), pg.Rect(x + 185, y + 15, 40, 40))
  pg.draw.rect(screen, FSR_SENSORS[3].getColor(), pg.Rect(x + 250, y + 15, 40, 40))
  
  pg.draw.rect(screen, FSR_SENSORS[4].getColor(), pg.Rect(x + 10, y + 245, 40, 40))
  pg.draw.rect(screen, FSR_SENSORS[5].getColor(), pg.Rect(x + 75, y + 245, 40, 40))
  pg.draw.rect(screen, FSR_SENSORS[6].getColor(), pg.Rect(x + 185, y + 245, 40, 40))
  pg.draw.rect(screen, FSR_SENSORS[7].getColor(), pg.Rect(x + 250, y + 245, 40, 40))
  
  pg.draw.circle(screen, PIEZO_SENSORS[0].getColor(), [x + 238, y + 80], 15)
  pg.draw.circle(screen, PIEZO_SENSORS[1].getColor(), [x + 63, y + 80], 15)
  pg.draw.circle(screen, PIEZO_SENSORS[2].getColor(), [x + 63, y + 220], 15)
  pg.draw.circle(screen, PIEZO_SENSORS[3].getColor(), [x + 238, y + 220], 15)
  

def drawGraph(x, y):
  
  drawBar(x, y, FSR_SENSORS[0])
  drawBar(x + 30, y, PIEZO_SENSORS[0])
  drawBar(x + 60, y, FSR_SENSORS[1])
  drawBar(x + 120, y, FSR_SENSORS[2])
  drawBar(x + 150, y, PIEZO_SENSORS[1])
  drawBar(x + 180, y, FSR_SENSORS[3])
  
  drawBar(x, y + 173, FSR_SENSORS[4])
  drawBar(x + 30, y + 173, PIEZO_SENSORS[2])
  drawBar(x + 60, y + 173, FSR_SENSORS[5])
  drawBar(x + 120, y + 173, FSR_SENSORS[6])
  drawBar(x + 150, y + 173, PIEZO_SENSORS[3])
  drawBar(x + 180, y + 173, FSR_SENSORS[7])


def drawBar(x, y, s):
  pg.draw.rect(screen, WHITE, pg.Rect(x, y, 20, 127), 1)
  pg.draw.rect(screen, WHITE, pg.Rect(x, y + 127 - s.read[Sensor.readIndex], 20, s.read[Sensor.readIndex]))
  pg.draw.line(screen, RED, [x, y + 127 - s.relMax(127)], [x + 20, y + 127 - s.relMax(127)], 2)
  
def showLog():
  
  pg.draw.rect(screen, WHITE, pg.Rect(20, 350, 600, 250), 1)
  
  pg.draw.rect(screen, WHITE, pg.Rect(20, 350, 600, 50), 1)
  text = BIG_FONT.render("ACTION LOG", True, WHITE)
  screen.blit(text, (30, 360))
  
  for i in range(10):
    text = SMALL_FONT.render(str(Sensor.filteredLogTime[Sensor.filteredLogIndex - i]) + ": " + Sensor.filteredLog[Sensor.filteredLogIndex - i], True, WHITE)
    screen.blit(text, (30, 400 + 20 * i))
  
  text = BIG_FONT.render("pattern: ", True, WHITE)
  screen.blit(text, (250, 400))
  text = BIG_FONT.render(Sensor.currentPattern, True, WHITE)
  screen.blit(text, (250, 420))
  