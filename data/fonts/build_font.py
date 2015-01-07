#!/usr/bin/python

# code to generate all glyphs from a given font
# glyphs are from 32 (space) to 126

import pygame, os, shutil, sys

SIZE = 0
GLYPH_START = 32
GLYPH_END = 126
FONT = ''

def makeFilename():
	return(FONT.split('.')[0] + '.png')

def buildFont():
	filename = makeFilename()
	pygame.init()
	font = pygame.font.Font('anonymouspro.ttf', SIZE)
	letters = []
	for i in range(GLYPH_START, GLYPH_END + 1):
		letters.append(font.render(chr(i), True, (255, 255, 255)))
	# from experimentation, some are maybe 1 or 2 pixels larger (depends on size)
	# we just use the smallest.
	width = min([x.get_width() for x in letters])
	height = min([x.get_height() for x in letters])
	base_image = pygame.Surface(((GLYPH_END - GLYPH_START) * width, height), pygame.SRCALPHA, 32)
	xpos = 0
	for i in letters:
		base_image.blit(i, (xpos, 0))
		xpos += width
	pygame.image.save(base_image, filename)
	print 'Saved as ' + filename

def parseArgs(args):
	global FONT, SIZE

	# args[1] must be a string of type XXX.ttf, and must exist
	if(args[1].split('.')[1].lower() != 'ttf'):
		print 'Error: First argument must be a ttf font'
		return(False)
	# args 2 must be integer > 0
	if(args[2].isdigit() == False):
		print 'Error: Second argument must be a number'
		return(false)
	SIZE = int(args[2])
	if(SIZE == 0):
		print 'Error: Second argument cannot be 0'
		return(False)
	FONT = args[1]
	return(True)

if __name__ == '__main__':
	# get the fontname and size from command line
	if(len(sys.argv) != 3):
		print 'Builds png of fixed width fonts'
		print '    Ex: build_font.py my_font.ttf size'
	elif(parseArgs(sys.argv) == True):
		buildFont()

