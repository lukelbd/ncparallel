# Compile the mppnccombine tool
# Edit these flags as needed for your system
CPP = 'pgcc'
INCLUDE = '-I/usr/include/mpich-x86_64'
LIBS = '-lnetcdff -lnetcdf -lhdf5 -lhdf5_hl'  # include netcdf libs

.PHONY: clean

mppnccombine.x: mppnccombine.c
	$(CPP) -O -o mppnccombine.x $(INCLUDE) $(LIBS) $(NCFLAGS) mppnccombine.c

clean:
	rm mppnccombine.x
