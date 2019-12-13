VC=v

build: clean
	$(VC) -g build module vsl

clean:
	rm -rf test *.o *.o.tmp*

test: build
	$(VC) -g run test.v
