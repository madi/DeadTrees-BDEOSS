__author__ = "Laura Martinez Sanchez, Margherita Di Leo"
__license__ = "GPL v.3"
__version__ = "3.0"
__email__ = "lmartisa@gmail.com, dileomargherita@gmail.com"


from mlh import *
from serialize import *
from movingwindow import *
import os
import sys
import argparse
import re

parser = argparse.ArgumentParser(description = "Performs prediction")
parser.add_argument('--orthoPath', dest = "orthoPath",
                                 help = "Input Path for the original tile to process")
parser.add_argument('--texturePath', dest = "texturePath",
                                 help = "Input Path for the textures")
parser.add_argument('--resultPath', dest = "resultPath",
                                 help = "Output Path")
parser.add_argument('--InputFile', dest = "InputFile",
                                 help = "InputFile name to be processed")

args = parser.parse_args()

orthoPath   = args.orthoPath
texturePath = args.texturePath
resultPath  = args.resultPath
inputFile   = args.inputFile


feat = defaultdict(list)

count = 0
picklemodel = "modelKNN"
model = read("pickle/model/" + str(picklemodel))


Classifier = ImageClassifier(modeltype = 2, \
                             Threads = 4, \
                             picklemodel = picklemodel, \
                             model = model)

# for file in os.listdir(orthoPath):
#     if file.endswith(".tif"):
#         file = os.path.splitext(file)[0]

file1 = os.path.join(orthoPath, InputFile)
file = os.path.splitext(InputFile)[0]

Classifier.ImageToClassify(file1, True, texturePath)

Classifier.Classify()
Classifier.SaveImg(resultPath + str(file) + "_classified")

imgResult = moviw(Classifier.GetClassified(), \
                        resultPath + str(file) + "_smooth", \
                        Classifier.GetProjection(), \
                        Classifier.GetGeotrans())

# print "imgResult", imgResult
