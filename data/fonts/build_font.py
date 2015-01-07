#!/usr/bin/python

# code to generate all glyphs from a given font
# glyphs are from 32 (space) to 126

import pygame, os, shutil, sys

SIZE = 0
GLYPH_START = 32
GLYPH_END = 126
FONT = ''

def makeFolder():
	name = FONT.split('.')[0] + '_bitmap'
	# delete if exists and make
	shutil.rmtree(name)
	os.mkdir(name)
	return(name)

def buildFont():
	folder = makeFolder()
	pygame.init()
	font = pygame.font.Font('anonymouspro.ttf', SIZE)
	letters = []
	for i in range(GLYPH_START, GLYPH_END + 1):
		image = font.render(chr(i), True, (255, 255, 255))
		letters.append(str(image.get_width()) + ':' + str(image.get_height()))
		# save the image
		pygame.image.save(image, folder + '/' + 'glyph' + str(i) + '.png')
	unique = set(letters)
	# how many?
	print 'Size, Total Glyphs:'
	for i in unique:
		print ' ', i, letters.count(i)
		# print glyphs if not too large
		if(letters.count(i) < 3):
			counts = [x for x, j in enumerate(letters) if j == i]
			for i in counts:
				print '    ' + chr(i + GLYPH_START) + ' - chr(' + str(i + GLYPH_START) + ')'
	print 'Saved in ./' + folder

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
		print 'Usage: build_font.py fontname size'
		print '   Ex: build_font.py my_font.ttf 132'
	elif(parseArgs(sys.argv) == True):
		buildFont()

