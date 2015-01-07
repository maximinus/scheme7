#!/usr/bin/python

# code to generate all glyphs from a given font
# glyphs are from 32 (space) to 126

import pygame

SIZE = 120

def buildFont():
	pygame.init()
	font = pygame.font.Font('anonymouspro.ttf', SIZE)

if __name__ == '__main__':
	buildFont();

