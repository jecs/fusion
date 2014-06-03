from scipy.ndimage import imread
from numpy import arange
from scipy.misc import imsave
from scipy.misc import lena
import numpy

def convert2gray(img_name, coe_name):
	img = imread(img_name, flatten=True)
	img = numpy.uint8(img)
	print "img dtype=%s" % (img.dtype,)
	coe = open(coe_name, 'w')
	
	radix = 16
	(M, N) = img.shape
	
	coe.write('memory_initialization_radix=%d;\n' % (radix))
	coe.write('memory_initialization_vector=\n')
	
	for m in arange(M):
		for n in arange(N):
			hex_str = '%X' % (img[m, n],)
			if len(hex_str) == 1:
				hex_str = '0'+hex_str
				
			coe.write(hex_str)
			if(n != N-1):
				coe.write(', ')
			elif(m != M-1):
				coe.write(',\n');
			else:
				coe.write(';\n');

	coe.close()
	
if __name__ == '__main__':
	lena = lena()
	imsave('lena.png', lena)
	
	convert2gray('lena.png', 'lena.coe')
	