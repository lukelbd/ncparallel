# Compile the mppnccombine tool
# Edit these flags as needed for your system
CPP = pgcc
LIBS = -lnetcdff -lnetcdf -lhdf5 -lhdf5_hl -lm  # include netcdf libs and math lib
LIBPATH = -L/usr/lib64/mpich/lib
INCPATH = -I/usr/include/mpich-x86_64

.PHONY: clean

mppnccombine.x: mppnccombine.c
	$(CPP) -O -o mppnccombine.x $(LIBPATH) $(INCPATH) $(LIBS) mppnccombine.c

clean:
	rm mppnccombine.x
