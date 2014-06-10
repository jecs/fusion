import math

f_system = 62.0e6
desired_f_v = 60.0

N = 500
E = [0]*N
M = [0]*N
fv = [0.0]*N
bw = [0]*N

for k in range(0, N):
	M[k] = k+1
	E[k] = int(round(f_system / (M[k] * desired_f_v)))
	fv[k] = f_system/(E[k]*M[k])
	bw[k] = int(math.ceil(math.log(E[k], 2)))

A = filter(lambda x: x[3] <= 16, zip(M, E, fv, bw))

def comparison(x,y):
	if x < y:
		return -1
	elif x > y:
		return 1
	else:
		return 0

A = sorted(A, cmp=lambda x, y: comparison(abs(60-x[2]), abs(60-y[2])))

for a in A:
	print "%d\t%d\t%f\t%d" % a
