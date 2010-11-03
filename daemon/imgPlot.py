'''
Created on 23 oct. 2010

@author: maximeboucher
'''
import Image, StringIO
import matplotlib
import base64
matplotlib.use('Agg')
import matplotlib.pyplot as plt

class imgPlot:

    def __init__(self):
        self.imgdata = StringIO.StringIO()
        self.fig = plt.figure()

    
    def getPlot(self):
        self.fig.savefig(self.imgdata, format='png')
        self.imgdata.seek(0)
        return 'data:image/gif;base64,'+base64.b64encode(self.imgdata.getvalue())
