#!/usr/bin/python

import sys

# tile descriptions for all the tiles
# all points numbered 0-3 are just points on the rectangle

# 0: top left, 1: top right, 2: bottom right. 3: bottom left

SIZES = [[0,0], [1,0], [1,1], [0,1]]

TILES_1x1 = [[0,1,2,3], [0,2,3], [0,1,3], [0,1,2], [1,2,3]]

#TILES_1x2 = [[0,1,2], [1,2,3], [3,1,2], [0,2,3]]
TILES_1x2 = [[0,1,2], [1,2,3], [0,1,3], [0,2,3]]

TILES_2x1 = [[0,2,3], [1,2,3], [0,1,2], [0,1,3]]

# no in a simple format: [width, height], [tiles]

ALL_TILES = [[[1,1], TILES_1x1],
			 [[1,2], TILES_1x2],
			 [[2,1], TILES_2x1],
			]

def convertTileSizes(width, height, tiles):
	new_tiles = []
	for i in tiles:
		points = []
		for j in i:
			# each j is one point			
			points.append([SIZES[j][0] * width, SIZES[j][1] * height])
		new_tiles.append(points)
	return(new_tiles)

# some helper functions
def getTilesetMatch(width, height):
	for i in ALL_TILES:
		if((width == i[0][0]) and (height == i[0][1])):
			# return the array of values
			# convert array to sizes and return
			return(convertTileSizes(i[0][0], i[0][1], i[1]))
	# no tie, kill with error
	print 'Error: No matching tileset'
	sys.exit()

