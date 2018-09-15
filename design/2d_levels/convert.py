import sys
import pygame
import xml.etree.ElementTree as ET

# example of loading data from an svg file


class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __eq__(self, other):
        if self.x == other.x and self.y == other.y:
            return True
        return False


class Path:
    def __init__(self, points):
        self.points = points
        self.normalise()

    def normalise(self):
        # find the smallest x and y, adjust them to zero,
        # and do the same for the rest
        # also convert points to integers
        min_x = min([x.x for x in self.points])
        min_y = min([x.y for x in self.points])
        for i in self.points:
            i.x = int(i.x - min_x)
            i.y = int(i.y - min_y)

    def getResize(self, size):
        largest_size = max([self.width, self.height])
        ratio = size / largest_size
        converted = []
        for i in self.points:
            converted.append([i.x * ratio, i.y * ratio])
        return converted

    @property
    def width(self):
        return max([x.x for x in self.points])

    @property
    def height(self):
        return max([x.x for x in self.points])

    @property
    def closed(self):
        if len(self.point) == 0:
            return False
        # loop of 1 elements is always closed
        return self.points[0] == self.points[-1]

    def __repr__(self):
        point_string = ['[{0},{1}]'.format(x.x, x.y) for x in self.points]
        return '->'.join(point_string)


def die(message='Unknown'):
    """Helper function to print error and quit"""
    print('  Error: {0}'.format(message))
    sys.exit(False)


def loadRawXML(filename):
    try:
        xml_file = open(filename)
        xml_data = xml_file.read()
    except Exception as e:
        die(str(e))
    print('  * Loaded {0}'.format(filename))
    return xml_data


def getAllPaths(xml_string):
    try:
        root = ET.fromstring(xml_string)
    except Exception as e:
        die(str(e))
    print('  * Converted data from XML')
    return root.findall('{http://www.w3.org/2000/svg}g')


def stringToPath(string):
    # this is the string given to from the element
    # split by spaces and igmore opening 'm' character
    point_text = string.split()[1:]
    points = []
    for p in point_text:
        data = p.split(',')
        if len(data) != 2:
            # could be l or m for now. Ignore these
            continue
        points.append(Point(float(data[0]), float(data[1])))
    return Path(points)


def convertAllPaths(paths):
    converted_paths = []
    for path in paths:
        # each path is an xml element
        # we are only interested in the 'd' element
        path_detail = path.find('{http://www.w3.org/2000/svg}path')
        if path_detail is None:
            die('No path in element {0}'.format(path))
        if 'd' not in path_detail.attrib:
            dir('Missing path data in element {0}'.format(path))
        converted_paths.append(stringToPath(path_detail.attrib['d']))
    return converted_paths


def drawPaths(paths):
    pygame.init()
    screen = pygame.display.set_mode((400, 400))
    # now draw to the screen
    screen.fill((0, 0, 0))
    for i in paths:
        points = i.getResize(400)
        # start at point 1, continue
        start = points[0]
        for i in points[1:]:
            pygame.draw.line(screen, (255, 255, 255), start, i)
            start = i
    pygame.display.flip()
    while True:
        for event in pygame.event.get():
            # listening for the the X button at the top
            if event.type == pygame.QUIT:
                break
    pygame.quit()


if __name__ == '__main__':
    data = loadRawXML('drawing.svg')
    xml_data = getAllPaths(data)
    paths = convertAllPaths(xml_data)
    drawPaths(paths)
    print('  * Done')
