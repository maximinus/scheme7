import sys

# example of loading data from an svg file


def die(message='Unknown'):
    print('  Error: {0}'.format(message))
    sys.exit(False)


def loadRawXML(filename):
    try:
        xml_file = open(filename)
        xml_data = xml_file.read()
    except Exception as e:
        die(str(e))
    return xml_data


if __name__ == '__main__':
    data = loadRawXML()
    print('  Done')
